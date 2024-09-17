import BigInt
import Combine
import FetchNodeDetails
import Foundation
import SessionManager
import TorusUtils
#if canImport(curveSecp256k1)
    import curveSecp256k1
#endif

public class SingleFactorAuth {
    let nodeDetailManager: NodeDetailManager
    let torusUtils: TorusUtils
    private var sessionManager: SessionManager

    public init(singleFactorAuthArgs: SFAParams, sessionTime: Int) throws {
        sessionManager = SessionManager(sessionTime: sessionTime, allowedOrigin: Bundle.main.bundleIdentifier ?? "single-factor-auth-swift")
        nodeDetailManager = NodeDetailManager(network: singleFactorAuthArgs.getNetwork())
        let torusOptions = TorusOptions(clientId: singleFactorAuthArgs.getWeb3AuthClientId(), network: singleFactorAuthArgs.getNetwork(), enableOneKey: true)
        try torusUtils = TorusUtils(params: torusOptions)
    }

    public func initialize() async throws -> SFAKey {
        let data = try await sessionManager.authorizeSession(origin: Bundle.main.bundleIdentifier ?? "single-factor-auth-swift")
        guard let privKey = data["privateKey"] as? String,
              let publicAddress = data["publicAddress"] as? String else { throw SessionManagerError.decodingError }
        return .init(privateKey: privKey, publicAddress: publicAddress)
    }
    
    public func isSessionIdExists() -> Bool {
        if (sessionManager.getSessionID() != nil) && !(sessionManager.getSessionID()!.isEmpty) {
            return true
        }
        return false
    }

    public func getTorusKey(loginParams: LoginParams) async throws -> TorusKey {
        var retrieveSharesResponse: TorusKey

        let details = try await nodeDetailManager.getNodeDetails(verifier: loginParams.verifier, verifierID: loginParams.verifierId)

        let userDetails = try await torusUtils.getUserTypeAndAddress(endpoints: details.getTorusNodeEndpoints(), verifier: loginParams.verifier, verifierId: loginParams.verifierId)

        if userDetails.metadata?.upgraded == true {
            throw "User already has enabled MFA"
        }

        if let subVerifierInfoArray = loginParams.subVerifierInfoArray, !subVerifierInfoArray.isEmpty {
            var aggregateIdTokenSeeds = [String]()
            var subVerifierIds = [String]()
            var verifyParams = [VerifyParams]()
            for value in subVerifierInfoArray {
                aggregateIdTokenSeeds.append(value.idToken)

                let verifyParam = VerifyParams(verifier_id: loginParams.verifierId, idtoken: value.idToken)

                verifyParams.append(verifyParam)
                subVerifierIds.append(value.verifier)
            }
            aggregateIdTokenSeeds.sort()

            let verifierParams = VerifierParams(verifier_id: loginParams.verifierId, sub_verifier_ids: subVerifierIds, verify_params: verifyParams)

            let aggregateIdToken = try curveSecp256k1.keccak256(data: Data(aggregateIdTokenSeeds.joined(separator: "\u{001d}").utf8)).toHexString()

            retrieveSharesResponse = try await torusUtils.retrieveShares(
                endpoints: details.getTorusNodeEndpoints(),
                verifier: loginParams.verifier,
                verifierParams: verifierParams,
                idToken: aggregateIdToken
            )
        } else {
            let verifierParams = VerifierParams(verifier_id: loginParams.verifierId)

            retrieveSharesResponse = try await torusUtils.retrieveShares(
                endpoints: details.getTorusNodeEndpoints(),
                verifier: loginParams.verifier,
                verifierParams: verifierParams,
                idToken: loginParams.idToken
            )
        }

        return retrieveSharesResponse
    }

    public func connect(loginParams: LoginParams) async throws -> SFAKey {
        let torusKey = try await getTorusKey(loginParams: loginParams)

        let publicAddress = torusKey.finalKeyData.evmAddress
        let privateKey = torusKey.finalKeyData.privKey

        let sfaKey = SFAKey(privateKey: privateKey, publicAddress: publicAddress)
        _ = try await sessionManager.createSession(data: sfaKey)
        return sfaKey
    }
}
