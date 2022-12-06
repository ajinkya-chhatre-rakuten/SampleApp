#import <RakutenEngineClient/RETokenRequestContext.h>
#import <RakutenEngineClient/REChallengeParameters.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Concrete conformer of RETokenRequestContext used to contextualize RETokenRequest instancess for Japan Ichiba member tokens.
 *
 *  This context is used to provide context to RETokenRequest instances indicating that the resulting tokens have Japan Ichiba member
 *  permissions, meaning they can be used for Rakuten App Engine web services which target specific Japan Ichiba member information. Note
 *  that this will not work for those web services which require Global member permissions.
 *
 *  Token requests with this context should typically be parsed with RETokenResult.
 *
 *  @see https://confluence.rakuten-it.com/confluence/display/RAED/password
 *
 *  @class REJapanPasswordTokenRequestContext REJapanPasswordTokenRequestContext.h <RakutenEngineClient/REJapanPasswordTokenRequestContext.h>
 *  @ingroup RERequests
 */
RWC_EXPORT @interface REJapanPasswordTokenRequestContext : NSObject <RETokenRequestContext>

/**
 *  Designated initializer which takes the Japan Ichiba member's username and password
 *
 *  @param username The Japan Ichiba member's username
 *  @param password The Japan Ichiba member's password
 *
 *  @return An initialized instance of the receiver
 */
- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password NS_DESIGNATED_INITIALIZER;

/**
 *  The username of the Japan Ichiba member
 */
@property (copy, nonatomic) NSString *username;

/**
 *  The password of the Japan Ichiba member
 */
@property (copy, nonatomic) NSString *password;

/**
 *  An optional identifier which can be provided to request access to internal Rakuten web services
 *
 *  This identifier must be requested for specific client applications to access certain internal services. For example, Japan Ichiba uses
 *  their application's service identifier to access the checkout web service.
 */
@property (copy, nonatomic, nullable) NSString *serviceIdentifier;

/**
 *  Optional privacy policy version. The current version of the Rakuten Japan privacy policy is at
 *  https://privacy.rakuten.co.jp/date/generic.txt
 *
 *  This is sent as the `pp_version` field described in *Tracking Parameters* at https://confluence.rakuten-it.com/confluence/display/RAED/password#password-RequestParameters
 *  Note that the other tracking parameters are automatically set.
 */
@property (copy, nonatomic, nullable) NSString *privacyPolicyVersion;

/**
 * Challenge Parameters
 */
@property (copy, nonatomic, nullable) REChallengeParameters *challengeParameters;
@end

NS_ASSUME_NONNULL_END
