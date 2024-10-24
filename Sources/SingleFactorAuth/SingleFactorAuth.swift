import BigInt
import Combine
import FetchNodeDetails
import Foundation
import SessionManager
import TorusUtils
import JWTDecode
#if canImport(curveSecp256k1)
    import curveSecp256k1
#endif

public class SingleFactorAuth {
    let nodeDetailManager: NodeDetailManager
    let torusUtils: TorusUtils
    private var sessionManager: SessionManager
    private var state: SessionData?

    public init(params: Web3AuthOptions) throws {
        sessionManager = SessionManager(sessionServerBaseUrl: params.getStorageServerUrl(), sessionTime: params.getSessionTime(), allowedOrigin: Bundle.main.bundleIdentifier ?? "single-factor-auth-swift")
        nodeDetailManager = NodeDetailManager(network: params.getNetwork())
        let torusOptions = TorusOptions(clientId: params.getClientId(), network: params.getNetwork(), serverTimeOffset: params.getServerTimeOffset(), enableOneKey: true)
        try torusUtils = TorusUtils(params: torusOptions)
    }

    public func initialize() async throws {
        let savedSessionId = SessionManager.getSessionIdFromStorage()
        
        if savedSessionId != nil && !savedSessionId!.isEmpty {
            sessionManager.setSessionId(sessionId: savedSessionId!)
            
            let data = try await sessionManager.authorizeSession(origin: Bundle.main.bundleIdentifier ?? "single-factor-auth-swift")
            guard let privKey = data["privateKey"] as? String,
                  let publicAddress = data["publicAddress"] as? String,
            let userInfo = data["userInfo"],
            let signatures = data["signatures"] else { throw SessionManagerError.decodingError }
            state = SessionData(privateKey: privKey, publicAddress: publicAddress, signatures: signatures as? TorusKey.SessionData, userInfo: userInfo as? UserInfo)
        }
    }
    
    public func getSessionData() -> SessionData? {
        return self.state
    }
    
    public func connected() -> Bool {
        return self.state != nil
    }

    private func getTorusKey(loginParams: LoginParams) async throws -> TorusKey {
        var retrieveSharesResponse: TorusKey

        let details = try await nodeDetailManager.getNodeDetails(verifier: loginParams.verifier, verifierID: loginParams.verifierId)

        /* TODO: Fix me
        if let serverTimeOffset = loginParams.serverTimeOffset {
            torusUtils.setServerTimeOffset(serverTimeOffset: serverTimeOffset)
        }
        */
        
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
        
        if retrieveSharesResponse.metadata.upgraded == true {
            throw SFAError.MFAAlreadyEnabled
        }

        return retrieveSharesResponse
    }

    public func connect(loginParams: LoginParams) async throws -> SessionData {
        let torusKey = try await getTorusKey(loginParams: loginParams)

        let publicAddress = torusKey.finalKeyData.evmAddress
        let privateKey = if (torusKey.finalKeyData.privKey.isEmpty) {
            torusKey.oAuthKeyData.privKey
        } else {
            torusKey.finalKeyData.privKey
        }

        var decodedUserInfo: UserInfo? = nil
        
        do {
            let jwt = try decode(jwt: loginParams.idToken)
            decodedUserInfo = UserInfo.init(email: jwt.body["email"] as? String ?? "", name: jwt.body["name"] as? String ?? "", profileImage: jwt.body["picture"] as? String ?? "", verifier: loginParams.verifier, verifierId: loginParams.verifierId, typeOfLogin: LoginType.jwt, state: .init(params: [:]))
        } catch {
            decodedUserInfo = loginParams.fallbackUserInfo
        }
        
        let sessionId = try SessionManager.generateRandomSessionID()!
        sessionManager.setSessionId(sessionId: sessionId)
        
        let sfaKey = SessionData(privateKey: privateKey, publicAddress: publicAddress, signatures: torusKey.sessionData, userInfo: decodedUserInfo)
        _ = try await sessionManager.createSession(data: sfaKey)
        
        SessionManager.saveSessionIdToStorage(sessionId)
        
        self.state = sfaKey
        return sfaKey
    }
    
    public func logout() async throws {
        try await sessionManager.invalidateSession()
    }
}
