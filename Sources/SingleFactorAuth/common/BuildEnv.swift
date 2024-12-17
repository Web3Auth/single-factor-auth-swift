import Foundation

public enum BuildEnv: String, Encodable {
    case production
    case staging
    case testing
}
