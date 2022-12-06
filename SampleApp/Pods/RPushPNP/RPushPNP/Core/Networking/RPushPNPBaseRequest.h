#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^UpdateTokenBlock)(NSString *);

/**
 *  Base class for issuing requests for Rakuten App Engine's PNP endpoints.
 *
 *  This class represents both request parameters and NSURLRequest serialization. By default #RPushPNPDefaultBaseURLString is used as the base URL.
 *
 *  @class RPushPNPBaseRequest RPushPNPBaseRequest.h <RPushPNP/RPushPNPBaseRequest.h>
 */
RWC_EXPORT @interface RPushPNPBaseRequest : NSObject<NSCopying, NSSecureCoding>

/**
 *  A block to update the request access token.
 */
@property (nonatomic, copy) _Nullable UpdateTokenBlock updateTokenBlock;

/**
 *  Designated initializer creates a request.
 *
 *  @param accessToken          The OAuth2 token of Rakuten App Engine. Rakuten App Engine supports both Rakuten login user and guest user.
 *  @param pnpClientIdentifier  The client identifier to distinguish pnp client.
 *  @param pnpClientSecret      The password of pnp client.
 *  @param deviceToken          The device token of APNs(Apple Push Notification Service), as obtained
 *                              in the `-application:didRegisterForRemoteNotificationsWithDeviceToken:` method of the
 *                              application delegate.
 *
 *  @return An initialized instance of the receiver
 */
- (instancetype)initWithAccessToken:(NSString *)accessToken
                pnpClientIdentifier:(NSString *)pnpClientIdentifier
                    pnpClientSecret:(NSString *)pnpClientSecret
                        deviceToken:(nullable NSData *)deviceToken NS_DESIGNATED_INITIALIZER;

/**
 *  The access token to use for Push Notification Platform.
 *
 *  @note This token must be permitted to the endpoint's scope
 */
@property (copy, nonatomic) NSString *accessToken;

/**
 *  The client identifier for the Push Notification Platform.
 */
@property (copy, nonatomic) NSString *pnpClientIdentifier;

/**
 *  The client secret for the Push Notification Platform.
 */
@property (copy, nonatomic) NSString *pnpClientSecret;

/**
 *  The device token returned by Apple's notification framework, as obtained
 *  in the `-application:didRegisterForRemoteNotificationsWithDeviceToken:` method of the
 *  application delegate.
 */
@property (copy, nonatomic, nullable) NSData *deviceToken;

/**
 *  The free unique user identifier, e.g. Edy number, Wuaki.tv username, …
 */
@property (copy, nonatomic, nullable) NSString *userIdentifier;

@end

NS_ASSUME_NONNULL_END
