import Foundation

/// RPushPNP Requests
enum RequestBuilder {
    enum Path {
        static let nonMemberAccessToken = "register-ios/oauth2/token"
        static let memberAccessToken = "register-ios/access_token"
        static let register = "register-ios/api/register/ios"
        static let unregister = "unregister-ios/api/unregister/ios"
        static let getDenyType = "check-denytype-ios/api/denytype/ios"
        static let setDenyType = "update-denytype-ios/api/denytype/ios"
        static let getPushedHistory = "check-pushed-history/api/history/client"
        static let getUnreadCount = "check-pushhistory-unreadcount/api/history/unreadcount"
        static let setHistoryStatusRead = "set-pushhistory-status/api/history/status/read"
        static let setHistoryStatusUnread = "set-pushhistory-status/api/history/status/unread"
    }
    enum MemberType {
        static let nonMember = "non-member"
        static let member = "member"
    }
    enum NonMember {
        /// Create the API-C non-member access token URL request or return nil.
        ///
        /// - Parameters:
        ///     - token: the anonymous token.
        ///
        /// - Returns: the API-C non-member access token URL request or nil.
        static func accessToken(token: String,
                                baseURL: URL) -> URLRequest {
            let url = URL(baseURL: baseURL, memberType: MemberType.nonMember, path: Path.nonMemberAccessToken)
            var components = URLComponents(queryItems: [])
            components.addGrantType()
            return URLRequest(url: url,
                              httpMethod: HTTPMethod.POST.rawValue,
                              httpBody: components.toData,
                              accessToken: token)
        }
    }
    enum Member {
        /// Create the API-C member access token URL request or return nil.
        ///
        /// - Parameters:
        ///     - token: the exchange token.
        ///
        /// - Returns: the API-C member access token URL request or nil.
        static func accessToken(token: String,
                                baseURL: URL) -> URLRequest {
            let url = URL(baseURL: baseURL, memberType: MemberType.member, path: Path.memberAccessToken)
            return URLRequest(url: url,
                              httpMethod: HTTPMethod.POST.rawValue,
                              accessToken: token)
        }
    }
    enum Common {
        /// Create the API-C register URL request or throw an error.
        /// - Parameters:
        ///     - parameters: the register request parameters.
        ///
        /// - Returns: the API-C register URL request.
        ///
        /// - Throws: an error if `baseURL` or `deviceToken` is nil.
        static func register(_ parameters: RequestParameters) throws -> URLRequest {
            try URLRequest(url: URL(parameters, path: Path.register), httpMethod: .POST, parameters: parameters)
        }

        /// Create the API-C unregister URL request or throw an error.
        /// - Parameters:
        ///     - parameters: the unregister request parameters.
        ///
        /// - Returns: the API-C unregister URL request.
        ///
        /// - Throws: an error if `baseURL` or `deviceToken` is nil.
        static func unregister(_ parameters: RequestParameters) throws -> URLRequest {
            try URLRequest(url: URL(parameters, path: Path.unregister), httpMethod: .POST, parameters: parameters)
        }

        /// Create the API-C getDenyType URL request or throw an error.
        /// - Parameters:
        ///     - parameters: the getDenyType request parameters.
        ///
        /// - Returns: the API-C getDenyType URL request.
        ///
        /// - Throws: an error if `baseURL` or `deviceToken` is nil.
        static func getDenyType(_ parameters: RequestParameters) throws -> URLRequest {
            try URLRequest(url: URL(parameters, path: Path.getDenyType), httpMethod: .GET, parameters: parameters)
        }

        /// Create the API-C setDenyType URL request or throw an error.
        /// - Parameters:
        ///     - parameters: the setDenyType request parameters.
        ///
        /// - Returns: the API-C setDenyType URL request.
        ///
        /// - Throws: an error if `baseURL` or `deviceToken` is nil.
        static func setDenyType(_ parameters: RequestParameters) throws -> URLRequest {
            try URLRequest(url: URL(parameters, path: Path.setDenyType), httpMethod: .POST, parameters: parameters)
        }

        /// Create the API-C getPushedHistory URL request or throw an error.
        /// - Parameters:
        ///     - parameters: the getPushedHistory request parameters.
        ///
        /// - Returns: the API-C getPushedHistory URL request.
        ///
        /// - Throws: an error if `baseURL` or `deviceToken` is nil.
        static func getPushedHistory(_ parameters: RequestParameters) throws -> URLRequest {
            try URLRequest(url: URL(parameters, path: Path.getPushedHistory), httpMethod: .GET, parameters: parameters)
        }

        /// Create the API-C getUnreadCount URL request or throw an error.
        /// - Parameters:
        ///     - parameters: the getUnreadCount request parameters.
        ///
        /// - Returns: the API-C getUnreadCount URL request.
        ///
        /// - Throws: an error if `baseURL` or `deviceToken` is nil.
        static func getUnreadCount(_ parameters: RequestParameters) throws -> URLRequest {
            try URLRequest(url: URL(parameters, path: Path.getUnreadCount), httpMethod: .GET, parameters: parameters)
        }

        /// Create the API-C setHistoryStatus URL request or throw an error.
        /// - Parameters:
        ///     - parameters: the setHistoryStatus request parameters.
        ///
        /// - Returns: the API-C setHistoryStatus URL request.
        ///
        /// - Throws: an error if `baseURL` or `deviceToken` is nil.
        static func setHistoryStatus(_ parameters: RequestParameters) throws -> URLRequest {
            try URLRequest(url: URL(parameters, path: parameters.markAsRead ? Path.setHistoryStatusRead : Path.setHistoryStatusUnread),
                           httpMethod: .POST, parameters: parameters)
        }
    }
}
