/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RWCDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol for conformers who represent Rakuten App Engine (RAE) endpoints that require a specific scope for access.
 *
 *  @protocol RWCAppEngineScopedEndpoint RWCAppEngineScopedEndpoint.h <RakutenWebClientKit/RWCAppEngineScopedEndpoint.h>
 *  @ingroup RWCAppEngine
 */
@protocol RWCAppEngineScopedEndpoint

/**
 *  The required scope (requested when generating access tokens) for accessing the receiving endpoint
 */
+ (NSString *)requiredScopePermission;

@end

NS_ASSUME_NONNULL_END

