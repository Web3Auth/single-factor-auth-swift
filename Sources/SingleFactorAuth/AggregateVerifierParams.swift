class AggregateVerifierParams {
    var verifyParams: [VerifierParams]
    var subVerifierIds: [String]
    var verifierId: String?

    init(verifyParams: [VerifierParams], subVerifierIds: [String]) {
        self.verifyParams = verifyParams
        self.subVerifierIds = subVerifierIds
    }
}

struct VerifierParams {
    var verifierId: String
    var idToken: String
}
