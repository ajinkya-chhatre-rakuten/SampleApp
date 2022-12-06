#import "RakutenEngineClient.h"

static BOOL objects_equal(id objA, id objB)
{
    return (!objA && !objB) || (objA && objB && [objA isEqual:objB]);
}

@implementation RERevokeTokenRequest

- (instancetype)initWithClientIdentifier:(NSString *)clientIdentifier
                            clientSecret:(NSString *)clientSecret
                             accessToken:(NSString *)accessToken
{
    NSParameterAssert(clientIdentifier);
    NSParameterAssert(clientSecret);
    NSParameterAssert(accessToken);
    
    if ((self = [super init]))
    {
        _clientIdentifier = [clientIdentifier copy];
        _clientSecret = [clientSecret copy];
        _accessToken = [accessToken copy];
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
    return self.clientIdentifier.hash ^ self.clientSecret.hash ^ self.accessToken.hash;
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
    
    RERevokeTokenRequest *other = object;
    return objects_equal(self.clientIdentifier, other.clientIdentifier) &&
           objects_equal(self.clientSecret, other.clientSecret) &&
           objects_equal(self.accessToken, other.accessToken);
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithClientIdentifier:self.clientIdentifier
                                                          clientSecret:self.clientSecret
                                                           accessToken:self.accessToken];
}


#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *clientIdentifier = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(clientIdentifier))];
    NSString *clientSecret = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(clientSecret))];
    NSString *accessToken = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(accessToken))];
    
    return [self initWithClientIdentifier:clientIdentifier clientSecret:clientSecret accessToken:accessToken];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.clientIdentifier forKey:NSStringFromSelector(@selector(clientIdentifier))];
    [aCoder encodeObject:self.clientSecret forKey:NSStringFromSelector(@selector(clientSecret))];
    [aCoder encodeObject:self.accessToken forKey:NSStringFromSelector(@selector(accessToken))];
}


#pragma mark - RWCURLQueryItemSerializable

- (NSArray *)serializeQueryItemsWithError:(out NSError **)error
{
    NSArray *queryItems = @[[RWCURLQueryItem queryItemWithPercentUnencodedKey:@"client_id" percentUnencodedValue:self.clientIdentifier],
                            [RWCURLQueryItem queryItemWithPercentUnencodedKey:@"client_secret" percentUnencodedValue:self.clientSecret],
                            [RWCURLQueryItem queryItemWithPercentUnencodedKey:@"access_token" percentUnencodedValue:self.accessToken]];
    
    return [queryItems sortedArrayUsingSelector:@selector(compare:)];
}


#pragma mark - RWCURLRequestSerializable

- (NSURLRequest *)serializeURLRequestWithConfiguration:(RWCURLRequestConfiguration *)configuration error:(out NSError **)error
{
    static NSString *path = @"engine/token_cancel";
    
    NSArray *queryItems = [self serializeQueryItemsWithError:error];
    if (!queryItems)
    {
        return nil;
    }
    
    NSURL *baseURL = configuration.baseURL ?: [NSURL URLWithString:REDefaultBaseURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[baseURL URLByAppendingPathComponent:path]];
    request.HTTPMethod = @"POST";
    
    NSMutableDictionary *HTTPHeaderFields = [@{@"Accept": @"application/json",
                                               @"Content-Type": @"application/x-www-form-urlencoded; charset=utf-8"} mutableCopy];
    
    if ([configuration HTTPHeaderFields])
    {
        [HTTPHeaderFields addEntriesFromDictionary:[configuration HTTPHeaderFields]];
    }
    
    [request setAllHTTPHeaderFields:HTTPHeaderFields];
    
    if (configuration && configuration.cachePolicy != NSURLRequestUseProtocolCachePolicy)
    {
        [request setCachePolicy:configuration.cachePolicy];
    }
    
    [request setHTTPBody:[RWCURLQueryItem formDataFromQueryItems:queryItems]];
    
    return [request copy];
}

@end

@implementation RERevokeTokenRequest (REConvenience)

+ (instancetype)requestWithClientIdentifier:(NSString *)clientIdentifier
                               clientSecret:(NSString *)clientSecret
                                accessToken:(NSString *)accessToken
{
    return [[self alloc] initWithClientIdentifier:clientIdentifier clientSecret:clientSecret accessToken:accessToken];
}

@end
