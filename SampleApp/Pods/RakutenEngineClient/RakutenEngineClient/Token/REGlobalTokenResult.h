#import <RakutenEngineClient/RETokenResult.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Result model for Rakuten App Engine's engine/gtoken endpoint.
 *
 *  This class inherits from RETokenResult, meaning it is also a conformer of RWCURLResponseParser and can be parsed from RETokenRequest
 *  serialized network requests. Specifically this class is intended for use with the result of a token request whose context is a
 *  REGlobalPasswordTokenRequestContext instance. While no exceptions will be thrown if this class is used with any other token request
 *  context, the additional context defined in this class will be meaningless and should be ignored. Similarly, no exception will be raised
 *  if a token request with a REGlobalPasswordTokenRequestContext context has its network response parsed by RETokenResult, but the
 *  additional context provided by that specific response will be lost.
 *
 *  @class REGlobalTokenResult REGlobalTokenResult.h <RakutenEngineClient/REGlobalTokenResult.h>
 *  @ingroup REResponses
 *  @ingroup RECoreComponents
 *  @deprecated Global ID support is deprecated and will be removed in the next major version of our SDK (3.0), scheduled to be released in Q1 2017. Applications relying on Global ID are invited to implement and maintain authentication as part of their source code base.
 */
DEPRECATED_MSG_ATTRIBUTE("Global ID support is deprecated and will be removed in the next major version of our SDK (3.0), scheduled to be released in Q1 2017. Applications relying on Global ID are invited to implement and maintain authentication as part of their source code base.")
RWC_EXPORT @interface REGlobalTokenResult : RETokenResult

/**
 *  Flag indicating if the Global Ichiba member associated with the receiving token has accepted the associated marketplace's terms and
 *  conditions
 *
 *  @note This property is only relevant to Global Ichiba member tokens
 *
 *  If this property returns @c YES, the member has accepted the marketplace's terms and conditions and requests can be made without issue
 *  using the receiver's access token. If this property returns @c NO, the member may not have accepted the terms and conditions for the
 *  specific marketplace the tokens were generated in. In such a case, the terms and conditions should be accepted prior to utilizing the
 *  receiver's access token (typically through the RakutenGlobalMemberInformationClient library). Note that once terms and conditions have
 *  been accepted, the access token does not need to be regenerated before it can be used.
 */
@property (assign, nonatomic) BOOL didMemberAcceptMarketplaceTermsAndConditions;

/**
 *  The identifier of the marketplace in which the receiver's access token can be used
 *
 *  @note The receiver's implementation of RWCURLResponseParser does not set this property since it is not part of the network response.
 *        It is provided as a convenience for developers to keep track of what marketplace their tokens were generated in. The default
 *        implementation of REClient::tokenWithRequest:completionBlock: does set this property on the result when the passed request
 *        has a REGlobalPasswordTokenRequestContext instance context.
 */
@property (copy, nonatomic, nullable) NSString *marketplaceIdentifierForAccessToken;

@end

NS_ASSUME_NONNULL_END
