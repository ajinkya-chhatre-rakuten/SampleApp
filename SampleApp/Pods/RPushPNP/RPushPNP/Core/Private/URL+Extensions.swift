import Foundation

extension URL {
    /// Create a new URL.
    ///
    /// - Parameters:
    ///     - baseURL: the base URL.
    ///     - memberType: the member type.
    ///     - path: the path.
    init(baseURL: URL, memberType: String, path: String) {
        var mutableBaseURL = baseURL
        mutableBaseURL.appendPathComponent("pnp/\(memberType)/\(path)")
        self = mutableBaseURL
    }

    /// Create a new URL.
    ///
    /// - Parameters:
    ///     - parameters: the request parameters.
    ///     - path: the path.
    ///
    /// - Throws: an error if `baseURL` or `deviceToken` is nil.
    init(_ parameters: RequestParameters, path: String) throws {
        guard parameters.deviceToken != nil else { throw RPushPNPError.deviceTokenIsNil }
        self.init(baseURL: parameters.baseURL, memberType: parameters.memberType, path: path)
    }
}
