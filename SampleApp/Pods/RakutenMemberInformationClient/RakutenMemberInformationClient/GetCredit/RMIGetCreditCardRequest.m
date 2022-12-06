#import "RakutenMemberInformationClient.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation RMIGetCreditCardRequest

- (instancetype)initWithAccessToken:(NSString *)accessToken
{
    if ((self = [super init]))
    {
        _accessToken = [accessToken copy];
    }
    
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
#pragma clang diagnostic pop

- (NSUInteger)hash
{
    return self.accessToken.hash;
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    else if (![object isKindOfClass:[self class]] || (self.hash != [object hash]))
    {
        return NO;
    }
    else
    {
        return [self.accessToken isEqualToString:[object accessToken]];
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithAccessToken:self.accessToken];
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *accessToken = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(accessToken))];
    return [self initWithAccessToken:accessToken];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.accessToken forKey:NSStringFromSelector(@selector(accessToken))];
}

#pragma mark - RWCAppEngineScopedEndpoint

+ (NSString *)requiredScopePermission
{
    return @"memberinfo_read_credit";
}

#pragma mark - RWCURLRequestSerializable

- (NSURLRequest *)serializeURLRequestWithConfiguration:(RWCURLRequestConfiguration *)configuration
                                                 error:(out NSError **)error
{
    static NSString *path = @"/engine/api/MemberInformation/GetCredit/20120425";
    
    NSURL *baseURL = configuration.baseURL?: [NSURL URLWithString:RMIDefaultBaseURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[baseURL URLByAppendingPathComponent:path]];
    
    NSMutableDictionary *HTTPHeaderFields = [@{@"Accept": @"application/json",
                                               @"Authorization": [NSString stringWithFormat:@"OAuth2 %@", self.accessToken]} mutableCopy];
    
    if ([configuration HTTPHeaderFields])
    {
        [HTTPHeaderFields addEntriesFromDictionary:[configuration HTTPHeaderFields]];
    }
    
    [request setAllHTTPHeaderFields:HTTPHeaderFields];
    
    if (configuration && configuration.cachePolicy != NSURLRequestUseProtocolCachePolicy)
    {
        [request setCachePolicy:configuration.cachePolicy];
    }
    
    return [request copy];
}

@end

@implementation RMIGetCreditCardRequest (RMIConvenience)

+ (instancetype)requestWithAccessToken:(NSString *)accessToken
{
    return [[self alloc] initWithAccessToken:accessToken];
}

@end

#pragma clang diagnostic pop
