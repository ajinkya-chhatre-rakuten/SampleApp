#import <RakutenWebClientKit/RakutenWebClientKit.h>
#import <RPushPNP/RPushPNPProtocol.h>
#import <RPushPNP/RPushPNPBaseRequest.h>

NS_ASSUME_NONNULL_BEGIN

@class RPushPNPAPIParameters;
@class RPushPNPBaseRequest;

typedef NS_ENUM(NSUInteger, RPushPNPManagerAPIType) {
    RPushPNPManagerAPITypeRAE = 0, // RAE
    RPushPNPManagerAPITypeAPIC // API-C
};

typedef void (^ExpiredAccessTokenCompletionBlock)(UpdateTokenBlock);

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

@interface RWClient() <RPushPNPClientConfigurable>
@end

RWC_EXPORT @interface RPushPNPManager : NSObject <RPushPNPProtocol>

/**
 * This completion block is called when the access token is expired.
 *
 * RAE case:   Use it to fetch a new access token and pass it to `updateClientTokenCompletionBlock`.
 *
 * API-C case: Use it to fetch a new exchange token and pass it to `updateClientTokenCompletionBlock`.
 *
 * @Example:
 *
 * - Swift:
 *
 * 1) RAE
 * RPushPNPManager.sharedInstance().accessTokenIsExpiredCompletionBlock = { updateAccessTokenCompletionBlock in
 *      self.fetchMyRAEAccessToken { accessToken in
 *          updateAccessTokenCompletionBlock(accessToken)
 *      }
 * }
 *
 * 2) API-C
 * RPushPNPManager.sharedInstance().accessTokenIsExpiredCompletionBlock = { updateAccessTokenCompletionBlock in
 *      self.fetchMyExchangeToken { exchangeToken in
 *          self.fetchMyAPICAccessToken(exchangeToken) { accessToken in
 *              updateAccessTokenCompletionBlock(accessToken)
 *          }
 *      }
 * }
 *
 */
@property (nonatomic, copy) _Nullable ExpiredAccessTokenCompletionBlock accessTokenIsExpiredCompletionBlock;

+ (instancetype)sharedInstance;

/**
 *  Enable an API: RAE or API-C.
 *
 *  @note:
 *  The RAE API is enabled by default.
 *
 *  @param apiType  The API type, RAE or API-C.
 *
 */
- (void)enableAPI:(RPushPNPManagerAPIType)apiType;

/**
 *  Returns the enabled API: RAE or API-C.
 *
 */
- (RPushPNPManagerAPIType)enabledAPI;

/**
 *  Return the access token in successCompletion or an error in failureCompletion.
 *
 *  @param parameters  The parameters containing the client identifier, the client secret and the token.
 *
 *  @note: RPushPNPAPIParameters.clientId and RPushPNPAPIParameters.clientSecret are required to fetch the Non-Member access token.
 *
 *  @note: RPushPNPAPIParameters.token is required to fetch the Member access token.
 *
 *  @note:
 *  The access token is returned only if RPushPNPManagerAPITypeAPIC is enabled.
 *  The app is responsible for fetching and passing in the access token if RPushPNPManagerAPITypeRAE is used.
 *
 *  @note:
 *  The access token has an expiration date.
 *
 */
- (void)fetchAccessTokenWithParameters:(RPushPNPAPIParameters * _Nullable)parameters
                     failureCompletion:(void (^)(NSError *))failureCompletion
                     successCompletion:(void (^)(NSString *))successCompletion;

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

/**
 *  Checks the PNP registration cache to get the PNP registration status.
 *
 *  @param pnpClientIdentifier  The PNP Client identifier.
 *  @param userIdentifier  The PNP user identifier. Set empty string if there is no user identifier.
 *  @param deviceToken  The APNS device token.
 *
 *  @return the PNP registration status boolean
 *
 */
- (BOOL)isRegisteredToPNP:(NSString *)pnpClientIdentifier
           userIdentifier:(NSString *)userIdentifier
              deviceToken:(NSData *)deviceToken;

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
