import BigInt
import FetchNodeDetails
import JWTKit
import SingleFactorAuth
import XCTest

final class SapphireDevnetTests: XCTestCase {
    var singleFactoreAuth: SingleFactorAuth!
    var singleFactorAuthArgs: Web3AuthOptions!

    let TORUS_TEST_EMAIL = "devnettestuser@tor.us"
    let TEST_VERIFIER = "torus-test-health"
    let TEST_AGGREGRATE_VERIFIER = "torus-test-health-aggregate"

    override func setUp() {
        singleFactorAuthArgs = Web3AuthOptions(clientId: "CLIENT ID", web3AuthNetwork: .SAPPHIRE_DEVNET)
        singleFactoreAuth = try! SingleFactorAuth(params: singleFactorAuthArgs)
    }

    func testConnect() async throws {
        let idToken = try generateIdToken(email: TORUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_VERIFIER, verifierId: TORUS_TEST_EMAIL, idToken: idToken)
        let torusKey = try await singleFactoreAuth.connect(loginParams: loginParams)

        let requiredPrivateKey = "230dad9f42039569e891e6b066ff5258b14e9764ef5176d74aeb594d1a744203"
        XCTAssertEqual(requiredPrivateKey, torusKey.privateKey)
        XCTAssertEqual("0x462A8BF111A55C9354425F875F89B22678c0Bc44", torusKey.publicAddress)
    }

    func testInitialise() async throws {
        let idToken = try generateIdToken(email: TORUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_VERIFIER, verifierId: TORUS_TEST_EMAIL, idToken: idToken)
        let _ = try await singleFactoreAuth.connect(loginParams: loginParams)
        try await singleFactoreAuth.initialize()
    }

    func testAggregrateGetTorusKey() async throws {
        let idToken = try generateIdToken(email: TORUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_AGGREGRATE_VERIFIER, verifierId: TORUS_TEST_EMAIL, idToken: idToken, subVerifierInfoArray: [TorusSubVerifierInfo(verifier: TEST_VERIFIER, idToken: idToken)])
        let torusKey = try await singleFactoreAuth.connect(loginParams: loginParams)

        let requiredPrivateKey = "edef171853fdf23ed3cfc702d32cf46f181b475a449d2f7b636924cabecd81d4"
        XCTAssertEqual(requiredPrivateKey, torusKey.privateKey)
        XCTAssertEqual("0xfC58EB0475F1E3fa05877eE2e1350f6A619E2d78", torusKey.publicAddress)
    }
}
