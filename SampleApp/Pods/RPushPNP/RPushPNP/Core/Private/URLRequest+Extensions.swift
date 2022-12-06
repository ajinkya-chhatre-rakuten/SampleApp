import Foundation
import RLogger

enum HTTPMethod: String {
    case GET, POST
}

/// See https://www.ietf.org/rfc/rfc3986.txt section 2.2 and 3.4
private let RFC3986UnreservedCharacters: CharacterSet = {
    var allowed = CharacterSet.urlQueryAllowed
    let RFC3986ReservedCharacters = ":#[]@!$&'()*+,;="
    allowed.remove(charactersIn: RFC3986ReservedCharacters)
    return allowed
}()

extension URLRequest {
    /// Create a new instance of `URLRequest`.
    ///
    /// - Parameters:
    ///     - url: the URL.
    ///     - httpMethod: the http method.
    ///     - httpBody: the http body.
    ///     - accessToken: the access token.
    init(url: URL,
         httpMethod: String,
         httpBody: Data? = nil,
         accessToken: String) {
        self.init(url: url)
        self.httpMethod = httpMethod
        self.httpBody = httpBody
        setAuthorizationToken(accessToken)
    }

    /// Create a new instance of `URLRequest`.
    ///
    /// - Parameters:
    ///     - url: the URL.
    ///     - httpMethod: the http method.
    ///     - parameters: the parameters.
    init(url: URL, httpMethod: HTTPMethod, parameters: RequestParameters) throws {
        var components = URLComponents(queryItems: [])
        components.addResponseJson()
        components.addPnpClientId(parameters.clientIdentifier)
        components.addPnpClientSecret(parameters.clientSecret)
        if let deviceToken = parameters.deviceToken { components.addDeviceId(deviceToken) }
        if let userIdentifier = parameters.userIdentifier { components.addUserid(userIdentifier) }
        if let requestIdentifier = parameters.requestIdentifier { components.addRequestId(requestIdentifier) }
        if let pushTypesFilter = parameters.pushTypesFilter { components.addPushTypesFilter(pushTypesFilter) }
        if let pushType = parameters.pushType { components.addPushType(pushType) }
        if let registerDateStart = parameters.registerDateStart { components.addRegisterDateStart(registerDateStart) }
        if let registerDateEnd = parameters.registerDateEnd { components.addRegisterDateEnd(registerDateEnd) }
        if let limit = parameters.limit { components.addLimit(limit) }
        if let paging = parameters.paging { components.addPaging(paging) }

        components.queryItems = components.queryItems?.compactMap {
            guard let name = $0.name.addingPercentEncoding(withAllowedCharacters: RFC3986UnreservedCharacters),
                  let value = $0.value?.addingPercentEncoding(withAllowedCharacters: RFC3986UnreservedCharacters) else {
                RLogger.warning("PNP API-C Error: the parameter (key: \($0.name), value: \($0.value ?? "")) could not be added to \(url.absoluteString)")
                return nil
            }
            return URLQueryItem(name: name, value: value)
        }

        switch httpMethod {
        case .POST:
            self.init(url: url,
                      httpMethod: httpMethod.rawValue,
                      httpBody: components.toData,
                      accessToken: parameters.accessToken)
        case .GET:
            let result = components.queryItems?.compactMap({ item -> String? in
                guard let value = item.value else {
                    return nil
                }
                return "\(item.name)=\(value)"
            })
            guard let query = result?.joined(separator: "&"),
                  let urlWithParameters = URL(string: "\(url.absoluteString)?\(query)") else {
                throw RPushPNPError.baseURLIsNilError
            }

            self.init(url: urlWithParameters,
                      httpMethod: httpMethod.rawValue,
                      httpBody: nil,
                      accessToken: parameters.accessToken)
        }
    }
}

extension URLRequest {
    /// Set the Authorization token to the HTTP Header field.
    mutating func setAuthorizationToken(_ token: String) {
        setValue(token, forHTTPHeaderField: "Authorization")
    }
}
