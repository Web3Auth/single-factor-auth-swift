import FetchNodeDetails

public class Web3AuthOptions: Codable {
    private var web3AuthNetwork: Web3AuthNetwork
    private var clientId: String
    private var sessionTime: Int
    private var storageServerUrl: String? = nil
    private var serverTimeOffset: Int = 0
    var whiteLabel: WhiteLabelData? = nil
    var originData: [String: String]?
    var buildEnv: BuildEnv = .production
    var redirectUrl: String?
    var walletSdkUrl: String?
    var chainConfig: ChainConfig? = nil

    public init(clientId: String, web3AuthNetwork: Web3AuthNetwork, sessionTime: Int = 86400, serverTimeOffset: Int? = nil, storageServerUrl: String? = nil,
                whiteLabel: WhiteLabelData? = nil, originData: [String: String]? = nil,
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
        self.whiteLabel = whiteLabel
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
    
    enum CodingKeys: String, CodingKey {
        case network
        case clientId
        case sessionTime
        case storageServerUrl
        case serverTimeOffset
        case whiteLabel
        case originData
        case buildEnv
        case redirectUrl
        case walletSdkUrl
        case chainConfig
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let networkString = try container.decode(String.self, forKey: .network)
        self.web3AuthNetwork = try Web3AuthNetwork(from: networkString as! Decoder) // Handle default case
        self.clientId = try container.decode(String.self, forKey: .clientId)
        self.sessionTime = try container.decode(Int.self, forKey: .sessionTime)
        self.storageServerUrl = try container.decodeIfPresent(String.self, forKey: .storageServerUrl)
        self.serverTimeOffset = try container.decodeIfPresent(Int.self, forKey: .serverTimeOffset) ?? 0
        self.whiteLabel = try container.decodeIfPresent(WhiteLabelData.self, forKey: .whiteLabel)
        self.originData = try container.decodeIfPresent([String: String].self, forKey: .originData)
        self.buildEnv = try container.decode(BuildEnv.self, forKey: .buildEnv)
        self.redirectUrl = try container.decodeIfPresent(String.self, forKey: .redirectUrl)
        self.walletSdkUrl = try container.decodeIfPresent(String.self, forKey: .walletSdkUrl)
        self.chainConfig = try container.decodeIfPresent(ChainConfig.self, forKey: .chainConfig)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(web3AuthNetwork.name, forKey: .network)
        try container.encode(clientId, forKey: .clientId)
        try container.encode(sessionTime, forKey: .sessionTime)
        try container.encodeIfPresent(storageServerUrl, forKey: .storageServerUrl)
        try container.encode(serverTimeOffset, forKey: .serverTimeOffset)
        try container.encodeIfPresent(whiteLabel, forKey: .whiteLabel)
        try container.encodeIfPresent(originData, forKey: .originData)
        try container.encode(buildEnv, forKey: .buildEnv)
        try container.encodeIfPresent(redirectUrl, forKey: .redirectUrl)
        try container.encodeIfPresent(walletSdkUrl, forKey: .walletSdkUrl)
        try container.encodeIfPresent(chainConfig, forKey: .chainConfig)
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
