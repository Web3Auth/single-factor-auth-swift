import FetchNodeDetails

public class Web3AuthOptions {
    private var web3AuthNetwork: Web3AuthNetwork
    private var clientId: String
    private var sessionTime: Int
    private var storageServerUrl: String? = nil
    private var serverTimeOffset: Int = 0
    var whitelLabelData: WhiteLabelData? = nil
    var originData: [String: String]?
    var buildEnv: BuildEnv = .production
    var redirectUrl: String?
    var walletSdkUrl: String?
    var chainConfig: ChainConfig? = nil

    public init(clientId: String, web3AuthNetwork: Web3AuthNetwork, sessionTime: Int = 86400, serverTimeOffset: Int? = nil, storageServerUrl: String? = nil,
                whitelabelData: WhiteLabelData? = nil, originData: [String: String]? = nil,
                buildEnv: BuildEnv = .production,
                redirectUrl: String? = nil,
                walletSdkUrl: String? = nil) {
        self.web3AuthNetwork = web3AuthNetwork
        self.clientId = clientId
        self.sessionTime = sessionTime
        self.storageServerUrl = storageServerUrl
        if serverTimeOffset != nil {
            self.serverTimeOffset = serverTimeOffset!
        }
        self.whitelLabelData = whitelabelData
        self.originData = originData
        self.buildEnv = buildEnv
        self.redirectUrl = redirectUrl
        self.walletSdkUrl = walletSdkUrl ?? getWalletSdkUrl(buildEnv: buildEnv)
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
}

public func getWalletSdkUrl(buildEnv: BuildEnv?) -> String {
    let walletServicesVersion = "v3"
    guard let buildEnv = buildEnv else {
        return "https://wallet.web3auth.io"
    }

    switch buildEnv {
    case .staging:
        return "https://staging-wallet.web3auth.io/\(walletServicesVersion)"
    case .testing:
        return "https://develop-wallet.web3auth.io"
    default:
        return "https://wallet.web3auth.io/\(walletServicesVersion)"
    }
}
