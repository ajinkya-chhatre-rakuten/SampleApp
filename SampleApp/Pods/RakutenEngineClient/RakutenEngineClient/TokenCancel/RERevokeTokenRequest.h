#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Class for issuing requests for Rakuten App Engine's engine/token_cancel endpoint.
 *
 *  This class represents both request parameters and NSURLRequest serialization. By default #REDefaultBaseURLString is used as the
 *  base URL.
 *
 *  While RETokenRequest deals with generating tokens, this class does the reverse and asks the web service to revoke tokens such that they
 *  can no longer be used. Typically this is used in a logout scenario, especially if multiple applications are sharing the same tokens.
 *  Similarly to how RETokenRequest handles multiple types of token requests, this class can revoke any access tokens generated via
 *  RETokenRequest regardless of context type.
 *
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=222009343
 *
 *  @class RERevokeTokenRequest RERevokeTokenRequest.h <RakutenEngineToken/RERevokeTokenRequest.h>
 *  @ingroup RERequests
 *  @ingroup RECoreComponents
 */
RWC_EXPORT @interface RERevokeTokenRequest : NSObject <RWCURLQueryItemSerializable, RWCURLRequestSerializable, NSCopying, NSSecureCoding>

/**
 *  Designated initializer which takes a client's identifier and secret and a valid access token to revoke
 *
 *  @param clientIdentifier The identifier of the client application
 *  @param clientSecret     The secret of the client application
 *  @param accessToken      A valid access token to revoke
 *
 *  @return An initialized instance of the receiver
 */
- (instancetype)initWithClientIdentifier:(NSString *)clientIdentifier
                            clientSecret:(NSString *)clientSecret
                             accessToken:(NSString *)accessToken NS_DESIGNATED_INITIALIZER;

/**
 *  The client application's identifier
 */
@property (copy, nonatomic) NSString *clientIdentifier;

/**
 *  The client application's secret
 */
@property (copy, nonatomic) NSString *clientSecret;

/**
 *  A valid access token which will be revoked
 *
 *  This access token may have any grant-type associated with it.
 */
@property (copy, nonatomic) NSString *accessToken;

@end


/**
 *  Convenience methods for RERevokeTokenRequest
 */
@interface RERevokeTokenRequest (REConvenience)

/**
 *  Convenience factory for generating revoke-token requests
 *
 *  @param clientIdentifier The identifier of the client application
 *  @param clientSecret     The secret of the client application
 *  @param accessToken      A valid access token to revoke
 *
 *  @return An initialized instance of the receiver
 */
+ (instancetype)requestWithClientIdentifier:(NSString *)clientIdentifier
                               clientSecret:(NSString *)clientSecret
                                accessToken:(NSString *)accessToken;

@end

NS_ASSUME_NONNULL_END
