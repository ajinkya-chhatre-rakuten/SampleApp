#import "RakutenEngineClient.h"

@implementation RERefreshTokenRequestContext

- (instancetype)initWithRefreshToken:(NSString *)refreshToken
{
    NSParameterAssert(refreshToken);
    
    if ((self = [super init]))
    {
        _refreshToken = [refreshToken copy];
    }
    
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
#pragma clang diagnostic pop

- (NSUInteger)hash
{
    return self.refreshToken.hash;
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
    
    RERefreshTokenRequestContext *other = object;
    return [self.refreshToken isEqualToString:other.refreshToken];
}


#pragma mark - RETokenRequestContext

- (NSString *)requestURLPath
{
    return @"engine/token";
}


#pragma mark - RWCURLQueryItemSerializable

- (NSArray *)serializeQueryItemsWithError:(out NSError **)error
{
    return @[[RWCURLQueryItem queryItemWithPercentUnencodedKey:@"grant_type" percentUnencodedValue:@"refresh_token"],
             [RWCURLQueryItem queryItemWithPercentUnencodedKey:@"refresh_token" percentUnencodedValue:self.refreshToken]];
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithRefreshToken:self.refreshToken];
}


#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *refreshToken = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(refreshToken))];
    return [self initWithRefreshToken:refreshToken];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.refreshToken forKey:NSStringFromSelector(@selector(refreshToken))];
}

@end
