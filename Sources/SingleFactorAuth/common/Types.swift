import Foundation

public struct ChainConfig: Encodable {
    public init(chainNamespace: ChainNamespace = ChainNamespace.eip155, decimals: Int? = 18, blockExplorerUrl: String? = nil, chainId: String, displayName: String? = nil, logo: String? = nil, rpcTarget: String, ticker: String? = nil, tickerName: String? = nil) {
        self.chainNamespace = chainNamespace
        self.decimals = decimals
        self.blockExplorerUrl = blockExplorerUrl
        self.chainId = chainId
        self.displayName = displayName
        self.logo = logo
        self.rpcTarget = rpcTarget
        self.ticker = ticker
        self.tickerName = tickerName
    }

    public let chainNamespace: ChainNamespace
    public let decimals: Int?
    public let blockExplorerUrl: String?
    public let chainId: String?
    public let displayName: String?
    public let logo: String?
    public let rpcTarget: String
    public let ticker: String?
    public let tickerName: String?

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        chainNamespace = try values.decodeIfPresent(ChainNamespace.self, forKey: .chainNamespace) ?? ChainNamespace.eip155
        decimals = try values.decodeIfPresent(Int.self, forKey: .decimals) ?? 18
        blockExplorerUrl = try values.decodeIfPresent(String.self, forKey: .blockExplorerUrl)
        chainId = try values.decodeIfPresent(String.self, forKey: .chainId)
        displayName = try values.decodeIfPresent(String.self, forKey: .displayName)
        logo = try values.decodeIfPresent(String.self, forKey: .logo)
        rpcTarget = try values.decodeIfPresent(String.self, forKey: .rpcTarget) ?? ""
        ticker = try values.decodeIfPresent(String.self, forKey: .ticker)
        tickerName = try values.decodeIfPresent(String.self, forKey: .tickerName)
    }
}

public enum ChainNamespace: String, Codable {
    case eip155
    case solana
}

public struct WhiteLabelData: Encodable, Decodable {
    public init(appName: String? = nil, logoLight: String? = nil, logoDark: String? = nil, defaultLanguage: Language? = Language.en, mode: ThemeModes? = ThemeModes.auto, theme: [String: String]? = nil, appUrl: String? = nil, useLogoLoader: Bool? = false) {
        self.appName = appName
        self.logoLight = logoLight
        self.logoDark = logoDark
        self.defaultLanguage = defaultLanguage
        self.mode = mode
        self.theme = theme
        self.appUrl = appUrl
        self.useLogoLoader = useLogoLoader
    }

    let appName: String?
    let logoLight: String?
    let logoDark: String?
    let defaultLanguage: Language?
    let mode: ThemeModes?
    let theme: [String: String]?
    let appUrl: String?
    let useLogoLoader: Bool?

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        appName = try values.decodeIfPresent(String.self, forKey: .appName)
        logoLight = try values.decodeIfPresent(String.self, forKey: .logoLight)
        logoDark = try values.decodeIfPresent(String.self, forKey: .logoDark)
        defaultLanguage = try values.decodeIfPresent(Language.self, forKey: .defaultLanguage) ?? Language.en
        mode = try values.decodeIfPresent(ThemeModes.self, forKey: .mode) ?? ThemeModes.auto
        theme = try values.decodeIfPresent([String: String].self, forKey: .theme)
        appUrl = try values.decodeIfPresent(String.self, forKey: .appUrl)
        useLogoLoader = try values.decodeIfPresent(Bool.self, forKey: .useLogoLoader)
    }
}

struct WalletServicesParams {
    let options: Web3AuthOptions
    let appState: String?

    enum CodingKeys: String, CodingKey {
        case options
        case appState
    }
}

public struct SignResponse: Codable {
    public let success: Bool
    public let result: String?
    public let error: String?

    public init(success: Bool, result: String?, error: String?) {
        self.success = success
        self.result = result
        self.error = error
    }
}

struct ProjectConfigResponse: Decodable {
    let smsOtpEnabled, walletConnectEnabled: Bool
    let whitelist: Whitelist
    let whiteLabelData: WhiteLabelData?

    enum CodingKeys: String, CodingKey {
        case smsOtpEnabled = "sms_otp_enabled"
        case walletConnectEnabled = "wallet_connect_enabled"
        case whitelist
        case whiteLabelData = "whitelabel"
    }
}

struct Whitelist: Encodable, Decodable {
    let urls: [String]
    let signedUrls: [String: String]

    enum CodingKeys: String, CodingKey {
        case urls
        case signedUrls = "signed_urls"
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

