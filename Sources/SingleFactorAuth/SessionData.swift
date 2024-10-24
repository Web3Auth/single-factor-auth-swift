import BigInt
import Foundation
import TorusUtils

public class SessionData: Codable {
    let privateKey: String
    let publicAddress: String
    let signatures: TorusKey.SessionData?
    let userInfo: UserInfo?

    init(privateKey: String, publicAddress: String, signatures: TorusKey.SessionData? = nil, userInfo: UserInfo? = nil) {
        self.privateKey = privateKey
        self.publicAddress = publicAddress
        self.signatures = signatures
        self.userInfo = userInfo
    }

    public func getPrivateKey() -> String {
        return privateKey
    }

    public func getPublicAddress() -> String {
        return publicAddress
    }
    
    public func getUserInfo() -> UserInfo? {
        return userInfo
    }
    
    public func getSignatures() -> TorusKey.SessionData? {
        return self.signatures
    }
}
