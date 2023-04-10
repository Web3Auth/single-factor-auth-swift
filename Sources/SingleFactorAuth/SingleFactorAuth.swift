import FetchNodeDetails
import TorusUtils

open class SingleFactorAuth {
    let nodeDetailManager: FetchNodeDetails
    let torusUtils: TorusUtils
    
    init(singleFactorAuthArgs: SingleFactorAuthArgs) {
        if singleFactorAuthArgs.networkUrl.isEmpty {
            self.nodeDetailManager = FetchNodeDetails(network: singleFactorAuthArgs.network, contractMap: SingleFactorAuthArgs.CONTRACT_MAP[singleFactorAuthArgs.network]!)
        } else {
            self.nodeDetailManager = FetchNodeDetails(networkUrl: singleFactorAuthArgs.networkUrl, contractMap: SingleFactorAuthArgs.CONTRACT_MAP[singleFactorAuthArgs.network]!)
        }
        
        let opts = TorusCtorOptions(name: "SingleFactorAuth")
        opts.enableOneKey = true
        opts.network = singleFactorAuthArgs.network.rawValue
        opts.signerHost = SingleFactorAuthArgs.SIGNER_MAP[singleFactorAuthArgs.network]! + "/api/sign"
        opts.allowHost = SingleFactorAuthArgs.SIGNER_MAP[singleFactorAuthArgs.network]! + "/api/allow"
        self.torusUtils = TorusUtils(opts: opts)
    }

    func getKey(loginParams: LoginParams) -> EventLoopFuture<TorusKey> {
        do {
            let details = try self.nodeDetailManager.getNodeDetails(verifier: loginParams.verifier, verifierId: loginParams.verifierId).wait()
            let pubDetails = try torusUtils.getUserTypeAndAddress(nodeEndpoints: details.torusNodeEndpoints, pub: details.torusNodePub, args: VerifierArgs(verifier: loginParams.verifier, verifierId: loginParams.verifierId), normalize: true).wait()
            if pubDetails.upgraded {
                let response = eventLoop.makeFailedFuture(TorusError.userHasEnabledMFA)
                return response
            }
            if pubDetails.typeOfUser == .v1 {
                try torusUtils.getOrSetNonce(x: pubDetails.x, y: pubDetails.y, normalize: false).wait()
            }
            var retrieveSharesResponse: RetrieveSharesResponse

            if let subVerifierInfoArray = loginParams.subVerifierInfoArray, !subVerifierInfoArray.isEmpty {
                var aggregateVerifierParams = AggregateVerifierParams()
                aggregateVerifierParams.verifyParams = Array(repeating: AggregateVerifierParams.VerifierParams(verifier: loginParams.verifierId, token: ""), count: subVerifierInfoArray.count)
                aggregateVerifierParams.subVerifierIds = Array(repeating: "", count: subVerifierInfoArray.count)
                var aggregateIdTokenSeeds = [String]()
                var aggregateVerifierId = ""
                for (i, userInfo) in subVerifierInfoArray.enumerated() {
                    let finalToken = userInfo.idToken
                    aggregateVerifierParams.verifyParams[i].token = finalToken
                    aggregateVerifierParams.subVerifierIds[i] = userInfo.verifier
                    aggregateIdTokenSeeds.append(finalToken)
                    aggregateVerifierId = loginParams.verifierId
                }
                aggregateIdTokenSeeds.sort()
                let aggregateTokenString = aggregateIdTokenSeeds.joined(separator: String(Character(UnicodeScalar(29))))
                let aggregateIdToken = Hash.sha3String(aggregateTokenString).substring(fromIndex: 2)
                aggregateVerifierParams.verifierId = aggregateVerifierId
                var aggregateVerifierParamsHashMap = [String: Any]()
                aggregateVerifierParamsHashMap["verify_params"] = aggregateVerifierParams.verifyParams
                aggregateVerifierParamsHashMap["sub_verifier_ids"] = aggregateVerifierParams.subVerifierIds
                aggregateVerifierParamsHashMap["verifier_id"] = aggregateVerifierParams.verifierId
                details = try self.nodeDetailManager.getNodeDetails(verifier: loginParams.verifier, verifierId: aggregateVerifierId).wait()
                retrieveSharesResponse = try torusUtils.retrieveShares(nodeEndpoints: details.torusNodeEndpoints, indexes: details.torusIndexes, verifier: loginParams.verifier, verifierParams: aggregateVerifierParamsHashMap, idToken: aggregateIdToken).wait()
            } else {
                var verifierParams = [String: Any]()
                verifierParams["verifier_id"] = loginParams.verifierId
                retrieveSharesResponse = try torusUtils.retrieveShares(nodeEndpoints: details.torusNodeEndpoints, indexes: details.torusIndexes, verifier: loginParams.verifier, verifierParams: verifierParams, idToken: loginParams.idToken).wait()
            }
            if retrieveSharesResponse.privKey == nil {
                return eventLoop.makeFailedFuture(TorusError.unableToGetPrivateKey)
            }
            let torusKey = TorusKey(privKey: retrieveSharesResponse.privKey!, ethAddress: retrieveSharesResponse.ethAddress!)
            return eventLoop.makeSucceededFuture(torusKey)
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
    }

}