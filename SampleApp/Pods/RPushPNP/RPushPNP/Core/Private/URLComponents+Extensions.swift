import Foundation

extension URLComponents {
    /// Create a new URLComponents.
    /// - Parameters:
    ///     - queryItems: the query items.
    init(queryItems: [URLQueryItem]) {
        self.init()
        self.queryItems = queryItems
    }
}

extension URLComponents {
    private enum ItemKeys {
        static let pnpClientId = "pnpClientId"
        static let pnpClientSecret = "pnpClientSecret"
        static let deviceId = "deviceId"
        static let userid = "userid"
        static let responseFormat = "responseFormat"
        static let grantType = "grant_type"
        static let pushType = "pushtype"
        static let registerDateStart = "registerDateStart"
        static let registerDateEnd = "registerDateEnd"
        static let limit = "limit"
        static let paging = "paging"
        static let requestId = "requestId"
    }
    mutating func addPnpClientId(_ pnpClientId: String) {
        queryItems?.append(URLQueryItem(name: ItemKeys.pnpClientId, value: pnpClientId))
    }
    mutating func addPnpClientSecret(_ pnpClientSecret: String) {
        queryItems?.append(URLQueryItem(name: ItemKeys.pnpClientSecret, value: pnpClientSecret))
    }
    mutating func addDeviceId(_ deviceId: String) {
        queryItems?.append(URLQueryItem(name: ItemKeys.deviceId, value: deviceId))
    }
    mutating func addUserid(_ userid: String) {
        queryItems?.append(URLQueryItem(name: ItemKeys.userid, value: userid))
    }
    mutating func addRequestId(_ requestId: String) {
        queryItems?.append(URLQueryItem(name: ItemKeys.requestId, value: requestId))
    }
    mutating func addPushTypesFilter(_ pushTypesFilter: [AnyHashable: Any]) {
        let value = pushTypesFilter.map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
        queryItems?.append(URLQueryItem(name: ItemKeys.pushType, value: value))
    }
    mutating func addPushType(_ pushType: String) {
        queryItems?.append(URLQueryItem(name: ItemKeys.pushType, value: pushType))
    }
    mutating func addRegisterDateStart(_ registerDateStart: Date) {
        queryItems?.append(URLQueryItem(name: ItemKeys.registerDateStart, value: (registerDateStart as NSDate).toISO8601String))
    }
    mutating func addRegisterDateEnd(_ registerDateEnd: Date) {
        queryItems?.append(URLQueryItem(name: ItemKeys.registerDateEnd, value: (registerDateEnd as NSDate).toISO8601String))
    }
    mutating func addLimit(_ limit: Int) {
        queryItems?.append(URLQueryItem(name: ItemKeys.limit, value: "\(limit)"))
    }
    mutating func addPaging(_ paging: Int) {
        queryItems?.append(URLQueryItem(name: ItemKeys.paging, value: "\(paging)"))
    }
    mutating func addGrantType() {
        queryItems?.append(URLQueryItem(name: ItemKeys.grantType, value: "client_credentials"))
    }
    mutating func addResponseJson() {
        queryItems?.append(URLQueryItem(name: ItemKeys.responseFormat, value: "json"))
    }
}

extension URLComponents {
    /// - Returns: the query items converted  to `Data`.
    var toData: Data? { query?.data(using: .utf8) }
}
