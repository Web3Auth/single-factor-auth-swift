import CommonSources
import FetchNodeDetails
import TorusUtils

public class SingleFactorAuthArgs {
    public static let SIGNER_MAP: [Web3AuthNetwork: String] = [
        Web3AuthNetwork.SAPPHIRE_MAINNET: "https://signer.tor.us",
        Web3AuthNetwork.SAPPHIRE_DEVNET: "https://signer.tor.us",
        Web3AuthNetwork.MAINNET: "https://signer.tor.us",
        Web3AuthNetwork.TESTNET: "https://signer.tor.us",
        Web3AuthNetwork.CYAN: "https://signer-polygon.tor.us",
        Web3AuthNetwork.AQUA: "https://signer-polygon.tor.us",
    ]

    private var network: Web3AuthNetwork
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
        return SingleFactorAuthArgs.SIGNER_MAP[network]
    }

    public func setNetwork(network: Web3AuthNetwork) {
        self.network = network
    }
}

public enum Web3AuthNetwork : Equatable, Hashable {
    case SAPPHIRE_DEVNET
    case SAPPHIRE_MAINNET
    case MAINNET
    case TESTNET
    case CYAN
    case AQUA
    case CELESTE
    case CUSTOM(path: String)
    
    public var path: String {
        return self.network.path
    }
    
    public var name: String {
        return self.network.name
    }
    
    public var network: TorusNetwork {
        switch self {
        case .SAPPHIRE_DEVNET:
            return .sapphire(.SAPPHIRE_DEVNET)
        case .SAPPHIRE_MAINNET:
            return .sapphire(.SAPPHIRE_MAINNET)
        case .MAINNET:
            return .legacy(.MAINNET)
        case .TESTNET:
            return .legacy(.TESTNET)
        case .CYAN:
            return .legacy(.CYAN)
        case .AQUA:
            return .legacy(.AQUA)
        case .CELESTE:
            return .legacy(.CELESTE)
        case .CUSTOM(path: let path):
            return .legacy(.CUSTOM(path: path))
        }
    }
}
