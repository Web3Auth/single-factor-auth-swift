import CommonSources
import FetchNodeDetails
import TorusUtils

public class SingleFactorAuthArgs {
    public static let SIGNER_MAP: [TorusNetwork: String] = [
        TorusNetwork.legacy(LegacyNetwork.MAINNET): "https://signer.tor.us",
        TorusNetwork.legacy(LegacyNetwork.TESTNET): "https://signer.tor.us",
        TorusNetwork.legacy(LegacyNetwork.CYAN): "https://signer-polygon.tor.us",
        TorusNetwork.legacy(LegacyNetwork.AQUA): "https://signer-polygon.tor.us",
    ]

    private var network: TorusNetwork
    private var networkUrl: String

    public init(network: TorusNetwork, networkUrl: String = "") {
        self.network = network
        self.networkUrl = networkUrl
    }

    public func getNetwork() -> TorusNetwork {
        switch network {
        case .legacy(LegacyNetwork.MAINNET):
            return TorusNetwork.legacy(LegacyNetwork.MAINNET)
        case .legacy(LegacyNetwork.TESTNET):
            return TorusNetwork.legacy(LegacyNetwork.TESTNET)
        case .legacy(LegacyNetwork.CYAN):
            return TorusNetwork.legacy(LegacyNetwork.CYAN)
        case .legacy(LegacyNetwork.AQUA):
            return TorusNetwork.legacy(LegacyNetwork.AQUA)
        case .legacy(LegacyNetwork.CELESTE):
            return TorusNetwork.legacy(LegacyNetwork.CELESTE)
        case let .legacy(.CUSTOM(path: path)):
            return TorusNetwork.legacy(.CUSTOM(path: path))
        case .sapphire(.SAPPHIRE_DEVNET):
            return TorusNetwork.sapphire(.SAPPHIRE_DEVNET)
        case .sapphire(.SAPPHIRE_MAINNET):
            return TorusNetwork.sapphire(.SAPPHIRE_MAINNET)
        }
    }

    public func getSignerUrl() -> String? {
        return SingleFactorAuthArgs.SIGNER_MAP[network]
    }

    public func setNetwork(network: TorusNetwork) {
        self.network = network
    }
    /*
     public func getNetworkUrl() -> String? {
         if self.networkUrl.isEmpty {
             return SingleFactorAuthArgs.CONTRACT_MAP[self.network]
         } else {
             return self.networkUrl
         }
     }

     public func setNetworkUrl(networkUrl: String) {
         self.networkUrl = networkUrl
     }
     */
}
