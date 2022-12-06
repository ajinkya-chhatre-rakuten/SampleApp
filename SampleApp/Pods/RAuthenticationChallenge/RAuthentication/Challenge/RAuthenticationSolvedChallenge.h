/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationChallenge/RAuthenticationChallengeDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Represent a solved challenge.
 *
 *  @class RAuthenticationSolvedChallenge RAuthenticationSolvedChallenge.h <RAuthentication/RAuthenticationSolvedChallenge.h>
 *  @ingroup RAuthenticationChallengeClient
 */
RAUTH_EXPORT @interface RAuthenticationSolvedChallenge : NSObject<NSCopying>

/**
 * Challenge page identifier.
 */
@property (copy, nonatomic) NSString *pageId;

/**
 * Challenge identifier.
 */
@property (copy, nonatomic) NSString *identifier;

/**
 * Solved challenge result.
 */
@property (copy, nonatomic) NSString *result;

@end

NS_ASSUME_NONNULL_END
