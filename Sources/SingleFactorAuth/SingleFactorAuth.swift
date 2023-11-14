import BigInt
import Combine
import CryptoSwift
import FetchNodeDetails
import Foundation
import SessionManager
import TorusUtils

public class SingleFactorAuth {
    let nodeDetailManager: NodeDetailManager
    let torusUtils: TorusUtils
    private var sessionManager: SessionManager

    public init(singleFactorAuthArgs: SingleFactorAuthArgs) {
        sessionManager = .init()
        nodeDetailManager = NodeDetailManager(network: singleFactorAuthArgs.getNetwork())
        torusUtils = TorusUtils(
            enableOneKey: true,
            signerHost: singleFactorAuthArgs.getSignerUrl()! + "/api/sign",
            allowHost: singleFactorAuthArgs.getSignerUrl()! + "/api/allow",
            network: singleFactorAuthArgs.getNetwork()
        )
    }

    public func initialize() async throws -> TorusSFAKey {
        let data = try await sessionManager.authorizeSession()
        guard let privKey = data["privateKey"] as? String,
              let publicAddress = data["publicAddress"] as? String else { throw SessionManagerError.decodingError }
        return .init(privateKey: privKey, publicAddress: publicAddress)
    }

    public func getKey(loginParams: LoginParams) async throws -> TorusSFAKey {
        var retrieveSharesResponse: TorusKey

        var details = try await nodeDetailManager.getNodeDetails(verifier: loginParams.verifier, verifierID: loginParams.verifierId)

        let userDetails = try await torusUtils.getUserTypeAndAddress(endpoints: details.getTorusNodeEndpoints(), torusNodePubs: details.getTorusNodePub(), verifier: loginParams.verifier, verifierId: loginParams.verifierId)

        if userDetails.metadata?.upgraded == true {
            throw "User already has enabled MFA"
        }

        if let subVerifierInfoArray = loginParams.subVerifierInfoArray, !subVerifierInfoArray.isEmpty {
            var aggregateIdTokenSeeds = [String]()
            var subVerifierIds = [String]()
            var verifyParams = [[String: String]]()

            for (i, _) in subVerifierInfoArray.enumerated() {
                aggregateIdTokenSeeds.append(subVerifierInfoArray[i].idToken)

                var verifyParam: [String: String] = [:]
                verifyParam["verifier_id"] = loginParams.verifierId
                verifyParam["idToken"] = subVerifierInfoArray[i].idToken

                verifyParams.append(verifyParam)
                subVerifierIds.append(subVerifierInfoArray[i].verifier)
            }

            let extraParams = [
                "verifier_id": loginParams.verifierId,
                "sub_verifier_ids": subVerifierIds,
                "verify_params": verifyParams
            ] as [String : Codable]
            
            let aggregateIdToken = String(aggregateIdTokenSeeds.joined(separator: " ").sha3(.keccak256))

            details = try await nodeDetailManager.getNodeDetails(verifier: loginParams.verifier, verifierID: loginParams.verifierId)
            
            let additionalParams = VerifierParams(verifier_id: loginParams.verifierId, additionalParams: extraParams)
            
            retrieveSharesResponse = try await torusUtils.retrieveShares(
                endpoints: details.getTorusNodeEndpoints(),
                torusNodePubs: details.getTorusNodePub(),
                indexes: details.getTorusIndexes(),
                verifier: loginParams.verifier,
                verifierParams: additionalParams,
                idToken: aggregateIdToken
            )
        } else {
            let extraParams = VerifierParams(verifier_id: loginParams.verifierId)

            retrieveSharesResponse = try await torusUtils.retrieveShares(
                endpoints: details.getTorusNodeEndpoints(),
                torusNodePubs: details.getTorusNodePub(),
                indexes: details.getTorusIndexes(),
                verifier: loginParams.verifier,
                verifierParams: extraParams,
                idToken: loginParams.idToken
            )
        }

        let publicAddress = (retrieveSharesResponse.finalKeyData?.X ?? "") + (retrieveSharesResponse.finalKeyData?.Y ?? "")
        let privateKey = retrieveSharesResponse.finalKeyData?.privKey ?? ""

        let torusKey = TorusSFAKey(privateKey: privateKey, publicAddress: publicAddress)
        _ = try await sessionManager.createSession(data: torusKey)
        return torusKey
    }
}
