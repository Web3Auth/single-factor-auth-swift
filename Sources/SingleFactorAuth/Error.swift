import Foundation

public enum SFAError: Error, Equatable {
    case MFAAlreadyEnabled
}

extension SFAError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .MFAAlreadyEnabled:
            return "User has already enabled MFA"
        }
    }
}
