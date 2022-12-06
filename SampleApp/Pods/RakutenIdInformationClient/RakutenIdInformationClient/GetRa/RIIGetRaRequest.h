/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Class for issuing requests for requesting the Ra key from Rakuten App Engine's IdInformation/GetRa endpoint.
 *
 *  This class represents both request parameters and NSURLRequest serialization. By default #RIIDefaultBaseURLString is used as the
 *  base URL.
 *
 *  @note Requests made with this class require tokens with the @c "idinfo_read_ra" scope.
 *  @see http://ws-jenkins.stg-jpe1.rakuten.rpaas.net/job/rae.document/lastSuccessfulBuild/artifact/dist/index.html#/doc/ServiceConfiguration_IdInformation/GetRa/20110601
 *
 *  @class RIIGetRaRequest RIIGetRaRequest.h <RakutenIdInformationClient/RIIGetRaRequest.h>
 *  @ingroup RIIRequests
 *  @ingroup RIICoreComponents
 */
RWC_EXPORT @interface RIIGetRaRequest : NSObject <RWCURLRequestSerializable, RWCAppEngineScopedEndpoint, NSCopying, NSSecureCoding>

/**
 *  Designated initializer creates a requests for requesting the Ra key from the endpoint.
 *
 *  @param accessToken          The OAuth2 token of Rakuten App Engine. This parameter is issued token by password, authorization_code.
 *
 *  @return An initialized instance of the receiver
 */
- (instancetype)initWithAccessToken:(NSString *)accessToken NS_DESIGNATED_INITIALIZER;

/**
 *  The access token to use for IdInformation.
 *
 *  @note This token must be permitted to the @c "idinfo_read_ra" scope
 */
@property (copy, nonatomic) NSString *accessToken;

#ifndef DOXYGEN
- (instancetype)init NS_UNAVAILABLE;
#endif

@end

/**
 *  Convenience methods for RIIGetRaRequest
 */
@interface RIIGetRaRequest (RIIConvenience)

/**
 *  Convenience factory for generating a requests for requesting the Ra key from the endpoint.
 *
 *  @see RIIGetRaRequest::initWithAccessToken:
 *
 *  @param accessToken          The OAuth2 token of Rakuten App Engine. This parameter is issued token by password, authorization_code.
 *
 *  @return An initialized instance of the receiver
 */
+ (instancetype)requestWithAccessToken:(NSString *)accessToken;

@end

NS_ASSUME_NONNULL_END