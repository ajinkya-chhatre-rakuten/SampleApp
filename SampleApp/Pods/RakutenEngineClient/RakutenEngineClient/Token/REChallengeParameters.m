/*
 * © Rakuten, Inc.
 */

#import "RakutenEngineClient.h"

static BOOL objects_equal(id objA, id objB)
{
    return (!objA && !objB) || (objA && objB && [objA isEqual:objB]);
}

@implementation REChallengeParameters

+ (instancetype)parametersWithPageId:(NSString *)pageId identifier:(NSString *)identifier result:(NSString *)result
{
    if (pageId && identifier && result)
    {
        REChallengeParameters * instance = REChallengeParameters.new;
        instance.pageId = pageId.copy;
        instance.identifier = identifier.copy;
        instance.result = result.copy;
        return instance;
    }
    return nil;
}

- (NSUInteger)hash
{
    return _pageId.hash ^ _identifier.hash ^ _result.hash;
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    else if (![object isKindOfClass:[self class]])
    {
        return NO;
    }
    
    REChallengeParameters *other = object;
    
    return objects_equal(_pageId, other.pageId) &&
    objects_equal(_identifier, other.identifier) &&
    objects_equal(_result, other.result);
}

#pragma mark <NSCopying>
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    REChallengeParameters *copy = [[self.class allocWithZone:zone] init];
    copy.pageId = self.pageId;
    copy.identifier = self.identifier;
    copy.result = self.result;
    return copy;
}

#pragma mark <NSSecureCoding>

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark <NSCoding>

- (instancetype)initWithCoder:(NSCoder *)coder
{
    _pageId = [coder decodeObjectOfClass:NSString.class forKey:NSStringFromSelector(@selector(pageId))];
    _identifier = [coder decodeObjectOfClass:NSString.class forKey:NSStringFromSelector(@selector(identifier))];
    _result = [coder decodeObjectOfClass:NSString.class forKey:NSStringFromSelector(@selector(result))];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_pageId forKey:NSStringFromSelector(@selector(pageId))];
    [coder encodeObject:_identifier forKey:NSStringFromSelector(@selector(identifier))];
    [coder encodeObject:_result forKey:NSStringFromSelector(@selector(result))];
}

- (id)jsonObject
{
    return @{@"pageIdentifier":_pageId, @"challengeId":_identifier, @"challengeResult":_result};
}

@end
