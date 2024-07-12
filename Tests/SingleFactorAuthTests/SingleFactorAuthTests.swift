import BigInt
import JWTKit
import XCTest

@testable import SingleFactorAuth

final class SingleFactorAuthTests: XCTestCase {
    var singleFactoreAuth: SingleFactorAuth!
    var singleFactorAuthArgs: SingleFactorAuthArgs!

    let TOURUS_TEST_EMAIL = "hello@tor.us"
    let TEST_VERIFIER = "torus-test-health"
    let TEST_AGGREGRATE_VERIFIER = "torus-test-health-aggregate"

    override func setUp() {
        singleFactorAuthArgs = SingleFactorAuthArgs(web3AuthClientId: "CLIENT ID", network: Web3AuthNetwork.TESTNET)
        singleFactoreAuth = SingleFactorAuth(singleFactorAuthArgs: singleFactorAuthArgs)
    }

    func testGetTorusKey() async throws {
        let idToken = try generateIdToken(email: TOURUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_VERIFIER, verifierId: TOURUS_TEST_EMAIL, idToken: idToken)
        let torusKey = try await singleFactoreAuth.getKey(loginParams: loginParams)
        let requiredPrivateKey = "296045a5599afefda7afbdd1bf236358baff580a0fe2db62ae5c1bbe817fbae4"
        XCTAssertEqual(requiredPrivateKey, torusKey.getPrivateKey())
        XCTAssertEqual("0x53010055542cCc0f2b6715a5c53838eC4aC96EF7", torusKey.getPublicAddress())
    }

    func testInitialise() async throws {
        let idToken = try generateIdToken(email: TOURUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_VERIFIER, verifierId: TOURUS_TEST_EMAIL, idToken: idToken)
        let torusKey = try await singleFactoreAuth.getKey(loginParams: loginParams)
        let savedKey = try await singleFactoreAuth.initialize()
        let requiredPrivateKey = "296045a5599afefda7afbdd1bf236358baff580a0fe2db62ae5c1bbe817fbae4"
        XCTAssertEqual(requiredPrivateKey, savedKey.getPrivateKey())
        XCTAssertEqual(torusKey.publicAddress, savedKey.getPublicAddress())
    }

    func testAggregrateGetTorusKey() async throws {
        let idToken = try generateIdToken(email: TOURUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_AGGREGRATE_VERIFIER, verifierId: TOURUS_TEST_EMAIL, idToken: idToken, subVerifierInfoArray: [TorusSubVerifierInfo(verifier: TEST_VERIFIER, idToken: idToken)])
        let torusKey = try await singleFactoreAuth.getKey(loginParams: loginParams)

        let requiredPrivateKey = "ad47959db4cb2e63e641bac285df1b944f54d1a1cecdaeea40042b60d53c35d2"
        XCTAssertEqual(requiredPrivateKey, torusKey.getPrivateKey())
        XCTAssertEqual("0xE1155dB406dAD89DdeE9FB9EfC29C8EedC2A0C8B", torusKey.getPublicAddress())
    }
}
