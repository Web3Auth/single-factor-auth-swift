import BigInt
import Foundation

public class SFAKey: Codable {
    let privateKey: String
    let publicAddress: String

    init(privateKey: String, publicAddress: String) {
        self.privateKey = privateKey
        self.publicAddress = publicAddress
    }

    public func getPrivateKey() -> String {
        return privateKey
    }

    public func getPublicAddress() -> String {
        return publicAddress
    }

    func toString() -> String {
        return "TorusKey{ privateKey='\(privateKey.description)', publicAddress='\(publicAddress)' }"
    }
}
