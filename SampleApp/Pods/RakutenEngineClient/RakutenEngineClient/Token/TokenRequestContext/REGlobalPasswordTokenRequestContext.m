#import "RakutenEngineClient.h"

static BOOL objects_equal(id objA, id objB)
{
    return (!objA && !objB) || (objA && objB && [objA isEqual:objB]);
}

@implementation REGlobalPasswordTokenRequestContext

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password marketplaceIdentifier:(NSString *)marketplaceIdentifier
{
    NSParameterAssert(username);
    NSParameterAssert(password);
    NSParameterAssert(marketplaceIdentifier);
    
    if ((self = [super init]))
    {
        _username = [username copy];
        _password = [password copy];
        _marketplaceIdentifier = [marketplaceIdentifier copy];
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
    return self.username.hash ^ self.password.hash ^ self.marketplaceIdentifier.hash ^ self.loginRoute.hash;
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    else if (![object isMemberOfClass:[self class]])
    {
        return NO;
    }
    
    REGlobalPasswordTokenRequestContext *other = object;
    
    return objects_equal(self.username, other.username) &&
           objects_equal(self.password, other.password) &&
           objects_equal(self.marketplaceIdentifier, other.marketplaceIdentifier) &&
           objects_equal(self.loginRoute, other.loginRoute);
}


#pragma mark - RETokenRequestContext

- (NSString *)requestURLPath
{
    return @"engine/gtoken";
}


#pragma mark - RWCURLQueryItemSerializable

- (NSArray *)serializeQueryItemsWithError:(out NSError **)error
{
    NSMutableArray *queryItems = [NSMutableArray array];
    
    [queryItems addObject:[RWCURLQueryItem queryItemWithPercentUnencodedKey:@"username" percentUnencodedValue:self.username]];
    [queryItems addObject:[RWCURLQueryItem queryItemWithPercentUnencodedKey:@"password" percentUnencodedValue:self.password]];
    [queryItems addObject:[RWCURLQueryItem queryItemWithPercentUnencodedKey:@"mall_id" percentUnencodedValue:self.marketplaceIdentifier]];
    
    if (self.loginRoute.length > 0)
    {
        [queryItems addObject:[RWCURLQueryItem queryItemWithPercentUnencodedKey:@"login_route" percentUnencodedValue:self.loginRoute]];
    }
    
    return [queryItems copy];
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    REGlobalPasswordTokenRequestContext *copy = [[[self class] allocWithZone:zone] initWithUsername:self.username
                                                                                           password:self.password
                                                                              marketplaceIdentifier:self.marketplaceIdentifier];
    copy.loginRoute = self.loginRoute;
    
    return copy;
}


#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *username = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(username))];
    NSString *password = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(password))];
    NSString *marketplaceIdentifier = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(marketplaceIdentifier))];
    
    if ((self = [self initWithUsername:username password:password marketplaceIdentifier:marketplaceIdentifier]))
    {
        _loginRoute = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(loginRoute))];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.username forKey:NSStringFromSelector(@selector(username))];
    [aCoder encodeObject:self.password forKey:NSStringFromSelector(@selector(password))];
    [aCoder encodeObject:self.marketplaceIdentifier forKey:NSStringFromSelector(@selector(marketplaceIdentifier))];
    [aCoder encodeObject:self.loginRoute forKey:NSStringFromSelector(@selector(loginRoute))];
}

@end
