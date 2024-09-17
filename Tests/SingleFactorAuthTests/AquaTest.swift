import BigInt
import JWTKit
import XCTest
import FetchNodeDetails

@testable import SingleFactorAuth

final class AquaTest: XCTestCase {
    var singleFactoreAuth: SingleFactorAuth!
    var singleFactorAuthArgs: SFAParams!

    let TOURUS_TEST_EMAIL = "hello@tor.us"
    let TEST_VERIFIER = "torus-test-health"
    let TEST_AGGREGRATE_VERIFIER = "torus-test-health-aggregate"

    override func setUp() {
        singleFactorAuthArgs = SFAParams(web3AuthClientId: "CLIENT ID", network: .legacy(.AQUA))
        singleFactoreAuth = try! SingleFactorAuth(singleFactorAuthArgs: singleFactorAuthArgs, sessionTime: 86400)
    }

    func testConnect() async throws {
        let idToken = try generateIdToken(email: TOURUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_VERIFIER, verifierId: TOURUS_TEST_EMAIL, idToken: idToken)
        let torusKey = try await singleFactoreAuth.connect(loginParams: loginParams)

        let requiredPrivateKey = "d8204e9f8c270647294c54acd8d49ee208789f981a7503158e122527d38626d8"
        XCTAssertEqual(requiredPrivateKey, torusKey.getPrivateKey())
        XCTAssertEqual("0x8b32926cD9224fec3B296aA7250B049029434807", torusKey.getPublicAddress())
    }

    func testInitialise() async throws {
        let idToken = try generateIdToken(email: TOURUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_VERIFIER, verifierId: TOURUS_TEST_EMAIL, idToken: idToken)
        let torusKey = try await singleFactoreAuth.connect(loginParams: loginParams)
        let savedKey = try await singleFactoreAuth.initialize()
        let requiredPrivateKey = "d8204e9f8c270647294c54acd8d49ee208789f981a7503158e122527d38626d8"
        XCTAssertEqual(requiredPrivateKey, savedKey.getPrivateKey())
        XCTAssertEqual(torusKey.publicAddress, savedKey.getPublicAddress())
    }

    func testAggregrateGetTorusKey() async throws {
        let idToken = try generateIdToken(email: TOURUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_AGGREGRATE_VERIFIER, verifierId: TOURUS_TEST_EMAIL, idToken: idToken, subVerifierInfoArray: [TorusSubVerifierInfo(verifier: TEST_VERIFIER, idToken: idToken)])
        let torusKey = try await singleFactoreAuth.connect(loginParams: loginParams)

        let requiredPrivateKey = "6f8b884f19975fb0d138ed21b22a6a7e1b79e37f611d0a29f1442b34efc6bacd"
        XCTAssertEqual(requiredPrivateKey, torusKey.getPrivateKey())
        XCTAssertEqual("0x62BaCa60f48C2b2b7e3074f7B7b4795EeF2afD2e", torusKey.getPublicAddress())
    }
}
