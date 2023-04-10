class AggregateVerifierParams {
    var verifyParams: [VerifierParams]
    var subVerifierIds: [String]
    var verifierId: String

    init(verifyParams: [VerifierParams], subVerifierIds: [String], verifierId: String) {
        self.verifyParams = verifyParams
        self.subVerifierIds = subVerifierIds
        self.verifierId = verifierId
    }
}

struct VerifierParams {
    var verifierId: String
    var idToken: String
}
