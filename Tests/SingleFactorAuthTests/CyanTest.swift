import BigInt
import JWTKit
import XCTest
import SingleFactorAuth

final class CyanTest: XCTestCase {
    var singleFactoreAuth: SingleFactorAuth!
    var singleFactorAuthArgs: Web3AuthOptions!

    let TORUS_TEST_EMAIL = "hello@tor.us"
    let TEST_VERIFIER = "torus-test-health"
    let TEST_AGGREGRATE_VERIFIER = "torus-test-health-aggregate"

    override func setUp() {
        singleFactorAuthArgs = Web3AuthOptions(clientId: "CLIENT ID", web3AuthNetwork: .CYAN)
        singleFactoreAuth = try! SingleFactorAuth(params: singleFactorAuthArgs)
    }

    func testConnect() async throws {
        let idToken = try generateIdToken(email: TORUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_VERIFIER, verifierId: TORUS_TEST_EMAIL, idToken: idToken)
        let torusKey = try await singleFactoreAuth.connect(loginParams: loginParams)

        let requiredPrivateKey = "223d982054fa1ad27d1497560521e4cce5b8c6438c38533c7bad27ff21ce0546"
        XCTAssertEqual(requiredPrivateKey, torusKey.privateKey)
        XCTAssertEqual("0x6b902fBCEb0E0374e5eB9eDFe68cD4B888c32150", torusKey.publicAddress)
    }

    func testInitialise() async throws {
        let idToken = try generateIdToken(email: TORUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_VERIFIER, verifierId: TORUS_TEST_EMAIL, idToken: idToken)
        let torusKey = try await singleFactoreAuth.connect(loginParams: loginParams)
        let requiredPrivateKey = "223d982054fa1ad27d1497560521e4cce5b8c6438c38533c7bad27ff21ce0546"
        try await singleFactoreAuth.initialize()
        XCTAssertEqual(requiredPrivateKey, singleFactoreAuth.getSessionData()!.privateKey)
        XCTAssertEqual(torusKey.publicAddress, singleFactoreAuth.getSessionData()!.publicAddress)
    }

    func testAggregrateGetTorusKey() async throws {
        let idToken = try generateIdToken(email: TORUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_AGGREGRATE_VERIFIER, verifierId: TORUS_TEST_EMAIL, idToken: idToken, subVerifierInfoArray: [TorusSubVerifierInfo(verifier: TEST_VERIFIER, idToken: idToken)])
        let torusKey = try await singleFactoreAuth.connect(loginParams: loginParams)

        let requiredPrivateKey = "66af498ea82c95d52fdb8c8dedd44cf2f758424a0eecab7ac3dd8721527ea2d4"
        XCTAssertEqual(requiredPrivateKey, torusKey.privateKey)
        XCTAssertEqual("0xFF4c4A0Aa5D633302B5711C3047D7D5967884521", torusKey.publicAddress)
    }
}
