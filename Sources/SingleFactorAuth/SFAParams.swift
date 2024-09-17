import FetchNodeDetails

public typealias Web3AuthNetwork = TorusNetwork

public class SFAParams{
    private var network: TorusNetwork
    private var networkUrl: String
    private var web3AuthClientId: String
    private var sessionTime: Int

    public init(web3AuthClientId: String, network: Web3AuthNetwork, sessionTime: Int = 86400, networkUrl: String = "") {
        self.network = network
        self.networkUrl = networkUrl
        self.web3AuthClientId = web3AuthClientId
        self.sessionTime = sessionTime
    }

    public func getWeb3AuthClientId() -> String {
        return web3AuthClientId
    }

    public func getNetwork() -> Web3AuthNetwork {
        return network
    }

    public func getSignerUrl() -> String? {
        return network.signerMap
    }

    public func setNetwork(network: Web3AuthNetwork) {
        self.network = network
    }
    
    public func getSessionTime() -> Int {
        return sessionTime
    }
}
