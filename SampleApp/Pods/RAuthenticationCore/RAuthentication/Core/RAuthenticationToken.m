/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationCore.h>
#import "_RAuthenticationHelpers.h"

static NSString *const _RAuthenticationVersion = @"4.2.0";

@implementation RAuthenticationToken

- (BOOL)isValid
{
    return self.accessToken.length && !(self.expirationDate && (self.expirationDate.timeIntervalSinceReferenceDate <= NSDate.timeIntervalSinceReferenceDate + 1.0));
}

- (BOOL)isEqualToToken:(RAuthenticationToken *)other
{
    if (![other isMemberOfClass:self.class] || other.hash != self.hash) { return NO; }
    return
        _RAuthenticationObjectsEqual(_accessToken,    other.accessToken)    &&
        _RAuthenticationObjectsEqual(_refreshToken,   other.refreshToken)   &&
        _RAuthenticationObjectsEqual(_expirationDate, other.expirationDate) &&
        _RAuthenticationObjectsEqual(_scopes,         other.scopes)         &&
        _RAuthenticationObjectsEqual(_tokenType,      other.tokenType);
}

#pragma mark NSObject

- (instancetype)init
{
    if ((self = [super init]))
    {
        _tokenType = @"BEARER";
    }
    return self;
}

- (NSUInteger)hash
{
    return _accessToken.hash ^ _refreshToken.hash ^ _expirationDate.hash ^ _scopes.hash ^ _tokenType.hash;
}

- (BOOL)isEqual:(id)other
{
    if (other == self) { return YES; }
    if (![other isKindOfClass:self.class]) { return NO; }
    return [self isEqualToToken:(RAuthenticationToken *)other];
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"<%@: %p>"
            @"\n\t   accessToken=%@"
            @"\n\t  refreshToken=%@"
            @"\n\texpirationDate=%@"
            @"\n\t        scopes=%@"
            @"\n\t     tokenType=%@",
            NSStringFromClass(self.class), self,
            _accessToken,
            _refreshToken,
            _expirationDate,
            [_scopes.allObjects componentsJoinedByString:@","],
            _tokenType];
}

#pragma mark <NSCopying>
- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) __strong copy = [[self.class allocWithZone:zone] init];
    copy.accessToken          = self.accessToken;
    copy.refreshToken         = self.refreshToken;
    copy.expirationDate       = self.expirationDate;
    copy.scopes               = self.scopes;
    copy.tokenType            = self.tokenType;
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
static NSString * const kVersionKey              = @"version";
static NSString * const kAccessTokenKey          = @"accessToken";
static NSString * const kRefreshTokenKey         = @"refreshToken";
static NSString * const kExpirationDateKey       = @"expirationDate";
static NSString * const kScopesKey               = @"scopes";
static NSString * const kTokenTypeKey            = @"tokenType";

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_RAuthenticationVersion forKey:kVersionKey]; // Kept this to prevent other app think it's a 2.x token
    [coder encodeObject:_accessToken           forKey:kAccessTokenKey];
    [coder encodeObject:_refreshToken          forKey:kRefreshTokenKey];
    [coder encodeObject:_expirationDate        forKey:kExpirationDateKey];
    [coder encodeObject:_scopes                forKey:kScopesKey];
    [coder encodeObject:_tokenType             forKey:kTokenTypeKey];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if ((self = [self init]))
    {
        _accessToken          = (id)[coder decodeObjectOfClass:NSString.class     forKey:kAccessTokenKey];
        _refreshToken         = (id)[coder decodeObjectOfClass:NSString.class     forKey:kRefreshTokenKey];
        _expirationDate       = (id)[coder decodeObjectOfClass:NSDate.class       forKey:kExpirationDateKey];
        _scopes               = (id)[coder decodeObjectOfClass:NSSet.class        forKey:kScopesKey];
        _tokenType            = (id)[coder decodeObjectOfClass:NSString.class     forKey:kTokenTypeKey];
    }
    return self;
}

#pragma mark Data migration

+ (RAuthenticationToken *)legacyStoredToken
{
    return nil;
}

@end
