#import "RakutenEngineClient.h"

@implementation REClientCredentialsTokenRequestContext

- (NSUInteger)hash
{
    return [[self class] hash];
}

- (BOOL)isEqual:(id)object
{
    if (object == self)
    {
        return YES;
    }
    else if (![object isKindOfClass:[self class]])
    {
        return NO;
    }
    
    return YES;
}


#pragma mark - RETokenRequestContext

- (NSString *)requestURLPath
{
    return @"engine/token";
}


#pragma mark - RWCURLQueryItemSerializable

- (NSArray *)serializeQueryItemsWithError:(out NSError **)error
{
    return @[[RWCURLQueryItem queryItemWithPercentUnencodedKey:@"grant_type" percentUnencodedValue:@"client_credentials"]];
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self init];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // Nothing
}

@end
