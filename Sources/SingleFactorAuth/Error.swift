import Foundation

public enum SFAError: Error, Equatable {
    case MFAAlreadyEnabled
    case runtimeError(String)
    case encodingError
}

extension SFAError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .MFAAlreadyEnabled:
            return "User has already enabled MFA"
        case let .runtimeError(msg):
            return "Runtime error \(msg)"
        case .encodingError:
            return "Encoding Error"
        }
    }
}
