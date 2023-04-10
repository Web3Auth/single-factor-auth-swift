import FetchNodeDetails
import Foundation

public class SingleFactorAuthArgs {
    public static let CONTRACT_MAP: [TorusNetwork: String] = [
        .MAINNET: FetchNodeDetails.PROXY_ADDRESS_MAINNET,
        .TESTNET: FetchNodeDetails.PROXY_ADDRESS_TESTNET,
        .CYAN: FetchNodeDetails.PROXY_ADDRESS_CYAN,
        .AQUA: FetchNodeDetails.PROXY_ADDRESS_AQUA
    ]
    public static let SIGNER_MAP: [TorusNetwork: String] = [
        .MAINNET: "https://signer.tor.us",
        .TESTNET: "https://signer.tor.us",
        .CYAN: "https://signer-polygon.tor.us",
        .AQUA: "https://signer-polygon.tor.us"
    ]
    private var network: TorusNetwork
    private var networkUrl: String?
    
    public init(network: TorusNetwork) {
        self.network = network
    }
    
    public func getNetwork() -> TorusNetwork {
        return network
    }
    
    public func setNetwork(network: TorusNetwork) {
        self.network = network
    }
    
    public func getNetworkUrl() -> String? {
        return networkUrl
    }
    
    public func setNetworkUrl(networkUrl: String) {
        self.networkUrl = networkUrl
    }
}
