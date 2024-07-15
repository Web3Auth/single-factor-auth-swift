import Foundation

internal extension Data {
    var bytes: Array<UInt8> {
        Array(self)
    }

    func toHexString() -> String {
        bytes.toHexString()
    }
}
