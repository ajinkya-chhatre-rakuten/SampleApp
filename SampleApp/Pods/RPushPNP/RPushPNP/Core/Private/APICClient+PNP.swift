import Foundation

// MARK: - RPushPNPProtocol

extension APICClient: RPushPNPProtocol {
    public func client() -> RPushPNPClientConfigurable { customClient ?? pnpClient }

    public func setPushAPIClient(_ client: RPushPNPClientConfigurable?) { customClient = client }

    /// Produces an `URLSessionDataTask` to register the device.
    ///
    /// - Note: This method implements a caching mechanism, so that subsequent calls do not result in any actual network request.
    ///
    /// - Note: The returned data task must be resumed.
    /// See https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=48149359
    ///
    /// - Parameters:
    ///   - request: The request to register device.
    ///   - completionBlock: A completion block executed when the returned data task resolves
    ///
    /// - Returns: A resumable data task or nil if an error occured.
    @discardableResult
    @objc public func registerDevice(with request: RPushPNPRegisterDeviceRequest, completionBlock: @escaping (Bool, Error?) -> Void) -> URLSessionDataTask? {
        do {
            return try send(urlRequest: RequestBuilder.Common.register(requestParameters(from: request)), completionBlock: completionBlock)
        } catch {
            completionBlock(false, error)
            return nil
        }
    }

    /// Produces an `URLSessionDataTask` to unregister the device.
    ///
    /// - Note: Upon success, this method invalidates the cache used by the `registerDevice` method above.
    ///
    /// - Note: The returned data task must be resumed.
    /// See https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=48149369
    ///
    /// - Parameters:
    ///   - request: The request to unregister device.
    ///   - completionBlock: A completion block executed when the returned data task resolves
    ///
    /// - Returns: A resumable data task or nil if an error occured.
    @discardableResult
    @objc public func unregisterDevice(with request: RPushPNPUnregisterDeviceRequest, completionBlock: @escaping (Bool, Error?) -> Void) -> URLSessionDataTask? {
        do {
            return try send(urlRequest: RequestBuilder.Common.unregister(requestParameters(from: request)), completionBlock: completionBlock)
        } catch {
            completionBlock(false, error)
            return nil
        }
    }

    /// Produces an `URLSessionDataTask` for requesting denied or acceptable types.
    ///
    /// - Note: The returned data task must be resumed.
    /// See https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=48149409
    ///
    /// - Parameters:
    ///   - request: The request to get denied or acceptable types.
    ///   - completionBlock: A completion block executed when the returned data task resolves
    ///
    /// - Returns: A resumable data task or nil if an error occured.
    @discardableResult
    @objc public func getDenyType(with request: RPushPNPGetDenyTypeRequest, completionBlock: @escaping (RPushPNPDenyType?, Error?) -> Void) -> URLSessionDataTask? {
        do {
            return try send(urlRequest: RequestBuilder.Common.getDenyType(requestParameters(from: request)),
                            modelType: RPushPNPDenyType.self,
                            completionBlock: completionBlock)

        } catch {
            completionBlock(nil, error)
            return nil
        }
    }

    /// Produces an `URLSessionDataTask` for setting denied or acceptable types.
    ///
    /// - Note: The returned data task must be resumed.
    /// See https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=48149390
    ///
    /// - Parameters:
    ///   - request: The request to set denied or acceptable types.
    ///   - completionBlock: A completion block executed when the returned data task resolves
    ///
    /// - Returns: A resumable data task or nil if an error occured
    @discardableResult
    @objc public func setDenyTypeWith(_ request: RPushPNPSetDenyTypeRequest, completionBlock: @escaping (Bool, Error?) -> Void) -> URLSessionDataTask? {
        do {
            return try send(urlRequest: RequestBuilder.Common.setDenyType(requestParameters(from: request)), completionBlock: completionBlock)
        } catch {
            completionBlock(false, error)
            return nil
        }
    }

    /// Produces an `URLSessionDataTask` to get pushed records of history data.
    ///
    /// - Note: The returned data task must be resumed.
    /// See https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=85986671
    ///
    /// - Parameters:
    ///   - request: The request to get pushed records of history data.
    ///   - completionBlock: A completion block executed when the returned data task resolves
    ///
    /// - Returns: A resumable data task or nil if an error occured
    @discardableResult
    @objc public func getPushedHistory(with request: RPushPNPGetPushedHistoryRequest, completionBlock: @escaping (RPushPNPHistoryData?, Error?) -> Void) -> URLSessionDataTask? {
        do {
            return try send(urlRequest: RequestBuilder.Common.getPushedHistory(requestParameters(from: request)),
                            modelType: RPushPNPHistoryData.self,
                            completionBlock: completionBlock)

        } catch {
            completionBlock(nil, error)
            return nil
        }
    }

    /// Produces an `URLSessionDataTask` to get number of unread push notifications.
    ///
    /// - Note: The returned data task must be resumed.
    /// See https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=240191091
    ///
    /// - Parameters:
    ///   - request: The request to get number of unread push notifications.
    ///   - completionBlock: A completion block executed when the returned data task resolves
    ///
    /// - Returns: A resumable data task or nil if an error occured
    @discardableResult
    @objc public func getUnreadCount(with request: RPushPNPGetUnreadCountRequest, completionBlock: @escaping (RPushPNPUnreadCount?, Error?) -> Void) -> URLSessionDataTask? {
        do {
            return try send(urlRequest: RequestBuilder.Common.getUnreadCount(requestParameters(from: request)),
                            modelType: RPushPNPUnreadCount.self,
                            completionBlock: completionBlock)

        } catch {
            completionBlock(nil, error)
            return nil
        }
    }

    /// Produces an `URLSessionDataTask` to update history record.
    ///
    /// - Note: The returned data task must be resumed.
    /// See https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=252742932 and
    /// https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=275983498
    ///
    /// - Parameters:
    ///   - request: The request to update history record.
    ///   - completionBlock: A completion block executed when the returned data task resolves
    ///
    /// - Returns: A resumable data task or nil if an error occured
    @discardableResult
    @objc public func setHistoryStatusWith(_ request: RPushPNPSetHistoryStatusRequest, completionBlock: @escaping (Bool, Error?) -> Void) -> URLSessionDataTask? {
        do {
            return try send(urlRequest: RequestBuilder.Common.setHistoryStatus(requestParameters(from: request)), completionBlock: completionBlock)
        } catch {
            completionBlock(false, error)
            return nil
        }
    }
}

private extension APICClient {
    func requestParameters(from request: RequestParameterizable) throws -> RequestParameters {
        guard let baseURL = clientBaseURL else {
            throw RPushPNPError.baseURLIsNilError
        }
        return request.toRequestParameters(isMember: isMember, baseURL: baseURL)
    }
}
