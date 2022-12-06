import Foundation

extension Data {
    /// - Returns: an hex string.
    var hexString: String {
        map { String(format: "%02.2hhx", $0) }.joined()
    }
}
