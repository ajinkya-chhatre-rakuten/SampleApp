#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RETokenResult;
@class RETokenRequest;
@class RERevokeTokenRequest;
@class REValidateTokenRequest;

/**
 *  Client for Rakuten App Engine's platform level services.
 *
 *  A client instance can be used in conjunction with specific request classes to conveniently create NSURLSessionData tasks which can then
 *  be resumed. Like all RWClient subclasses, REClient inherits the RWClient::sharedClient singleton which can be used for convenience.
 *
 *  For example:
 *  @code
 *  RETokenRequest *tokenRequest = [RETokenRequest japanPasswordTokenRequestWithClientIdentifier:clientID
 *                                                                                  clientSecret:clientSecret
 *                                                                                      username:username
 *                                                                                      password:password];
 *  NSURLSessionDataTask *tokenDataTask;
 *  tokenDataTask = [[REClient sharedClient] tokenWithRequest:tokenRequest completionBlock:^(RETokenResult *result, NSError *error) {
 *      // Use the token result
 *  }];
 *  [tokenDataTask resume];
 *  @endcode
 *
 *  @note This uses the @c +sharedSession of NSURLSession to generate NSURLSessionDataTasks. All returned data tasks must be resumed.
 *
 *  @see https://confluence.rakuten-it.com/confluence/display/RAED/Platform
 *
 *  @class REClient REClient.h <RakutenEngineClient/REClient.h>
 *  @ingroup RECoreComponents
 */
RWC_EXPORT @interface REClient : RWClient

/**
 *  Produces an NSURLSessionDataTask for requesting tokens.
 *
 *  @note The completion block's parsed result is based on the context of the given request. For all context conformers other than
 *        REGlobalPasswordTokenRequestContext, the result is a normal RETokenResult instance. However, for
 *        REGlobalPasswordTokenRequestContext the result is an REGlobalTokenResult instance, requiring a cast in order to access the
 *        additional properties.
 *
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=222008474 and
 *       https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=675863661
 *
 *  @param request         The token request with an appropriate request context for the type of token being requested
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)tokenWithRequest:(RETokenRequest *)request
                                    completionBlock:(void (^)(RETokenResult *__nullable result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask for revoking access tokens.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=222009343
 *
 *  @param request         The request with the access token to revoke
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)revokeTokenWithRequest:(RERevokeTokenRequest *)request
                                          completionBlock:(void (^)(BOOL result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask for checking an access token's validity.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=222009371
 *
 *  @param request         The request with the access token to validate
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)validateTokenWithRequest:(REValidateTokenRequest *)request
                                            completionBlock:(void (^)(BOOL result, NSError *__nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
