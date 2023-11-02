class AggregateVerifierParams {
    var verifyParams: [VerifierSFAParams]
    var subVerifierIds: [String]
    var verifierId: String?

    init(verifyParams: [VerifierSFAParams], subVerifierIds: [String]) {
        self.verifyParams = verifyParams
        self.subVerifierIds = subVerifierIds
    }
}

struct VerifierSFAParams {
    var verifierId: String
    var idToken: String
}
