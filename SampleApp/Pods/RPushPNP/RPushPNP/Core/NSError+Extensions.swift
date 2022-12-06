import Foundation

extension NSError {
    @objc public var isInvalidTokenError: Bool {
        localizedDescription == RPushPNPError.invalidToken
    }
}
