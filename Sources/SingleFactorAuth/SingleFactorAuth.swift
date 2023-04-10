import FetchNodeDetails
import TorusUtils
import Combine
import CryptoSwift
import Foundation
import BigInt

open class SingleFactorAuth {
    let nodeDetailManager: FetchNodeDetails
    let torusUtils: TorusUtils
    
    init(singleFactorAuthArgs: SingleFactorAuthArgs) {
        self.nodeDetailManager = FetchNodeDetails(proxyAddress: singleFactorAuthArgs.getNetworkUrl()!, network: singleFactorAuthArgs.getNetwork())
        self.torusUtils = TorusUtils(
            enableOneKey: true,
            signerHost: singleFactorAuthArgs.getSignerUrl()! + "/api/sign",
            allowHost: singleFactorAuthArgs.getSignerUrl()! + "/api/allow",
            network: singleFactorAuthArgs.getNetwork()
        )
    }

    func getKey(loginParams: LoginParams) async -> TorusKey {
        var retrieveSharesResponse: [String: String] = [:];
        
        do {
            var details = try await self.nodeDetailManager.getNodeDetails(verifier: loginParams.verifier, verifierID: loginParams.verifierId)
            let pubDetails = try await self.torusUtils.getUserTypeAndAddress(
                    endpoints: details.getTorusNodeEndpoints(),
                    torusNodePub: details.getTorusNodePub(),
                    verifier: loginParams.verifier,
                    verifierID: loginParams.verifierId)
        
            if pubDetails.typeOfUser == .v1 {
                let d = try await torusUtils.getOrSetNonce(x: pubDetails.x, y: pubDetails.y)
                if d.upgraded == true {
                    throw "User already havee enabled MFA"
                }
            }
            
            if let subVerifierInfoArray = loginParams.subVerifierInfoArray, !subVerifierInfoArray.isEmpty {
                
                let aggregateVerifierParams = AggregateVerifierParams(
                    verifyParams: Array(repeating: VerifierParams(verifierId: loginParams.verifierId, idToken: ""), count: subVerifierInfoArray.count),
                    subVerifierIds: Array(repeating: "", count: subVerifierInfoArray.count)
                )
                
                var aggregateIdTokenSeeds = [String]()
                var aggregateVerifierId = ""
                
                for (i, userInfo) in subVerifierInfoArray.enumerated() {
                    let finalToken = userInfo.idToken
                    aggregateVerifierParams.verifyParams[i].idToken = finalToken
                    aggregateVerifierParams.subVerifierIds[i] = userInfo.verifier
                    
                    aggregateIdTokenSeeds.append(finalToken)
                    aggregateVerifierId = loginParams.verifierId
                }
                aggregateIdTokenSeeds.sort()
                
                let aggregateTokenString = aggregateIdTokenSeeds.joined(separator: String(Character(UnicodeScalar(29))))
                let aggregateIdToken = String(aggregateTokenString.sha3(.keccak256).dropFirst(2))
                
                aggregateVerifierParams.verifierId = aggregateVerifierId
                
                var aggregateVerifierParamsHashMap = [String: Any]()
                aggregateVerifierParamsHashMap["verify_params"] = aggregateVerifierParams.verifyParams
                aggregateVerifierParamsHashMap["sub_verifier_ids"] = aggregateVerifierParams.subVerifierIds
                aggregateVerifierParamsHashMap["verifier_id"] = aggregateVerifierParams.verifierId
                details = try await self.nodeDetailManager.getNodeDetails(verifier: loginParams.verifier, verifierID: aggregateVerifierId)
                
                retrieveSharesResponse = try await torusUtils.retrieveShares(
                    torusNodePubs: details.getTorusNodePub(),
                    endpoints: details.getTorusNodeEndpoints(),
                    verifier: loginParams.verifier,
                    verifierId: loginParams.verifierId,
                    idToken: aggregateIdToken,
                    extraParams: Data()
                )
            } else {
                var verifierParams = [String: Any]()
                verifierParams["verifier_id"] = loginParams.verifierId
                retrieveSharesResponse = try await self.torusUtils.retrieveShares(
                    torusNodePubs: details.getTorusNodePub(),
                    endpoints: details.getTorusNodeEndpoints(),
                    verifier: loginParams.verifier,
                    verifierId: loginParams.verifierId,
                    idToken: loginParams.idToken,
                    extraParams: Data()
                )
            }
            if retrieveSharesResponse["privKey"] == nil {
                throw "Unable to generate privKey"
            }
            
        } catch {
            print(error)
        }
        
        let torusKey = TorusKey(privateKey: BigInt(retrieveSharesResponse["privKey"]!, radix: 16)!, publicAddress: retrieveSharesResponse["ethAddress"]!)
        return torusKey;
    }

}
