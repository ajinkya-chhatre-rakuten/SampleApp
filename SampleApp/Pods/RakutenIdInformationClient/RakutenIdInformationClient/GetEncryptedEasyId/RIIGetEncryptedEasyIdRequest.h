/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Class for issuing requests for requesting the encrypted easyId from Rakuten App Engine's IdInformation/GetEncryptedEasyId endpoint.
 *  The encrypted easy Id is converted by the raw easyId is generated from access_token. 
 *  The encrypted easy Id is used by Rakuten's RAT System, and is dencrypted on RAT side.
 *
 *  This class represents both request parameters and NSURLRequest serialization. By default #RIIDefaultBaseURLString is used as the
 *  base URL.
 *
 *  @note Requests made with this class require tokens with the @c "idinfo_read_encrypted_easyid" scope.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=660276417
 *
 *  @class RIIGetEncryptedEasyIdRequest RIIGetEncryptedEasyIdRequest.h <RakutenIdInformationClient/RIIGetEncryptedEasyIdRequest.h>
 *  @ingroup RIIRequests
 *  @ingroup RIICoreComponents
 */
RWC_EXPORT @interface RIIGetEncryptedEasyIdRequest : NSObject <RWCURLRequestSerializable, RWCAppEngineScopedEndpoint, NSCopying, NSSecureCoding>

/**
 *  Designated initializer creates a requests for requesting the encrypted easyId from the endpoind.
 *
 *  @param accessToken          The OAuth2 token of Rakuten App Engine. This parameter is issued token by password, authorization_code.
 *
 *  @return An initialized instance of the receiver
 */
- (instancetype)initWithAccessToken:(NSString *)accessToken NS_DESIGNATED_INITIALIZER;

/**
 *  The access token to use for IdInformation.
 *
 *  @note This token must be permitted to the @c "idinfo_read_encrypted_easyid" scope
 */
@property (copy, nonatomic) NSString *accessToken;

#ifndef DOXYGEN
- (instancetype)init NS_UNAVAILABLE;
#endif

@end

/**
 *  Convenience methods for RIIGetEncryptedEasyIdRequest
 */
@interface RIIGetEncryptedEasyIdRequest (RIIConvenience)

/**
 *  Convenience factory for generating a requests for requesting the encrypted easyId from the endpoind.
 *
 *  @see RIIGetEncryptedEasyIdRequest::initWithAccessToken:
 *
 *  @param accessToken          The OAuth2 token of Rakuten App Engine. This parameter is issued token by password, authorization_code.
 *
 *  @return An initialized instance of the receiver
 */
+ (instancetype)requestWithAccessToken:(NSString *)accessToken;

@end

NS_ASSUME_NONNULL_END