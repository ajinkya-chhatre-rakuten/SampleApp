#import <Foundation/Foundation.h>
#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Class for issuing requests for Rakuten App Engine's MemberInformation/GetCredit endpoint.
 *
 *  This class represents both request parameters and NSURLRequest serialization. By default #RMIDefaultBaseURLString is used as the base URL.
 *
 *  @note Requests made with this class require tokens with the @c "memberinfo_read_credit" scope. Additionally, the service identifier
 *        associated with the client application must have permission to access credit card information. For more details see the Confluence
 *        documentation.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=709317428
 *
 *  @class RMIGetCreditCardRequest RMIGetCreditCardRequest.h <RakutenMemberInformationClient/RMIGetCreditCardRequest.h>
 *  @ingroup RMIRequests
 *  @ingroup RMICoreComponents
 *  @deprecated Do not use. The RAE MemberInformation/GetCredit/20120425 API has been abolished.
 */
DEPRECATED_MSG_ATTRIBUTE("Do not use. The RAE MemberInformation/GetCredit/20120425 API has been abolished.")
RWC_EXPORT @interface RMIGetCreditCardRequest : NSObject <RWCURLRequestSerializable, RWCAppEngineScopedEndpoint, NSCopying, NSSecureCoding>

/**
 *  Designated initializer which takes a Japan Ichiba member's access token to locate their credit card information.
 *
 *  @param accessToken The member's access token. This should not be an anonymous or client token.
 *
 *  @return An initialized instance of the receiver
 */
- (instancetype)initWithAccessToken:(NSString *)accessToken NS_DESIGNATED_INITIALIZER;

/**
 *  The member access token both authorizing and identifying the Japan Ichiba member whose credit card is being requested
 *
 *  @note This token must be permitted to the @c "memberinfo_read_credit" scope
 */
@property (copy, nonatomic) NSString *accessToken;

@end

/**
 *  Convenience methods for RMIGetCreditCardRequest
 */
@interface RMIGetCreditCardRequest (RMIConvenience)

/**
 *  Convenience factory for generating Japan Ichiba credit card information requests.
 *
 *  @see RMIGetCreditCardRequest::initWithAccessToken:
 *
 *  @param accessToken The Japan Ichiba member's access token. This should not be an anonymous or client token.
 *
 *  @return An initialized instance of the receiver
 */
+ (instancetype)requestWithAccessToken:(NSString *)accessToken;

@end

NS_ASSUME_NONNULL_END
