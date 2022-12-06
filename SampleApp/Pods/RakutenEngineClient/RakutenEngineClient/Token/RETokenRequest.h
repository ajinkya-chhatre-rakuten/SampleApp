#import <RakutenWebClientKit/RakutenWebClientKit.h>
#import <RakutenEngineClient/REConstants.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RETokenRequestContext;

/**
 *  Class for issuing requests for Rakuten App Engine's engine/token endpoint.
 *
 *  This class represents both request parameters and NSURLRequest serialization. By default #REDefaultBaseURLString is used as the
 *  base URL.
 *
 *  Since authentication is required for majority of the RAE web services, this class will be frequently used to generate and refresh
 *  access tokens of varying permissions and types. RETokenRequest instances rely on an associated RETokenRequestContext conforming instance
 *  to provide additional context for the resulting token request. For example, a token that will be used for authenticating web services
 *  not tied to a specific user may request generalized client-credential tokens using the REClientCredentialsTokenRequestContext. By
 *  contrast, web services that require a Japan Ichiba member's access token may be use the REJapanPasswordTokenRequestContext. Network
 *  responses produced by executing any URL requests serialized by instances of this class should be parsed based on their context.
 *
 *  For convenience, this class defines class level factory methods that generate requests with proper contexts that can be used. However
 *  for finer grain control it can be useful to know the class and properties of the associated request context.
 *
 *  @see RETokenRequestContext
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=222008474
 *
 *  @class RETokenRequest RETokenRequest.h <RakutenEngineToken/RETokenRequest.h>
 *  @ingroup RERequests
 *  @ingroup RECoreComponents
 */
RWC_EXPORT @interface RETokenRequest : NSObject <RWCURLRequestSerializable, RWCURLQueryItemSerializable, NSCopying, NSSecureCoding>

/**
 *  Designated initializer which takes a client identifier, secret, and request context to generate tokens
 *
 *  @param clientIdentifier The identifier of the client application
 *  @param clientSecret     The secret of the client application
 *  @param context          An RETokenRequestContext conforming instance that provides serialization context
 *
 *  @return An initialized instance of the receiver
 */
- (instancetype)initWithClientIdentifier:(NSString *)clientIdentifier
                            clientSecret:(NSString *)clientSecret
                                 context:(id<RETokenRequestContext>)context NS_DESIGNATED_INITIALIZER;

/**
 *  The identifier of the client application
 */
@property (copy, nonatomic) NSString *clientIdentifier;

/**
 *  The secret of the client application
 */
@property (copy, nonatomic) NSString *clientSecret;

/**
 *  Additional serialization context for the receiver
 */
@property (copy, nonatomic) id<RETokenRequestContext> context;

/**
 *  The requested lifespan of the access token
 *
 *  By default this property is set to #RETokenLifespanCustom, meaning that the request will contain no explicit access token scope.
 *  Setting this to any other value will add a designated access token lifespan scope to resulting URL requests, and will also remove any
 *  access token lifespan scopes (identified with the suffix @c "\@Access") from the scopes property.
 *
 *  @see scopes
 */
@property (assign, nonatomic) RETokenLifespan accessTokenLifespan;

/**
 *  The requested lifespan of the refresh token
 *
 *  By default this property is set to #RETokenLifespanCustom, meaning that the request will contain no explicit refresh token scope.
 *  Setting this to any other value will add a designated refresh token lifespan scope to resulting URL requests, and will also remove any
 *  refresh token lifespan scopes (identified with the suffix @c "\@Refresh") from the scopes property.
 *
 *  @see scopes
 */
@property (assign, nonatomic) RETokenLifespan refreshTokenLifespan;

/**
 *  A set of NSString instances identifying permissions that requested access tokens should be granted
 *
 *  These strings are defined per web-service. If using a RakutenWebClientKit based library, requests requiring scopes are identified by
 *  the RWCAppEngineScopedEndpoint protocol.
 *
 *  Scopes also represent the desired lifespan of returned access and refresh tokens. These types of scopes are identified with the suffixes
 *  @c "\@Access" and @c "\@Refresh" respectively. When setting this property, if the set contains a lifespan scope for either type of
 *  token, the associated property (accessTokenLifespan and refreshTokenLifespan) will be set to #RETokenLifespanCustom.
 *
 *  @note What scopes can be requested depends on what permissions were granted to the client identifier.
 *  @see accessTokenLifespan and refreshTokenLifespan
 */
@property (copy, nonatomic, nullable) NSSet RWC_GENERIC(NSString *) *scopes;

/**
 *  Creates a token request suitable for requesting client-credential tokens
 *
 *  The resulting token request has a REClientCredentialsTokenRequestContext instance as its context property.
 *
 *  @see REClientCredentialsTokenRequestContext
 *  @see https://confluence.rakuten-it.com/confluence/display/RAED/client_credentials
 *
 *  @param clientIdentifier The identifier of the client application
 *  @param clientSecret     The secret of the client application
 *
 *  @return An initialized instance of the receiver with a REClientCredentialsTokenRequestContext context
 */
