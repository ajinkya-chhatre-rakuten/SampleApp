import Foundation

/// RPushPNP error codes
enum RPushPNPErrorCode: Int {
    case noAccessToken = 0
    case baseURLIsNil
    case accessTokenCannotBeParsed
    case noData
    case urlSessionError
    case deviceTokenIsNil
    case pushTypeCannotBeParsed
    case accessTokenIsExpired
    case accessTokenMissingParameters
}

/// RPushPNP errors
@objc public final class RPushPNPError: NSObject {
    @objc public static let domain = "jp.co.rakuten.sdk.rankutenapis"
    @objc public static var invalidToken: String { SwiftyRequesterError.invalidToken }
    @objc public static let baseURLIsNilError = NSError(domain: domain,
                                                        code: RPushPNPErrorCode.baseURLIsNil.rawValue,
                                                        userInfo: [NSLocalizedDescriptionKey: "Base URL is nil."])
}

// MARK: - RAE Error

extension RPushPNPError {
    @objc public static let noRAEAccessTokenError = NSError(domain: domain,
                                                            code: RPushPNPErrorCode.noAccessToken.rawValue,
                                                            userInfo: [NSLocalizedDescriptionKey: "No access token found. Ensure you send a valid access token with the request."])
}

// MARK: - API-C Errors

extension RPushPNPError {
    static let accessTokenCannotBeParsed = NSError(domain: domain,
                                                   code: RPushPNPErrorCode.accessTokenCannotBeParsed.rawValue,
                                                   userInfo: [NSLocalizedDescriptionKey: "The access token can't be parsed."])
    static let noData = NSError(domain: domain,
                                code: RPushPNPErrorCode.noData.rawValue,
                                userInfo: [NSLocalizedDescriptionKey: "No data."])
    static func urlSessionError(_ errorMessage: String) -> NSError {
        NSError(domain: domain,
                code: RPushPNPErrorCode.urlSessionError.rawValue,
                userInfo: [NSLocalizedDescriptionKey: errorMessage])
    }
    static func pnpError(_ errorMessage: String) -> NSError {
        NSError(domain: domain,
                code: RPushPNPErrorCode.urlSessionError.rawValue,
                userInfo: [NSLocalizedDescriptionKey: errorMessage])
    }
    static let deviceTokenIsNil = NSError(domain: domain,
                                          code: RPushPNPErrorCode.baseURLIsNil.rawValue,
                                          userInfo: [NSLocalizedDescriptionKey: "Device token is nil."])
    static let pushTypeCannotBeParsed = NSError(domain: domain,
                                                code: RPushPNPErrorCode.pushTypeCannotBeParsed.rawValue,
                                                userInfo: [NSLocalizedDescriptionKey: "The push type can't be parsed."])
    static func accessTokenIsExpired(_ error: String, message: String) -> NSError {
        NSError(domain: domain,
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: error, NSLocalizedFailureReasonErrorKey: message])
    }
    static let accessTokenMissingParameters = NSError(domain: domain,
                                                      code: RPushPNPErrorCode.accessTokenMissingParameters.rawValue,
                                                      userInfo: [NSLocalizedDescriptionKey: "Access token missing parameters."])
}
