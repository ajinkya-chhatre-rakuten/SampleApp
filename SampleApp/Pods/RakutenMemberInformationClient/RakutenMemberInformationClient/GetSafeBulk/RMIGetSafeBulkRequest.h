#import <Foundation/Foundation.h>
#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Class for issuing requests for Rakuten App Engine's MemberInformation/GetSafeBulk endpoint.
 *
 *  This class represents both request parameters and NSURLRequest serialization. By default #RMIDefaultBaseURLString is used as the base URL.
 *
 *  @note Requests made with this class require tokens with the @c "memberinfo_read_safebulk" scope.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=507645794
 *
 *  @class RMIGetSafeBulkRequest RMIGetSafeBulkRequest.h <RakutenMemberInformationClient/RMIGetSafeBulkRequest.h>
 *  @ingroup RMIRequests
 *  @ingroup RMICoreComponents
 */
RWC_EXPORT @interface RMIGetSafeBulkRequest : NSObject <RWCURLRequestSerializable, RWCAppEngineScopedEndpoint, NSCopying, NSSecureCoding>

/**
 *  Designated initializer which takes a Japan Ichiba member's access token to locate their bulk profile information.
 *
 *  @param accessToken The member's access token. This should not be an anonymous or client token.
 *
 *  @return An initialized instance of the receiver
 */
- (instancetype)initWithAccessToken:(NSString *)accessToken NS_DESIGNATED_INITIALIZER;

/**
 *  The member access token both authorizing and identifying the Japan Ichiba member whose bulk profile is being requested
 *
 *  @note This token must be permitted to the @c "memberinfo_read_telephone" scope
 */
@property (copy, nonatomic) NSString *accessToken;

@end

/**
 *  Convenience methods for RMIGetSafeBulkRequest
 */
@interface RMIGetSafeBulkRequest (RMIConvenience)

/**
 *  Convenience factory for generating Japan Ichiba bulk profile information requests.
 *
 *  @see RMIGetSafeBulkRequest::initWithAccessToken:
 *
 *  @param accessToken The Japan Ichiba member's access token. This should not be an anonymous or client token.
 *
 *  @return An initialized instance of the receiver
 */
+ (instancetype)requestWithAccessToken:(NSString *)accessToken;

@end

NS_ASSUME_NONNULL_END
