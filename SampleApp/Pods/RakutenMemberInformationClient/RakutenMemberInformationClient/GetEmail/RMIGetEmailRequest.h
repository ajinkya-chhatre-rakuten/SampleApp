#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Class for issuing requests for Rakuten App Engine's MemberInformation/GetMail endpoint
 
 *  This class represents both request parameters and NSURLRequest serialization. By default #RMIDefaultBaseURLString is used as the base URL.
 
 *  @note Requests made with this class require tokens with the @c "memberinfo_read_mail" scope.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=654674622
 
 *  @class RMIGetEmailRequest RMIGetEmailRequest.h <RakutenMemberInformationClient/RMIGetEmailRequest>
 *  @ingroup RMIRequests
 *  @ingroup RMICoreComponents
 */
RWC_EXPORT @interface RMIGetEmailRequest : NSObject<RWCURLRequestSerializable, RWCAppEngineScopedEndpoint, NSCopying, NSSecureCoding>

/**
 *  Designated initializer which takes a Japan Ichiba member's access token to locate their profile name information.
 *
 *  @param accessToken The member's access token. This should not be an anonymous or client token.
 *
 *  @return An initialized instance of the receiver
 */
- (instancetype)initWithAccessToken:(NSString *)accessToken NS_DESIGNATED_INITIALIZER;

/**
 *  The member access token both authorizing and identifying the Japan Ichiba member whose profile is being requested
 *
 *  @note This token must be permitted to the @c "memberinfo_read_mail" scope
 */
@property (copy, nonatomic) NSString *accessToken;

@end

/**
 *  Convenience methods for RMIGetEmailRequest
 */
@interface RMIGetEmailRequest (RMIConvenience)

/**
 *  Convenience factory for generating Japan Ichiba mail address(PC/Mobile) requests.
 *
 *  @see RMIGetEmailRequest::initWithAccessToken:
 *
 *  @param accessToken The Japan Ichiba member's access token. This should not be an anonymous or client token.
 *
 *  @return An initialized instance of the receiver
 */
+ (instancetype)requestWithAccessToken:(NSString *)accessToken;

@end

NS_ASSUME_NONNULL_END