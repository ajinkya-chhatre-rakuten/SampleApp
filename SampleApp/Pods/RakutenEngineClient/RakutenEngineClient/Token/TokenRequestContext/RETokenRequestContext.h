#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol for classes that can provide a serialization context for RETokenRequest instances
 *
 *  Classes must conform to RWCURLQueryItemSerializable to provide context-specific query items for the resulting request. Additionally,
 *  support for NSCopying and NSSecureCoding is required so that the RETokenRequest instance it is assocated with can produce deep copies
 *  and be encoded/decoded respectively.
 *
 *  Generally it should not be required for developers to manually create conformers of this protocol unless they are adding support for an
 *  additional @c "grant_type" not supported by the library.
 *
 *  @see REClientCredentialsTokenRequestContext, REJapanPasswordTokenRequestContext, REGlobalPasswordTokenRequestContext,
 *       RERefreshTokenRequestContext
 *
 *  @protocol RETokenRequestContext RETokenRequestContext.h <RakutenEngineClient/RETokenRequestContext.h>
 *  @ingroup RERequests
 */
@protocol RETokenRequestContext <RWCURLQueryItemSerializable, NSCopying, NSSecureCoding, NSObject>

/**
 *  The path that should be appended to the base URL identifying the token request's endpoint.
 *
 *  Typically this is set to @c \@"engine/token"
 *
 *  @return The path that identifies the token request's endpoint relative to a base URL.
 */
- (NSString *)requestURLPath;

@end

NS_ASSUME_NONNULL_END
