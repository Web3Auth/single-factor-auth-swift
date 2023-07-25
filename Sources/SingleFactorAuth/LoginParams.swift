public class LoginParams {
    public let verifier: String
    public let verifierId: String
    public let idToken: String
    public let subVerifierInfoArray: [TorusSubVerifierInfo]?

    public init(verifier: String, verifierId: String, idToken: String) {
        self.verifier = verifier
        self.verifierId = verifierId
        self.idToken = idToken
        self.subVerifierInfoArray = nil
    }

    public init(verifier: String, verifierId: String, idToken: String, subVerifierInfoArray: [TorusSubVerifierInfo]) {
        self.verifier = verifier
        self.verifierId = verifierId
        self.idToken = idToken
        self.subVerifierInfoArray = subVerifierInfoArray
    }
}

public struct TorusSubVerifierInfo {
    public var verifier: String
    public var idToken: String
    
    public init(verifier: String, idToken: String) {
        self.verifier = verifier
        self.idToken = idToken
    }
}
