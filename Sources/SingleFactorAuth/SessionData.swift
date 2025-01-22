import BigInt
import Foundation
import TorusUtils

public class SessionData: Codable {
    let privateKey: String
    let publicAddress: String
    let signatures: [String]?
    let userInfo: UserInfo?

    init(privateKey: String, publicAddress: String, signatures: [String]? = nil, userInfo: UserInfo? = nil) {
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
    
    public func getSignatures() -> [String]? {
        return self.signatures
    }
    
    enum CodingKeys: String, CodingKey {
        case privateKey = "privKey"
        case publicAddress
        case signatures
        case userInfo
        case sessionNamespace
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        privateKey = try container.decode(String.self, forKey: .privateKey)
        publicAddress = try container.decode(String.self, forKey: .publicAddress)
        signatures = try container.decodeIfPresent([String].self, forKey: .signatures)
        userInfo = try container.decodeIfPresent(UserInfo.self, forKey: .userInfo)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(privateKey, forKey: .privateKey)
        try container.encode(publicAddress, forKey: .publicAddress)
        try container.encodeIfPresent(signatures, forKey: .signatures)
        try container.encodeIfPresent(userInfo, forKey: .userInfo)
    }
}
