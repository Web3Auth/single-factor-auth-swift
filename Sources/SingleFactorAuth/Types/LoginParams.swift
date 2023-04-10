class LoginParams {
    let verifier: String
    let verifierId: String
    let idToken: String
    let subVerifierInfoArray: [TorusSubVerifierInfo]?

    init(verifier: String, verifierId: String, idToken: String) {
        self.verifier = verifier
        self.verifierId = verifierId
        self.idToken = idToken
        self.subVerifierInfoArray = nil
    }

    init(verifier: String, verifierId: String, idToken: String, subVerifierInfoArray: [TorusSubVerifierInfo]) {
        self.verifier = verifier
        self.verifierId = verifierId
        self.idToken = idToken
        self.subVerifierInfoArray = subVerifierInfoArray
    }
}

struct TorusSubVerifierInfo {
    var name: String
    var state: String
    var identifier: String
}
