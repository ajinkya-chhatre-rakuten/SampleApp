import Foundation

// MARK: - Requester

@objc public protocol Requestable {
    @discardableResult
    func send(urlRequest: URLRequest,
              failureCompletion: @escaping (Error) -> Void,
              successCompletion: @escaping (Data) -> Void) -> URLSessionDataTask
}

/// A class to send request
@objc public final class Requester: NSObject {
    private let swiftyRequester: SwiftyRequester

    /// Create a new instance of `Requester`.
    @objc public init(_ session: RPushPNPSessionable) {
        self.swiftyRequester = SwiftyRequester(session)
        super.init()
    }
}

extension Requester: Requestable {
    /// Sends a request on the network.
    ///
    /// - Parameters:
    ///   - urlRequest: The URL request.
    ///
    /// - Returns: A resumable data task or nil if an error occured.
    ///
    /// - Note: Returns a data in `successCompletion` or an error in `failureCompletion`.
    @objc public func send(urlRequest: URLRequest,
                           failureCompletion: @escaping (Error) -> Void,
                           successCompletion: @escaping (Data) -> Void) -> URLSessionDataTask {
        swiftyRequester.send(urlRequest: urlRequest) { (result) in
            switch result {
            case .failure(let error): failureCompletion(error.toNSError)
            case .success(let data): successCompletion(data)
            }
        }
    }
}

// MARK: - SwiftyRequester

enum SwiftyRequesterError: Error {
    case noData
    case urlSessionError(Error)
    case pnpError(String)
    case accessTokenIsExpired(String, String)

    /// Convert a swift Error to NSError in order to be used in Objective-C.
    var toNSError: NSError {
        switch self {
        case .noData: return RPushPNPError.noData
        case .urlSessionError(let error): return RPushPNPError.urlSessionError(error.localizedDescription)
        case .pnpError(let message): return RPushPNPError.pnpError(message)
        case .accessTokenIsExpired(let error, let message): return RPushPNPError.accessTokenIsExpired(error, message: message)
        }
    }

    static let invalidToken = "invalid_token"
}

private struct SwiftyRequester {
    let session: RPushPNPSessionable

    /// Create a new instance of `SwiftyRequester`.
    /// - Parameters:
    ///     - session: the session.
    init(_ session: RPushPNPSessionable) {
        self.session = session
    }

    /// Sends a request on the network.
    ///
    /// - Parameters:
    ///   - urlRequest: The URL request.
    ///
    /// - Returns: A resumable data task or nil if an error occured.
    ///
    /// - Note: it returns a data or an error in `completion`.
    func send(urlRequest: URLRequest, completion: @escaping (Result<Data, SwiftyRequesterError>) -> Void) -> URLSessionDataTask {
        let task = session.dataTask(with: urlRequest) { (data, _, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.urlSessionError(error)))
                    return
                }
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                if let errorModel = try? JSONDecoder().decode(AccessTokenErrorModel.self, from: data) {
                    guard errorModel.error == SwiftyRequesterError.invalidToken else {
                        completion(.failure(.pnpError("\(errorModel.error): \(errorModel.errorDescription)")))
                        return
                    }
                    completion(.failure(.accessTokenIsExpired(errorModel.error, errorModel.errorDescription)))
                    return
                }
                if let errorModel = try? JSONDecoder().decode(ErrorModel.self, from: data),
                   errorModel.statusCode >= 400 {
                    completion(.failure(.pnpError(errorModel.errorMessage)))
                    return
                }
                completion(.success(data))
            }
        }
        task.resume()
        return task
    }
}