+ (instancetype)clientCredentialsTokenRequestWithClientIdentifier:(NSString *)clientIdentifier
                                                     clientSecret:(NSString *)clientSecret;

/**
 *  Creates a token request suitable for requesting Japan Ichiba member tokens
 *
 *  The resulting token request has a REJapanPasswordTokenRequestContext instance as its context property.
 *
 *  @see REJapanPasswordTokenRequestContext
 *  @see https://confluence.rakuten-it.com/confluence/display/RAED/password
 *
 *  @param clientIdentifier The identifier of the client application
 *  @param clientSecret     The secret of the client application
 *  @param username         The Japan Ichiba member's username
 *  @param password         The Japan Ichiba member's password
 *
 *  @return An initialized instance of the receiver with a REJapanPasswordTokenRequestContext context
 *
 *  @see For a more complete method allowing you to set the JID service identifier and the version
 *       of the Rakuten Japan privacy policy agreed to, see
 *       RETokenRequest::japanPasswordTokenRequestWithClientIdentifier:clientSecret:username:password:serviceIdentifier:privacyPolicyVersion:
 */
+ (instancetype)japanPasswordTokenRequestWithClientIdentifier:(NSString *)clientIdentifier
                                                 clientSecret:(NSString *)clientSecret
                                                     username:(NSString *)username
                                                     password:(NSString *)password;

/**
 *  Creates a token request suitable for requesting JID member tokens
 *
 *  The resulting token request has a REJapanPasswordTokenRequestContext instance as its context property.
 *
 *  @see REJapanPasswordTokenRequestContext
 *  @see https://confluence.rakuten-it.com/confluence/display/RAED/password
 *
 *  @param clientIdentifier     The identifier of the client application
 *  @param clientSecret         The secret of the client application
 *  @param username             The Japan Ichiba member's username
 *  @param password             The Japan Ichiba member's password
 *  @param serviceIdentifier    The JID service identifier.
 *  @param privacyPolicyVersion The version of the Rakuten Japan privacy policy the user has agreed
 *                              to. The expected format is `YYYYMMDD`. See @ref REJapanPasswordTokenRequestContext.privacyPolicyVersion for more information.
 *
 *  @return An initialized instance of the receiver with a REJapanPasswordTokenRequestContext context
 */
+ (instancetype)japanPasswordTokenRequestWithClientIdentifier:(NSString *)clientIdentifier
                                                 clientSecret:(NSString *)clientSecret
                                                     username:(NSString *)username
                                                     password:(NSString *)password
                                            serviceIdentifier:(nullable NSString *)serviceIdentifier
                                         privacyPolicyVersion:(nullable NSString *)privacyPolicyVersion;

/**
 *  Creates a token request suitable for requesting Global Ichiba member tokens
 *
 *  The resulting token request has a REGlobalPasswordTokenRequestContext instance as its context property.
 *
 *  @see REGlobalPasswordTokenRequestContext
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=675863661
 *
 *  @param clientIdentifier      The identifier of the client application
 *  @param clientSecret          The secret of the client application
 *  @param username              The Global Ichiba member's username
 *  @param password              The Global Ichiba member's password
 *  @param marketplaceIdentifier The identifier of the marketplace in which the tokens should be generated.
 *
 *  @return An initialized instance of the receiver with a REGlobalPasswordTokenRequestContext context
 *  @deprecated Global ID support is deprecated and will be removed in the next major version of our SDK (3.0), scheduled to be released in Q1 2017. Applications relying on Global ID are invited to implement and maintain authentication as part of their source code base.
 */
+ (instancetype)globalPasswordTokenRequestWithClientIdentifier:(NSString *)clientIdentifier
                                                  clientSecret:(NSString *)clientSecret
                                                      username:(NSString *)username
                                                      password:(NSString *)password
                                         marketplaceIdentifier:(NSString *)marketplaceIdentifier
DEPRECATED_MSG_ATTRIBUTE("Global ID support is deprecated and will be removed in the next major version of our SDK (3.0), scheduled to be released in Q1 2017. Applications relying on Global ID are invited to implement and maintain authentication as part of their source code base.");

/**
 *  Creates a token request suitable for refreshing an existing access token of any kind
 *
 *  The resulting token request has a RERefreshTokenRequestContext instance as its context property.
 *
 *  @see RERefreshTokenRequestContext
 *  @see https://confluence.rakuten-it.com/confluence/display/RAED/refresh_token
 *
 *  @param clientIdentifier The identifier of the client application
 *  @param clientSecret     The secret of the client application
 *  @param refreshToken     The valid refresh token returned from a prior token request.
 *
 *  @return An initialized instance of the receiver with a RERefreshTokenRequestContext context
 */
+ (instancetype)refreshTokenRequestWithClientIdentifier:(NSString *)clientIdentifier
                                           clientSecret:(NSString *)clientSecret
                                           refreshToken:(NSString *)refreshToken;

@end

NS_ASSUME_NONNULL_END
