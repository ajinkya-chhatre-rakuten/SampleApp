import Foundation

/// The Anonymous Token Model
private struct AnonymousToken {
    let clientId: String
    let clientSecret: String

    /// - Returns: the anonymous token value.
    var value: String {
        let value = "\(clientId):\(clientSecret)".toBase64
        return "Basic \(value)"
    }
}

/// A client using API-C to send requests to the PNP API.
@objc public final class APICClient: NSObject {
    let requester: Requestable
    var pnpClient: RPushPNPClientConfigurable
    var customClient: RPushPNPClientConfigurable?
    @objc public private(set) var isMember = false

    /// Create a new instance of `APICClient`.
    @objc public init(requester: Requestable, pnpClient: RPushPNPClientConfigurable) {
        self.requester = requester
        self.pnpClient = pnpClient
        super.init()
    }
}

// MARK: - API-C Base URL

extension APICClient {
    var clientBaseURL: URL? {
        (client().clientConfiguration.baseURL ?? URL(string: RPushPNPDefaultAPICBaseURLString))
    }
}

// MARK: - API-C Access Token

extension APICClient {
    /// Fetch the access token.
    ///
    /// - Parameters:
    ///   - parameters: The parameters containing the  API-C client identifier, the API-C client secret and the exchange token.
    ///
    /// - Note: Returns the access token in `successCompletion` or an error in `failureCompletion`.
    @objc public func fetchAccessToken(parameters: RPushPNPAPIParameters,
                                       failureCompletion: @escaping (Error) -> Void,
                                       successCompletion: @escaping (String) -> Void) {
        guard let baseURL = clientBaseURL else {
            failureCompletion(RPushPNPError.baseURLIsNilError)
            return
        }
        let token: String
        var willBeMember = false
        if let exchangeToken = parameters.token {
            willBeMember = true
            token = exchangeToken

        } else if let clientId = parameters.clientId,
                  let clientSecret = parameters.clientSecret {
            token = AnonymousToken(clientId: clientId, clientSecret: clientSecret).value

        } else {
            failureCompletion(RPushPNPError.accessTokenMissingParameters)
            return
        }
        let urlRequest = willBeMember ? RequestBuilder.Member.accessToken(token: token, baseURL: baseURL) :
            RequestBuilder.NonMember.accessToken(token: token, baseURL: baseURL)
        requester.send(urlRequest: urlRequest) { error in
            failureCompletion(error)

        } successCompletion: { data in
            var apicTokenValue: String = ""

            switch willBeMember {
            case true:
                guard let apicToken = try? JSONDecoder().decode(APICTokenMember.self, from: data) else {
                    failureCompletion(RPushPNPError.accessTokenCannotBeParsed)
                    return
                }
                apicTokenValue = apicToken.accessToken

            case false:
                guard let apicToken = try? JSONDecoder().decode(APICTokenNonMember.self, from: data) else {
                    failureCompletion(RPushPNPError.accessTokenCannotBeParsed)
                    return
                }
                apicTokenValue = "\(apicToken.tokenType.capitalized) \(apicToken.accessToken)"
            }

            self.isMember = willBeMember
            successCompletion(apicTokenValue)
        }
    }
}

// MARK: - Sender

extension APICClient {
    /// Send the URL request on the network.
    ///
    /// - Parameters:
    ///     - urlRequest: the URL request.
    ///
    /// - Returns: A resumable data task or nil if an error occured.
    func send(urlRequest: URLRequest,
              completionBlock: @escaping (Bool, Error?) -> Void) -> URLSessionDataTask? {
        return requester.send(urlRequest: urlRequest) {
            completionBlock(false, $0)

        } successCompletion: { _ in
            completionBlock(true, nil)
        }
    }

    /// Send the URL request on the network.
    ///
    /// - Parameters:
    ///     - urlRequest: the URL request.
    ///     - modelType: the model type.
    ///
    /// - Returns: A resumable data task or nil if an error occured.
    func send<T: RWCURLResponseParser>(urlRequest: URLRequest,
                                       modelType: T.Type,
                                       completionBlock:  @escaping (T?, Error?) -> Void) -> URLSessionDataTask? {
        return requester.send(urlRequest: urlRequest) {
            completionBlock(nil, $0)

        } successCompletion: {
            self.parse($0) {
                self.convertResult(result: $0, completionBlock: completionBlock)
            }
        }
    }
}

// MARK: - Result

extension APICClient {
    private func convertResult<T: RWCURLResponseParser>(result: Result<T, Error>,
                                                        completionBlock: @escaping (T?, Error?) -> Void) {
        switch result {
        case .failure(let error): completionBlock(nil, error)
        case .success(let model): completionBlock(model, nil)
        }
    }
}

// MARK: - Parser

extension APICClient {
    private func parse<T: RWCURLResponseParser>(_ data: Data,
                                                completionBlock: @escaping (Result<T, Error>) -> Void) {
        T.parseURLResponse(nil, data: data, error: nil) { model, error in
            if let error = error {
                completionBlock(.failure(error))

            } else if let model = model as? T {
                completionBlock(.success(model))

            } else {
                completionBlock(.failure(RPushPNPError.noData))
            }
        }
    }
}
