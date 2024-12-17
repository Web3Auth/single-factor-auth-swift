import BigInt
import UIKit
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
    private var initParams: Web3AuthOptions
    
    var webViewController: WebViewController = DispatchQueue.main.sync { WebViewController(onSignResponse: { _ in }) }
    private static var signResponse: SignResponse?
    let SIGNER_MAP: [Network: String] = [
        .mainnet: "https://signer.web3auth.io",
        .testnet: "https://signer.web3auth.io",
        .cyan: "https://signer-polygon.web3auth.io",
        .aqua: "https://signer-polygon.web3auth.io",
        .sapphire_mainnet: "https://signer.web3auth.io",
        .sapphire_devnet: "https://signer.web3auth.io",
    ]

    public init(params: Web3AuthOptions) throws {
        sessionManager = SessionManager(sessionServerBaseUrl: params.getStorageServerUrl(), sessionTime: params.getSessionTime(), allowedOrigin: Bundle.main.bundleIdentifier ?? "single-factor-auth-swift")
        nodeDetailManager = NodeDetailManager(network: params.getNetwork())
        initParams = params
        let torusOptions = TorusOptions(clientId: params.getClientId(), network: params.getNetwork(), serverTimeOffset: params.getServerTimeOffset(), enableOneKey: true)
        try torusUtils = TorusUtils(params: torusOptions)
    }

    public func initialize() async throws {
        let savedSessionId = SessionManager.getSessionIdFromStorage()
        
        if savedSessionId != nil && !savedSessionId!.isEmpty {
            sessionManager.setSessionId(sessionId: savedSessionId!)
            
            // TODO: FIXME!!! Underlying dependency must use codable as a return type and not [String: Any] since it makes life difficult for ourselves unnecessarily
            let data = try await sessionManager.authorizeSession(origin: Bundle.main.bundleIdentifier ?? "single-factor-auth-swift")
            guard let privKey = data["privateKey"] as? String,
                  let publicAddress = data["publicAddress"] as? String,
            let userInfo = data["userInfo"],
            let signatures = data["signatures"] else { throw SessionManagerError.decodingError }
            
            let jsonInfo = try JSONSerialization.data(withJSONObject: userInfo, options: [])
            
            let finalUserInfo = try JSONDecoder().decode(UserInfo.self, from: jsonInfo)

            let jsonData = try JSONSerialization.data(withJSONObject: signatures, options: [])
            
            let finalSignatures = try JSONDecoder().decode([String].self, from: jsonData)
            state = SessionData(privateKey: privKey, publicAddress: publicAddress, signatures: finalSignatures, userInfo: finalUserInfo)
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
        
        let sfaKey = SessionData(privateKey: privateKey, publicAddress: publicAddress, signatures: getSignatureData(sessionTokenData: torusKey.sessionData.sessionTokenData), userInfo: decodedUserInfo)
        _ = try await sessionManager.createSession(data: sfaKey)
        
        SessionManager.saveSessionIdToStorage(sessionId)
        
        self.state = sfaKey
        return sfaKey
    }
    
    public func logout() async throws {
        try await sessionManager.invalidateSession()
        SessionManager.deleteSessionIdFromStorage()
        self.state = nil
    }
    
    private func getSignatureData(sessionTokenData: [SessionToken?]) -> [String] {
        return sessionTokenData
            .compactMap { $0 } // Remove nil values
            .map { session in
                "{\"data\":\"\(session.token)\",\"sig\":\"\(session.signature)\"}"
            }
    }
    
    public func showWalletUI(chainConfig: ChainConfig, path: String? = "wallet") async throws {
        let projectConfigSuccess = try await fetchProjectConfig()
        
        if projectConfigSuccess {
            let sessionId = SessionManager.getSessionIdFromStorage()!
            if !sessionId.isEmpty {
                initParams.chainConfig = chainConfig
                let walletServicesParams = WalletServicesParams(options: initParams, appState: nil)
                
                var loginId: String? = nil
                if let jsonData = paramsToJson(walletServicesParams) {
                    loginId = try await getLoginId(data: jsonData)
                }
                
                let jsonObject: [String: String?] = [
                    "loginId": loginId,
                    "sessionId": sessionId,
                    "platform": "ios",
                    "sessionNamespace": "sfa"
                ]
                
                let url = try SingleFactorAuth.generateAuthSessionURL(
                    initParams: initParams,
                    jsonObject: jsonObject,
                    sdkUrl: initParams.walletSdkUrl?.absoluteString,
                    path: path
                )
                
                // Ensure UI-related operations occur on the main thread
                await MainActor.run {
                    guard let rootViewController = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController else {
                        return
                    }
                    rootViewController.present(webViewController, animated: true) {
                        self.webViewController.webView.load(URLRequest(url: url))
                    }
                }
            } else {
                throw SFAError.runtimeError("SessionId not found. Please login first.")
            }
        } else {
            throw SFAError.runtimeError("Failed to fetch project configuration.")
        }
    }
    
    public func request(chainConfig: ChainConfig, method: String, requestParams: [Any], path: String? = "wallet/request", appState: String? = nil) async throws -> SignResponse {
        let projectConfigSuccess = try await fetchProjectConfig()
        
        if projectConfigSuccess {
            let sessionId = SessionManager.getSessionIdFromStorage()!
            if !sessionId.isEmpty {
                initParams.chainConfig = chainConfig
                
                let walletServicesParams = WalletServicesParams(options: initParams, appState: appState)
                
                var loginId: String? = nil
                if let jsonData = paramsToJson(walletServicesParams) {
                    loginId = try await getLoginId(data: jsonData)
                }
                
                var signMessageMap: [String: String] = [:]
                signMessageMap["loginId"] = loginId
                signMessageMap["sessionId"] = sessionId
                signMessageMap["platform"] = "ios"
                signMessageMap["sessionNamespace"] = "sfa"
                
                var requestData: [String: Any] = [:]
                requestData["method"] = method
                requestData["params"] = try? JSONSerialization.jsonObject(with: JSONSerialization.data(withJSONObject: requestParams), options: []) as? [Any]
                
                if let requestDataJson = try? JSONSerialization.data(withJSONObject: requestData, options: []),
                   let requestDataJsonString = String(data: requestDataJson, encoding: .utf8) {
                    // Add the requestData JSON string to signMessageMap as a property
                    signMessageMap["request"] = requestDataJsonString
                }
                
                let url = try SingleFactorAuth.generateAuthSessionURL(initParams: initParams, jsonObject: signMessageMap, sdkUrl: initParams.walletSdkUrl?.absoluteString, path: path)
                
                // open url in webview
                return await withCheckedContinuation { continuation in
                    Task {
                        let webViewController = await MainActor.run {
                            WebViewController(redirectUrl: initParams.redirectUrl, onSignResponse: { signResponse in
                                continuation.resume(returning: signResponse)
                            })
                        }
                        
                        DispatchQueue.main.async {
                            UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController?.present(webViewController, animated: true) {
                                webViewController.webView.load(URLRequest(url: url))
                            }
                        }
                    }
                }
            } else {
                throw SFAError.runtimeError("SessionId not found. Please login first.")
            }
        } else {
            throw SFAError.runtimeError("Failed to fetch project configuration.")
        }
    }
    
    func paramsToJson(_ params: WalletServicesParams) -> Data? {
        var dict: [String: Any] = [:]
        dict["clientId"] = params.options.clientId
        dict["sessionTime"] = params.options.getSessionTime()
        dict["storageServerUrl"] = params.options.getStorageServerUrl()
        dict["serverTimeOffset"] = params.options.getServerTimeOffset()
        dict["redirectUrl"] = params.options.redirectUrl
        dict["walletSdkUrl"] = params.options.walletSdkUrl?.absoluteString
        dict["web3AuthNetworkName"] = params.options.getNetwork().name
        dict["appState"] = params.appState

        return try? JSONSerialization.data(withJSONObject: dict, options: [])
    }
    
    public func fetchProjectConfig() async throws -> Bool {
        var response: Bool = false
        let api = Router.get([.init(name: "project_id", value: initParams.clientId), .init(name: "network", value: initParams.web3AuthNetwork.name), .init(name: "whitelist", value: "true")])
        let result = await Service.request(router: api)
        switch result {
        case let .success(data):
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(ProjectConfigResponse.self, from: data)
                // os_log("fetchProjectConfig API response is: %@", log: getTorusLogger(log: Web3AuthLogger.network, type: .info), type: .info, "\(String(describing: result))")
                initParams.originData = result.whitelist.signedUrls.merging(initParams.originData ?? [:]) { _, new in new }
                if let whiteLabelData = result.whiteLabelData {
                    if initParams.whiteLabel == nil {
                        initParams.whiteLabel = whiteLabelData
                    } else {
                        initParams.whiteLabel = initParams.whiteLabel?.merge(with: whiteLabelData)
                    }
                }
                response = true
            } catch {
                throw error
            }
        case let .failure(error):
            throw error
        }
        return response
    }
    
    public func getLoginId<T: Encodable>(data: T) async throws -> String? {
        let sessionId = try SessionManager.generateRandomSessionID()!
        sessionManager.setSessionId(sessionId: sessionId)
        return try await sessionManager.createSession(data: data)
    }
    
    static func generateAuthSessionURL(initParams: Web3AuthOptions, jsonObject: [String: String?], sdkUrl: String?, path: String?) throws -> URL {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting.insert(.sortedKeys)

        guard
            let data = try? jsonEncoder.encode(jsonObject),
            // Using sorted keys to produce consistent results
            var components = URLComponents(string: sdkUrl ?? "")
        else {
            throw SFAError.encodingError
        }
        components.path = components.path + "/" + path!
        components.fragment = "b64Params=" + data.toBase64URL()

        guard let url = components.url
        else {
            throw SFAError.runtimeError("Invalid URL")
        }

        return url
    }
}
