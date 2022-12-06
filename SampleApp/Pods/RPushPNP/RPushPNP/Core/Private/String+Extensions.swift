import Foundation

extension String {
    /// Encode a String to Base64.
    ///
    /// - Returns: the  Base64 encoded string.
    var toBase64: String { Data(utf8).base64EncodedString() }
}
