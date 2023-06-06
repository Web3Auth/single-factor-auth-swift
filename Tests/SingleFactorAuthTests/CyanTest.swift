//
//  CyanTest.swift
//
//
//  Created by Gaurav Goel on 17/04/23.
//

import XCTest
import JWTKit
import BigInt

@testable import SingleFactorAuth

final class CyanTest: XCTestCase {

    var singleFactoreAuth: SingleFactorAuth!
    var singleFactorAuthArgs: SingleFactorAuthArgs!

    let TOURUS_TEST_EMAIL = "hello@tor.us"
    let TEST_VERIFIER = "torus-test-health"
    let TEST_AGGREGRATE_VERIFIER = "torus-test-health-aggregate"

    override func setUp() {
        singleFactorAuthArgs = SingleFactorAuthArgs(network: TorusNetwork.CYAN)
        singleFactoreAuth = SingleFactorAuth(singleFactorAuthArgs: singleFactorAuthArgs)
    }

    func testGetTorusKey() async throws {
        let idToken = try generateIdToken(email: TOURUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_VERIFIER, verifierId: TOURUS_TEST_EMAIL, idToken: idToken)
        let torusKey = try await singleFactoreAuth.getKey(loginParams: loginParams)

        let requiredPrivateKey = "44ca9a8ac5167ff11e0b48731f7bfde141fbbb0711d0abb54d5da554fb6fd40a"
        XCTAssertTrue(requiredPrivateKey == torusKey.getPrivateKey())
        XCTAssertEqual(torusKey.publicAddress, torusKey.getPublicAddress())
    }

    func testInitialise() async throws {
        let idToken = try generateIdToken(email: TOURUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_VERIFIER, verifierId: TOURUS_TEST_EMAIL, idToken: idToken)
        let torusKey = try await singleFactoreAuth.getKey(loginParams: loginParams)
        let savedKey = try await singleFactoreAuth.initialize()
        let requiredPrivateKey = "44ca9a8ac5167ff11e0b48731f7bfde141fbbb0711d0abb54d5da554fb6fd40a"
        XCTAssertTrue(requiredPrivateKey == savedKey.getPrivateKey())
        XCTAssertEqual(torusKey.publicAddress, savedKey.getPublicAddress())
    }

    func testAggregrateGetTorusKey() async throws {
        let idToken = try generateIdToken(email: TOURUS_TEST_EMAIL)
        let loginParams = LoginParams(verifier: TEST_AGGREGRATE_VERIFIER, verifierId: TOURUS_TEST_EMAIL, idToken: idToken, subVerifierInfoArray: [TorusSubVerifierInfo(verifier: TEST_VERIFIER, idToken: idToken)])
        let torusKey = try await singleFactoreAuth.getKey(loginParams: loginParams)

        let requiredPrivateKey = "66af498ea82c95d52fdb8c8dedd44cf2f758424a0eecab7ac3dd8721527ea2d4"
        XCTAssertTrue(requiredPrivateKey == torusKey.getPrivateKey())
        XCTAssertEqual(torusKey.publicAddress, torusKey.getPublicAddress())
    }
}
