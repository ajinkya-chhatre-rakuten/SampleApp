/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationCore.h>
#import "_RAuthenticationHelpers.h"

@implementation RAuthenticationSettings
- (BOOL)isValid
{
    return self.clientId.length && self.clientSecret.length && self.baseURL.absoluteString.length && self.requestTimeoutInterval > 0;
}

- (BOOL)isEqualToSettings:(RAuthenticationSettings *)other
{
    if (![other isMemberOfClass:self.class] || other.hash != self.hash) { return NO; }
    return
        _RAuthenticationObjectsEqual(_clientId,     other.clientId)     &&
        _RAuthenticationObjectsEqual(_clientSecret, other.clientSecret) &&
        _RAuthenticationObjectsEqual(_baseURL,      other.baseURL);
}

#pragma mark NSObject
- (instancetype)init
{
    if ((self = [super init]))
    {
        _requestTimeoutInterval = 60.0;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> clientId=\"%@\", clientSecret=\"%@\", baseURL=\"%@\", requestTimeoutInterval=%@",
            NSStringFromClass(self.class),
            self,
            self.clientId,
            self.clientSecret,
            self.baseURL.absoluteString,
            @(self.requestTimeoutInterval)];
}

- (NSUInteger)hash
{
    return self.clientId.hash ^ self.clientSecret.hash ^ self.baseURL.hash;
}

- (BOOL)isEqual:(id)other
{
    if (other == self) { return YES; }
    if (![other isKindOfClass:self.class]) { return NO; }
    return [self isEqualToSettings:(RAuthenticationSettings *)other];
}

#pragma mark <NSCopying>
- (instancetype)copyWithZone:(NSZone *)zone
{
    RAuthenticationSettings *copy = [[self.class allocWithZone:zone] init];
    copy.clientId                   = self.clientId;
    copy.clientSecret               = self.clientSecret;
    copy.baseURL                    = self.baseURL;
    copy.requestTimeoutInterval     = self.requestTimeoutInterval;
    return copy;
}

#pragma mark <NSSecureCoding>
+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark <NSCoding>

/*
 * Local keys used for NSCoding. Should not be modified, even if the properties get renamed.
 */
static NSString * const kClientIdKey                   = @"clientId";
static NSString * const kClientSecretKey               = @"clientSecret";
static NSString * const kBaseURLKey                    = @"baseURL";
static NSString * const kRequestTimeoutInterval        = @"requestTimeoutInterval";

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.clientId                   forKey:kClientIdKey];
    [coder encodeObject:self.clientSecret               forKey:kClientSecretKey];
    [coder encodeObject:self.baseURL                    forKey:kBaseURLKey];
    [coder encodeDouble:self.requestTimeoutInterval     forKey:kRequestTimeoutInterval];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if ((self = [self init]))
    {
        _clientId                   = (id)[coder decodeObjectOfClass:NSString.class forKey:kClientIdKey];
        _clientSecret               = (id)[coder decodeObjectOfClass:NSString.class forKey:kClientSecretKey];
        _baseURL                    = (id)[coder decodeObjectOfClass:NSURL.class    forKey:kBaseURLKey];
        _requestTimeoutInterval     = [coder decodeDoubleForKey:kRequestTimeoutInterval];
    }
    return self;
}

@end
