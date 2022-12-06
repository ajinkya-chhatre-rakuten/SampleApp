import Foundation

/// RPushPNP Requests parameters
struct RequestParameters {
    let isMember: Bool
    let accessToken: String
    let clientIdentifier: String
    let clientSecret: String
    let deviceToken: String?
    let userIdentifier: String?
    let pushTypesFilter: [AnyHashable: Any]?
    let pushType: String?
    let registerDateStart: Date?
    let registerDateEnd: Date?
    let limit: Int?
    let paging: Int?
    let markAsRead: Bool
    let requestIdentifier: String?
    let baseURL: URL

    init(isMember: Bool,
         accessToken: String,
         clientIdentifier: String,
         clientSecret: String,
         deviceToken: String? = nil,
         userIdentifier: String? = nil,
         pushTypesFilter: [AnyHashable: Any]? = nil,
         pushType: String? = nil,
         registerDateStart: Date? = nil,
         registerDateEnd: Date? = nil,
         limit: Int? = nil,
         paging: Int? = nil,
         markAsRead: Bool = false,
         requestIdentifier: String? = nil,
         baseURL: URL) {
        self.isMember = isMember
        self.accessToken = accessToken
        self.clientIdentifier = clientIdentifier
        self.clientSecret = clientSecret
        self.deviceToken = deviceToken
        self.userIdentifier = userIdentifier
        self.pushTypesFilter = pushTypesFilter
        self.pushType = pushType
        self.registerDateStart = registerDateStart
        self.registerDateEnd = registerDateEnd
        self.limit = limit
        self.paging = paging
        self.markAsRead = markAsRead
        self.requestIdentifier = requestIdentifier
        self.baseURL = baseURL
    }
}

extension RequestParameters {
    var memberType: String { isMember ? "member" : "non-member" }
}
