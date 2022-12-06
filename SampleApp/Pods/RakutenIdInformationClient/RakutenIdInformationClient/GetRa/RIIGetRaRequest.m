/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import "RakutenIdInformationClient.h"

@implementation RIIGetRaRequest

- (instancetype)initWithAccessToken:(NSString *)accessToken
{
    NSParameterAssert(accessToken);

    if ((self = [super init]))
    {
        _accessToken = [accessToken copy];
    }

    return self;
}


- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    __builtin_unreachable();
}


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
    else if (![object isKindOfClass:[self class]] || self.hash != [object hash])
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
    return @"idinfo_read_ra";
}


#pragma mark - RWCURLRequestSerializable

- (NSURLRequest *)serializeURLRequestWithConfiguration:(RWCURLRequestConfiguration *)configuration
                                                 error:(out NSError **)error
{
    static NSString *path = @"engine/api/IdInformation/GetRa/20110601";

    NSURL *baseURL = configuration.baseURL ?: [NSURL URLWithString:RIIDefaultBaseURLString];
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


@implementation RIIGetRaRequest (RIIConvenience)

+ (instancetype)requestWithAccessToken:(NSString *)accessToken
{
    return [[self alloc] initWithAccessToken:accessToken];
}

@end
