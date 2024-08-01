import FetchNodeDetails

public typealias Web3AuthNetwork = TorusNetwork

public class SingleFactorAuthArgs {
    private var network: TorusNetwork
    private var networkUrl: String
    private var web3AuthClientId: String

    public init(web3AuthClientId: String, network: Web3AuthNetwork, networkUrl: String = "") {
        self.network = network
        self.networkUrl = networkUrl
        self.web3AuthClientId = web3AuthClientId
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
}
