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

    public func getTorusKey(loginParams: LoginParams) async throws -> TorusKey {
        var retrieveSharesResponse: TorusKey

        let details = try await nodeDetailManager.getNodeDetails(verifier: loginParams.verifier, verifierID: loginParams.verifierId)

        let userDetails = try await torusUtils.getUserTypeAndAddress(endpoints: details.getTorusNodeEndpoints(), torusNodePubs: details.getTorusNodePub(), verifier: loginParams.verifier, verifierId: loginParams.verifierId)

        if userDetails.metadata?.upgraded == true {
            throw "User already has enabled MFA"
        }

        if let subVerifierInfoArray = loginParams.subVerifierInfoArray, !subVerifierInfoArray.isEmpty {
            var aggregateIdTokenSeeds = [String]()
            var subVerifierIds = [String]()
            var verifyParams = [[String: String]]()
            for value in subVerifierInfoArray {
                aggregateIdTokenSeeds.append(value.idToken)

                var verifyParam: [String: String] = [:]
                verifyParam["verifier_id"] = loginParams.verifierId
                verifyParam["idtoken"] = value.idToken

                verifyParams.append(verifyParam)
                subVerifierIds.append(value.verifier)
            }
            aggregateIdTokenSeeds.sort()

            let extraParams = [
                "verifier_id": loginParams.verifierId,
                "sub_verifier_ids": subVerifierIds,
                "verify_params": verifyParams,
            ] as [String: Codable]

            let verifierParams = VerifierParams(verifier_id: loginParams.verifierId)

            let aggregateIdToken = String(String(bytes: aggregateIdTokenSeeds.joined(separator: "\u{001d}").bytes.sha3(.keccak256)).dropFirst(2)) // drop 0x

            retrieveSharesResponse = try await torusUtils.retrieveShares(
                endpoints: details.getTorusNodeEndpoints(),
                torusNodePubs: details.getTorusNodePub(),
                indexes: details.getTorusIndexes(),
                verifier: loginParams.verifier,
                verifierParams: verifierParams,
                idToken: aggregateIdToken,
                extraParams: extraParams
            )
        } else {
            let verifierParams = VerifierParams(verifier_id: loginParams.verifierId)

            retrieveSharesResponse = try await torusUtils.retrieveShares(
                endpoints: details.getTorusNodeEndpoints(),
                torusNodePubs: details.getTorusNodePub(),
                indexes: details.getTorusIndexes(),
                verifier: loginParams.verifier,
                verifierParams: verifierParams,
                idToken: loginParams.idToken
            )
        }

        return retrieveSharesResponse
    }
    
    public func getKey(loginParams: LoginParams) async throws -> TorusSFAKey {
        let torusKey = try await self.getTorusKey(loginParams: loginParams)
        
        let publicAddress = (torusKey.finalKeyData?.X ?? "") + (torusKey.finalKeyData?.Y ?? "")
        let privateKey = torusKey.finalKeyData?.privKey ?? ""

        let torusSfaKey = TorusSFAKey(privateKey: privateKey, publicAddress: publicAddress)
        _ = try await sessionManager.createSession(data: torusSfaKey)
        return torusSfaKey
    }
}
