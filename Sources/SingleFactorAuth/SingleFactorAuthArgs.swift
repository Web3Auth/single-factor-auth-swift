import FetchNodeDetails
import TorusUtils

public enum TorusNetwork {
    case MAINNET
    case TESTNET
    case CYAN
    case AQUA
    case CELESTE
}

public class SingleFactorAuthArgs {
    public static let CONTRACT_MAP: [TorusNetwork: String] = [
        .MAINNET: FetchNodeDetails.proxyAddressMainnet,
        .TESTNET: FetchNodeDetails.proxyAddressTestnet,
        .CYAN: FetchNodeDetails.proxyAddressCyan,
        .AQUA: FetchNodeDetails.proxyAddressAqua
    ]
    
    public static let SIGNER_MAP: [TorusNetwork: String] = [
        .MAINNET: "https://signer.tor.us",
        .TESTNET: "https://signer.tor.us",
        .CYAN: "https://signer-polygon.tor.us",
        .AQUA: "https://signer-polygon.tor.us"
    ]
    
    private var network: TorusNetwork
    private var networkUrl: String
    
    public init(network: TorusNetwork, networkUrl: String = "") {
        self.network = network
        self.networkUrl = networkUrl
    }
    
    public func getNetwork() -> EthereumNetworkFND {
        switch network {
        case .MAINNET:
            return EthereumNetworkFND.MAINNET
        case .TESTNET:
            return EthereumNetworkFND.TESTNET
        case .CYAN:
            return EthereumNetworkFND.CYAN
        case .AQUA:
            return EthereumNetworkFND.AQUA
        default:
            return EthereumNetworkFND.MAINNET
        }
    }
    
    public func getSignerUrl() -> String? {
        return SingleFactorAuthArgs.SIGNER_MAP[self.network];
    }
    
    public func setNetwork(network: TorusNetwork) {
        self.network = network
    }
    
    public func getNetworkUrl() -> String? {
        if (self.networkUrl.isEmpty) {
            return SingleFactorAuthArgs.CONTRACT_MAP[self.network];
        } else {
            return self.networkUrl;
        }
    }
    
    public func setNetworkUrl(networkUrl: String) {
        self.networkUrl = networkUrl;
    }
}
