import Foundation
import BigInt

public class TorusKey: Codable {
    let privateKey: String
    let publicAddress: String

    init(privateKey: String, publicAddress: String) {
        self.privateKey = privateKey
        self.publicAddress = publicAddress
    }

    public func getPrivateKey() -> String {
        return privateKey
    }

    func getPublicAddress() -> String {
        return publicAddress
    }

    func toString() -> String {
        return "TorusKey{ privateKey='\(privateKey.description)', publicAddress='\(publicAddress)' }"
    }
}
