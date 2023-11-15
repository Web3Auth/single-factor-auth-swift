import CommonSources
import FetchNodeDetails
import TorusUtils

public class SingleFactorAuthArgs {
    public static let SIGNER_MAP: [TorusNetwork: String] = [
        TorusNetwork.sapphire(SapphireNetwork.SAPPHIRE_MAINNET): "https://signer.tor.us",
        TorusNetwork.sapphire(SapphireNetwork.SAPPHIRE_DEVNET): "https://signer.tor.us",
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
        return network
    }

    public func getSignerUrl() -> String? {
        return SingleFactorAuthArgs.SIGNER_MAP[network]
    }

    public func setNetwork(network: TorusNetwork) {
        self.network = network
    }
}
