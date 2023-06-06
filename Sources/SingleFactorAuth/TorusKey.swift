import Foundation
import BigInt

class TorusKey:Codable{
    let privateKey: BigInt
    let publicAddress: String
    
    init(privateKey: BigInt, publicAddress: String) {
        self.privateKey = privateKey
        self.publicAddress = publicAddress
    }
    
    func getPrivateKey() -> BigInt {
        return privateKey
    }
    
    func getPublicAddress() -> String {
        return publicAddress
    }
    
    func toString() -> String {
        return "TorusKey{ privateKey='\(privateKey.description)', publicAddress='\(publicAddress)' }"
    }
}
