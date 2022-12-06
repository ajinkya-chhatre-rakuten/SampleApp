import Foundation

protocol RequestParameterizable {
    func toRequestParameters(isMember: Bool, baseURL: URL) -> RequestParameters
}

extension RPushPNPRegisterDeviceRequest: RequestParameterizable {
    func toRequestParameters(isMember: Bool, baseURL: URL) -> RequestParameters {
        RequestParameters(isMember: isMember,
                          accessToken: accessToken,
                          clientIdentifier: pnpClientIdentifier,
                          clientSecret: pnpClientSecret,
                          deviceToken: deviceToken?.hexString,
                          userIdentifier: userIdentifier,
                          baseURL: baseURL)
    }
}

extension RPushPNPUnregisterDeviceRequest: RequestParameterizable {
    func toRequestParameters(isMember: Bool, baseURL: URL) -> RequestParameters {
        RequestParameters(isMember: isMember,
                          accessToken: accessToken,
                          clientIdentifier: pnpClientIdentifier,
                          clientSecret: pnpClientSecret,
                          deviceToken: deviceToken?.hexString,
                          baseURL: baseURL)
    }
}

extension RPushPNPGetDenyTypeRequest: RequestParameterizable {
    func toRequestParameters(isMember: Bool, baseURL: URL) -> RequestParameters {
        RequestParameters(isMember: isMember,
                          accessToken: accessToken,
                          clientIdentifier: pnpClientIdentifier,
                          clientSecret: pnpClientSecret,
                          deviceToken: deviceToken?.hexString,
                          userIdentifier: userIdentifier,
                          baseURL: baseURL)
    }
}

extension RPushPNPSetDenyTypeRequest: RequestParameterizable {
    func toRequestParameters(isMember: Bool, baseURL: URL) -> RequestParameters {
        RequestParameters(isMember: isMember,
                          accessToken: accessToken,
                          clientIdentifier: pnpClientIdentifier,
                          clientSecret: pnpClientSecret,
                          deviceToken: deviceToken?.hexString,
                          userIdentifier: userIdentifier,
                          pushTypesFilter: pushFilter,
                          baseURL: baseURL)
    }
}

extension RPushPNPGetPushedHistoryRequest: RequestParameterizable {
    func toRequestParameters(isMember: Bool, baseURL: URL) -> RequestParameters {
        RequestParameters(isMember: isMember,
                          accessToken: accessToken,
                          clientIdentifier: pnpClientIdentifier,
                          clientSecret: pnpClientSecret,
                          deviceToken: deviceToken?.hexString,
                          userIdentifier: userIdentifier,
                          pushType: pushType,
                          registerDateStart: registerDateStart,
                          registerDateEnd: registerDateEnd,
                          limit: limit,
                          paging: page,
                          baseURL: baseURL)
    }
}

extension RPushPNPGetUnreadCountRequest: RequestParameterizable {
    func toRequestParameters(isMember: Bool, baseURL: URL) -> RequestParameters {
        RequestParameters(isMember: isMember,
                          accessToken: accessToken,
                          clientIdentifier: pnpClientIdentifier,
                          clientSecret: pnpClientSecret,
                          deviceToken: deviceToken?.hexString,
                          userIdentifier: userIdentifier,
                          pushType: pushType,
                          baseURL: baseURL)
    }
}

extension RPushPNPSetHistoryStatusRequest: RequestParameterizable {
    func toRequestParameters(isMember: Bool, baseURL: URL) -> RequestParameters {
        RequestParameters(isMember: isMember,
                          accessToken: accessToken,
                          clientIdentifier: pnpClientIdentifier,
                          clientSecret: pnpClientSecret,
                          deviceToken: deviceToken?.hexString,
                          userIdentifier: userIdentifier,
                          pushType: pushType,
                          registerDateStart: registerDateStart,
                          registerDateEnd: registerDateEnd,
                          markAsRead: markAsRead,
                          requestIdentifier: requestIdentifier,
                          baseURL: baseURL)
    }
}
