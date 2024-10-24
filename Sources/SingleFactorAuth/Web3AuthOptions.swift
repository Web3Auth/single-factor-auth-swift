import FetchNodeDetails

public class Web3AuthOptions {
    private var web3AuthNetwork: Web3AuthNetwork
    private var clientId: String
    private var sessionTime: Int
    private var storageServerUrl: String? = nil
    private var serverTimeOffset: Int = 0

    public init(clientId: String, web3AuthNetwork: Web3AuthNetwork, sessionTime: Int = 86400, serverTimeOffset: Int? = nil, storageServerUrl: String? = nil) {
        self.web3AuthNetwork = web3AuthNetwork
        self.clientId = clientId
        self.sessionTime = sessionTime
        self.storageServerUrl = storageServerUrl
        if serverTimeOffset != nil {
            self.serverTimeOffset = serverTimeOffset!
        }
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
