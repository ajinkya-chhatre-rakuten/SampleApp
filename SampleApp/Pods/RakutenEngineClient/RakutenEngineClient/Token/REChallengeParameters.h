/*
 * © Rakuten, Inc.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Represent a solved challenge.
 *
 *  @class REChallengeParameters REChallengeParameters.h <RakutenEngineClient/REChallengeParameters.h>
 *  @ingroup RERequests
 */
@interface REChallengeParameters : NSObject<NSCopying, NSSecureCoding>

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

/**
 *  Create a instance of the receiver with given parameters.
 *
 *  @param pageId     Challenge page identifier.
 *  @param identifier Challenge Identifier.
 *  @param result     Solved challenge result.
 *
 *  @return An initialized instance of the receiver
 */
+ (instancetype)parametersWithPageId:(NSString *)pageId identifier:(NSString *)identifier result:(NSString *)result;

/**
 *  Return a JSON object of the challenge
 *
 *  @return An JSON object
 */
- (id)jsonObject;

@end

NS_ASSUME_NONNULL_END
