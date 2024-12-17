import Foundation

public enum SFAError: Error, Equatable {
    case MFAAlreadyEnabled
    case runtimeError(String)
    case encodingError
}

extension SFAError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .runtimeError(msg):
            return msg
        case .encodingError:
            return "Encoding error"
        case .MFAAlreadyEnabled:
            return "User has already enabled MFA"
        }
    }
}
