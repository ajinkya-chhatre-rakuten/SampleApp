#import <RakutenEngineClient/RETokenRequestContext.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Concrete conformer of RETokenRequestContext used to contextualize RETokenRequest instancess for refreshing exsting tokens.
 *
 *  This context is used to provide context to RETokenRequest instances indicating that the existing refresh token should be used to
 *  regenerate tokens. These new tokens do not need to share the same scopes, though they will be of the same context with which they were
 *  initially created. For example, refreshing a Japan Ichiba member token will result in new access and refresh tokens that are still
 *  representative of the same Japan Ichiba member. Token requests with this context should therefore be parsed using the same parser as
 *  their originating context.
 *
 *  @see https://confluence.rakuten-it.com/confluence/display/RAED/refresh_token
 *
 *  @class RERefreshTokenRequestContext RERefreshTokenRequestContext.h <RakutenEngineClient/RERefreshTokenRequestContext.h>
 *  @ingroup RERequests
 */
RWC_EXPORT @interface RERefreshTokenRequestContext : NSObject <RETokenRequestContext>

/**
 *  Designated initializer which takes a valid refresh token to generate new tokens of the same context
 *
 *  @param refreshToken The existing refresh token. This must still be valid for the resulting request to succeed.
 *
 *  @return An initialized instance of the receiver
 */
- (instancetype)initWithRefreshToken:(NSString *)refreshToken NS_DESIGNATED_INITIALIZER;

/**
 *  The existing, valid refresh token generated from a prior request
 */
@property (copy, nonatomic) NSString *refreshToken;

@end

NS_ASSUME_NONNULL_END
