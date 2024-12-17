import FetchNodeDetails
import Foundation

public class Web3AuthOptions {
    var web3AuthNetwork: Web3AuthNetwork
    var clientId: String
    private var sessionTime: Int
    private var storageServerUrl: String? = nil
    private var serverTimeOffset: Int = 0
    var whiteLabel: WhiteLabelData?
    var chainConfig: ChainConfig? = nil
    var originData: [String: String]?
    var buildEnv: BuildEnv
    var redirectUrl: String?
    var walletSdkUrl: URL?

    public init(clientId: String, web3AuthNetwork: Web3AuthNetwork, sessionTime: Int = 86400, serverTimeOffset: Int? = nil, storageServerUrl: String? = nil,
                whiteLabel: WhiteLabelData? = nil, originData: [String: String]? = nil, buildEnv: BuildEnv = .production, redirectUrl: String? = nil,
                walletSdkUrl: URL? = nil) {
        self.web3AuthNetwork = web3AuthNetwork
        self.clientId = clientId
        self.sessionTime = sessionTime
        self.storageServerUrl = storageServerUrl
        if serverTimeOffset != nil {
            self.serverTimeOffset = serverTimeOffset!
        }
        self.whiteLabel = whiteLabel
        self.originData = originData
        self.buildEnv = buildEnv
        self.redirectUrl = redirectUrl
        if walletSdkUrl != nil {
            self.walletSdkUrl = walletSdkUrl
        } else {
            self.walletSdkUrl = URL(string: getWalletSdkUrl(buildEnv: self.buildEnv))
        }
        self.chainConfig = nil
    }

    public func getClientId() -> String {
        return clientId
    }

    public func getNetwork() -> Web3AuthNetwork {
        return web3AuthNetwork
    }
    
    public func getServerTimeOffset() -> Int {
        return self.serverTimeOffset
    }
    
    public func getStorageServerUrl() -> String? {
        return self.storageServerUrl
    }

    public func getSignerUrl() -> String? {
        return web3AuthNetwork.signerMap
    }

    public func setNetwork(network: Web3AuthNetwork) {
        self.web3AuthNetwork = network
    }
    
    public func getSessionTime() -> Int {
        return sessionTime
    }
    
    private enum CodingKeys: String, CodingKey {
        case web3AuthNetwork
        case clientId
        case sessionTime
        case storageServerUrl
        case serverTimeOffset
        case whiteLabel
        case chainConfig
        case originData
        case buildEnv
        case redirectUrl
        case walletSdkUrl
    }
}
