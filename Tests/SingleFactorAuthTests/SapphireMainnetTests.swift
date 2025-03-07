import BigInt
import FetchNodeDetails
import JWTKit
import SingleFactorAuth
import XCTest

final class SapphireMainnetTests: XCTestCase {
    var singleFactoreAuth: SingleFactorAuth!
    var singleFactorAuthArgs: Web3AuthOptions!

    let TORUS_TEST_EMAIL = "devnettestuser@tor.us"
    let TEST_VERIFIER = "torus-test-health"
    let TEST_AGGREGRATE_VERIFIER = "torus-aggregate-sapphire-mainnet"

    override func setUp() {
        singleFactorAuthArgs = Web3AuthOptions(clientId: "CLIENT ID", web3AuthNetwork: .SAPPHIRE_MAINNET)
        singleFactoreAuth = try! SingleFactorAuth(params: singleFactorAuthArgs)
    }

    func testConnect() async throws {
        let idToken = try generateIdToken(email: TORUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_VERIFIER, verifierId: TORUS_TEST_EMAIL, idToken: idToken)
        let torusKey = try await singleFactoreAuth.connect(loginParams: loginParams)

        let requiredPrivateKey = "2c4b346a91ecd11fe8a02d111d00bd921bf9b543f0a1e811face91b5f28947d6"
        XCTAssertEqual(requiredPrivateKey, torusKey.privateKey)
        XCTAssertEqual("0x0934d844a0a6db37CF75aF0269436ae1b2Ae5D36", torusKey.publicAddress)
    }

    func testInitialise() async throws {
        let idToken = try generateIdToken(email: TORUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_VERIFIER, verifierId: TORUS_TEST_EMAIL, idToken: idToken)
        let torusKey = try await singleFactoreAuth.connect(loginParams: loginParams)
        try await singleFactoreAuth.initialize()
        let requiredPrivateKey = "2c4b346a91ecd11fe8a02d111d00bd921bf9b543f0a1e811face91b5f28947d6"
        XCTAssertEqual(requiredPrivateKey, singleFactoreAuth.getSessionData()!.privateKey)
        XCTAssertEqual(torusKey.publicAddress, singleFactoreAuth.getSessionData()!.publicAddress)
    }

    func testAggregrateGetTorusKey() async throws {
        let idToken = try generateIdToken(email: TORUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_AGGREGRATE_VERIFIER, verifierId: TORUS_TEST_EMAIL, idToken: idToken, subVerifierInfoArray: [TorusSubVerifierInfo(verifier: TEST_VERIFIER, idToken: idToken)])
        let torusKey = try await singleFactoreAuth.connect(loginParams: loginParams)

        let requiredPrivateKey = "0c724bb285560dc41e585b91aa2ded94fdd703c2e7133dcc64b1361b0d1fd105"
        XCTAssertEqual(requiredPrivateKey, torusKey.privateKey)
        XCTAssertEqual("0xA92E2C756B5b2abABc127907b02D4707dc085612", torusKey.publicAddress)
    }

    func testLogout() async throws {
        let idToken = try generateIdToken(email: TORUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_VERIFIER, verifierId: TORUS_TEST_EMAIL, idToken: idToken)
        let _ = try await singleFactoreAuth.connect(loginParams: loginParams)

        try await singleFactoreAuth.logout()
        XCTAssertNil(singleFactoreAuth.getSessionData())
    }
}
