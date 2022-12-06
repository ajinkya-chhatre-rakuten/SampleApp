#import <RakutenWebClientKit/RakutenWebClientKit.h>
#import <RPushPNP/RPushPNPProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@class RPushPNPGetDenyTypeRequest;
@class RPushPNPDenyType;
@class RPushPNPSetDenyTypeRequest;
@class RPushPNPRegisterDeviceRequest;
@class RPushPNPUnregisterDeviceRequest;
@class RPushPNPGetPushedHistoryRequest;
@class RPushPNPHistoryData;
@class RPushPNPGetUnreadCountRequest;
@class RPushPNPUnreadCount;
@class RPushPNPSetHistoryStatusRequest;

RWC_EXPORT @interface RAEClient : NSObject <RPushPNPProtocol>

/**
 *  Sets a custom client to perform the register/unregister API requests.
 *
 *  @note If this method hasn't been called or if `client` is nil the fallback
 *  `RPushPNPClient.sharedClient` will be used to perform requests.
 *
 *  @param client  The client to use to perform requests.
 *
 */
- (void)setPushAPIClient:(id<RPushPNPClientConfigurable> __nullable)client;

- (id<RPushPNPClientConfigurable>)client;

/**
 *  Produces an NSURLSessionDataTask for requesting denied or acceptable types.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=48149409
 *
 *  @param request         The request to get denied or acceptable types.
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)getDenyTypeWithRequest:(RPushPNPGetDenyTypeRequest *)request
                                          completionBlock:(void (^)(RPushPNPDenyType *__nullable result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask for setting denied or acceptable types.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=48149390
 *
 *  @param request         The request to set denied or acceptable types.
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)setDenyTypeWithRequest:(RPushPNPSetDenyTypeRequest *)request
                                          completionBlock:(void (^)(BOOL result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask to register the device.
 *
 *  @note This method implements a caching mechanism, so that subsequent calls do not result in any
 *        actual network request.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=48149359
 *
 *  @param request         The request to register device.
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)registerDeviceWithRequest:(RPushPNPRegisterDeviceRequest *)request
                                             completionBlock:(void (^)(BOOL result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask to unregister the device.
 *
 *  @note Upon success, this method invalidates the cache used by the `registerDevice` method above.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=48149369
 *
 *  @param request         The request to unregister device.
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)unregisterDeviceWithRequest:(RPushPNPUnregisterDeviceRequest *)request
                                               completionBlock:(void (^)(BOOL result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask to get pushed records of history data.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=85986671
 *
 *  @param request         The request to get pushed records of history data.
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)getPushedHistoryWithRequest:(RPushPNPGetPushedHistoryRequest *)request
                                               completionBlock:(void (^)(RPushPNPHistoryData *__nullable result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask to get number of unread push notifications.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=240191091
 *
 *  @param request         The request to get number of unread push notifications.
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)getUnreadCountWithRequest:(RPushPNPGetUnreadCountRequest *)request
                                             completionBlock:(void (^)(RPushPNPUnreadCount *__nullable result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask to update history record.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=252742932 and
 *       https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=275983498
 *
 *  @param request         The request to update history record.
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)setHistoryStatusWithRequest:(RPushPNPSetHistoryStatusRequest *)request
                                               completionBlock:(void (^)(BOOL result, NSError *__nullable error))completionBlock;
@end

NS_ASSUME_NONNULL_END
