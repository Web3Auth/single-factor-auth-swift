import BigInt
import Foundation
import TorusUtils

public struct SessionData: Codable {
    public let privateKey: String
    public let publicAddress: String
    public let signatures: [String]?
    public let userInfo: UserInfo?
    public let sessionNamespace: String

    enum CodingKeys: String, CodingKey {
        case privateKey = "privKey"
        case publicAddress
        case signatures
        case userInfo
        case sessionNamespace
    }

    init(privateKey: String, publicAddress: String, signatures: [String]? = nil, userInfo: UserInfo? = nil, sessionNamespace: String = "sfa") {
        self.privateKey = privateKey
        self.publicAddress = publicAddress
        self.signatures = signatures
        self.userInfo = userInfo
        self.sessionNamespace = sessionNamespace
    }
}
