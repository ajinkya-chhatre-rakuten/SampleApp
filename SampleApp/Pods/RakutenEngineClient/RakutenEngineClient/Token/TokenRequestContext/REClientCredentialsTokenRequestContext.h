#import <RakutenEngineClient/RETokenRequestContext.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Concrete conformer of RETokenRequestContext used to contextualize RETokenRequest instancess for tokens with client-level permissions.
 *
 *  This basic token request context has no additional properties. It is used to provide context to RETokenRequest instances indicating that
 *  the resulting tokens have client-level permissions, meaning they can be used for Rakuten App Engine web services which are not member
 *  specific.
 *
 *  Token requests with this context should typically be parsed with RETokenResult.
 *
 *  @see https://confluence.rakuten-it.com/confluence/display/RAED/client_credentials
 *
 *  @class REClientCredentialsTokenRequestContext REClientCredentialsTokenRequestContext.h <RakutenEngineClient/REClientCredentialsTokenRequestContext.h>
 *  @ingroup RERequests
 */
RWC_EXPORT @interface REClientCredentialsTokenRequestContext : NSObject <RETokenRequestContext>
@end

NS_ASSUME_NONNULL_END
