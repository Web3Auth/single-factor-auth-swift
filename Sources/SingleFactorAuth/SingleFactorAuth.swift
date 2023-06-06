import FetchNodeDetails
import TorusUtils
import Combine
import CryptoSwift
import Foundation
import BigInt
import SessionManager

open class SingleFactorAuth {
    let nodeDetailManager: FetchNodeDetails
    let torusUtils: TorusUtils
    private var sessionManager:SessionManager
    
    init(singleFactorAuthArgs: SingleFactorAuthArgs) {
        sessionManager = .init()
        self.nodeDetailManager = FetchNodeDetails(proxyAddress: singleFactorAuthArgs.getNetworkUrl()!, network: singleFactorAuthArgs.getNetwork())
        self.torusUtils = TorusUtils(
            enableOneKey: true,
            signerHost: singleFactorAuthArgs.getSignerUrl()! + "/api/sign",
            allowHost: singleFactorAuthArgs.getSignerUrl()! + "/api/allow",
            network: singleFactorAuthArgs.getNetwork()
        )
    }
    
    func initialize() async throws -> TorusKey{
            let data = try await sessionManager.authorizeSession()
            guard let privKey = data["privateKey"] as? BigInt,
                  let publicAddress = data["publicAddress"] as? String else{ throw SessionManagerError.decodingError}
        return .init(privateKey: privKey, publicAddress: publicAddress)
    }

    func getKey(loginParams: LoginParams) async throws -> TorusKey {
        var retrieveSharesResponse: [String: String] = [:];
        
        do {
            var details = try await self.nodeDetailManager.getNodeDetails(verifier: loginParams.verifier, verifierID: loginParams.verifierId)
            
            let pubDetails = try await self.torusUtils.getPublicAddress(
                    endpoints: details.getTorusNodeEndpoints(),
                    torusNodePubs: details.getTorusNodePub(),
                    verifier: loginParams.verifier,
                    verifierId: loginParams.verifierId,
                    isExtended: true)
        
            if pubDetails.typeOfUser == .v1 {
                if let x = pubDetails.x, let y = pubDetails.y {
                    let d = try await torusUtils.getOrSetNonce(x: x, y: y)
                    if d.upgraded == true {
                        throw "User already havee enabled MFA"
                    }
                }
            }
            
            if let subVerifierInfoArray = loginParams.subVerifierInfoArray, !subVerifierInfoArray.isEmpty {
                var aggregateIdTokenSeeds = [String]()
                var subVerifierIds = [String]()
                var verifyParams = [Any]()
                
                for (i, _) in subVerifierInfoArray.enumerated() {
                    aggregateIdTokenSeeds.append(subVerifierInfoArray[i].idToken);
                    
                    var verifyParam: [String: Any] = [:]
                    verifyParam["verifier_id"] = loginParams.verifierId
                    verifyParam["idToken"] = subVerifierInfoArray[i].idToken
                    
                    verifyParams.append(verifyParam)
                    subVerifierIds.append(subVerifierInfoArray[i].verifier)
                }
                
                let aggregateIdToken = String(aggregateIdTokenSeeds.joined(separator: " ").sha3(.keccak256))
                
                let extraParams = [
                    "verifier_id": loginParams.verifierId,
                    "sub_verifier_ids": subVerifierIds,
                    "verify_params": verifyParams
                ] as [String: Any]
                let buffer: Data = try! NSKeyedArchiver.archivedData(withRootObject: extraParams, requiringSecureCoding: false)

                details = try await self.nodeDetailManager.getNodeDetails(verifier: loginParams.verifier, verifierID: loginParams.verifierId)
                
                retrieveSharesResponse = try await torusUtils.retrieveShares(
                    torusNodePubs: details.getTorusNodePub(),
                    endpoints: details.getTorusNodeEndpoints(),
                    verifier: loginParams.verifier,
                    verifierId: loginParams.verifierId,
                    idToken: aggregateIdToken,
                    extraParams: buffer
                )
            } else {
                let extraParams = ["verifier_id": loginParams.verifierId] as [String: Any]
                let buffer: Data = try! NSKeyedArchiver.archivedData(withRootObject: extraParams, requiringSecureCoding: false)
                
                retrieveSharesResponse = try await self.torusUtils.retrieveShares(
                    torusNodePubs: details.getTorusNodePub(),
                    endpoints: details.getTorusNodeEndpoints(),
                    verifier: loginParams.verifier,
                    verifierId: loginParams.verifierId,
                    idToken: loginParams.idToken,
                    extraParams: buffer
                )
            }
            if retrieveSharesResponse["privateKey"] == nil {
                throw "Unable to generate privKey"
            }
            
        } catch {
            throw error
        }
        
        let torusKey = TorusKey(privateKey: BigInt(retrieveSharesResponse["privateKey"]!, radix: 16)!, publicAddress: retrieveSharesResponse["publicAddress"]!)
        try await sessionManager.createSession(data: torusKey)
        return torusKey;
    }
}
