import Foundation

extension WhiteLabelData {
    func merge(with other: WhiteLabelData) -> WhiteLabelData {
        return WhiteLabelData(
            appName: appName ?? other.appName,
            logoLight: logoLight ?? other.logoLight,
            logoDark: logoDark ?? other.logoDark,
            defaultLanguage: defaultLanguage ?? other.defaultLanguage,
            mode: mode ?? other.mode,
            theme: theme ?? other.theme,
            appUrl: appUrl ?? other.appUrl,
            useLogoLoader: useLogoLoader ?? other.useLogoLoader
        )
    }
}
