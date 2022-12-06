#import <RakutenWebClientKit/RakutenWebClientKit.h>
#import <RPushPNP/RPushPNPBaseRequest.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Class for issuing requests for Rakuten App Engine's PNP/GetPushedHistory endpoint.
 *
 *  This class represents both request parameters and NSURLRequest serialization. By default #RPushPNPDefaultBaseURLString is used as the
 *  base URL.
 *
 *  @note Requests made with this class require tokens with the @c "pnp_common_pushedhistory" scope.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=85986671
 *
 *  @class RPushPNPGetPushedHistoryRequest RPushPNPGetPushedHistoryRequest.h <RPushPNP/RPushPNPGetPushedHistoryRequest.h>
 */
RWC_EXPORT @interface RPushPNPGetPushedHistoryRequest : RPushPNPBaseRequest<RWCURLRequestSerializable, RWCURLQueryItemSerializable, RWCAppEngineScopedEndpoint, NSCopying, NSSecureCoding>

/**
 *  The maximum number of records in a page.
 */
@property (nonatomic) NSInteger limit;

/**
 *  The index of the page to request. Indices start at `1`.
 */
@property (nonatomic) NSInteger page;

/**
 *  The push type.
 *
 *  This is a Filter. Only pushes with the pushType will be returned.
 */
@property (nonatomic, copy, nullable) NSString *pushType;

/**
 *  The register date start.
 *
 *  This is a Filter. Only pushes scheduled to sent on this date and onwards will be returned.
 */
@property (nonatomic, copy, nullable) NSDate *registerDateStart;

/**
 *  The register date end.
 *
 *  This is a Filter. Only pushes scheduled to sent before this date will be returned.
 */
@property (nonatomic, copy, nullable) NSDate *registerDateEnd;

@end

/**
 *  Convenience methods for RPushPNPGetPushedHistoryRequest
 */
@interface RPushPNPGetPushedHistoryRequest (RPushPNPConvenience)

/**
 *  Convenience factory uses the initialize method of RPushPNPBaseRequest for generating a request for getting a list of records of history data.
 *
 *  @see RPushPNPBaseRequest::initWithAccessToken:pnpClientIdentifier:pnpClientSecret:deviceIdentifer:
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
+ (instancetype)requestWithAccessToken:(NSString *)accessToken
                   pnpClientIdentifier:(NSString *)pnpClientIdentifier
                       pnpClientSecret:(NSString *)pnpClientSecret
                           deviceToken:(NSData *)deviceToken;

@end

NS_ASSUME_NONNULL_END
