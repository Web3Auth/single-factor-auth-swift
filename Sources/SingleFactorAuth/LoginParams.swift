public class LoginParams: Codable {
    public let verifier: String
    public let verifierId: String
    public let idToken: String
    public let subVerifierInfoArray: [TorusSubVerifierInfo]?
    public let serverTimeOffset: Int?
    public let fallbackUserInfo: UserInfo?

    public init(verifier: String, verifierId: String, idToken: String, subVerifierInfoArray: [TorusSubVerifierInfo]? = nil, serverTimeOffset: Int? = nil, fallbackUserInfo: UserInfo? = nil) {
        self.verifier = verifier
        self.verifierId = verifierId
        self.idToken = idToken
        self.subVerifierInfoArray = subVerifierInfoArray
        self.serverTimeOffset = serverTimeOffset
        self.fallbackUserInfo = fallbackUserInfo
    }
}

public struct TorusSubVerifierInfo: Codable {
    public var verifier: String
    public var idToken: String

    public init(verifier: String, idToken: String) {
        self.verifier = verifier
        self.idToken = idToken
    }
}
