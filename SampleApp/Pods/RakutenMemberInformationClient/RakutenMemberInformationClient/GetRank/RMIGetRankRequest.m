#import "RakutenMemberInformationClient.h"

@implementation RMIGetRankRequest

- (instancetype)initWithAccessToken:(NSString *)accessToken serviceIdentifier:(NSString *)serviceIdentifier
{
    NSParameterAssert(accessToken);
    NSParameterAssert(serviceIdentifier);
    
    if ((self = [super init]))
    {
        _accessToken = [accessToken copy];
        _serviceIdentifier = serviceIdentifier;
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
    return self.accessToken.hash ^ self.serviceIdentifier.hash;
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
        return [self.accessToken isEqualToString:[object accessToken]] && [self.serviceIdentifier isEqualToString:[object serviceIdentifier]];
    }
}

#pragma mark - Class properties

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
static RMIGetRankEndpoint _endpoint = RMIGetRankLegacyEndpoint;

+ (RMIGetRankEndpoint)endpoint
{
    return _endpoint;
}

+ (void)setEndpoint:(RMIGetRankEndpoint)endpoint
{
    _endpoint = endpoint;
}
#pragma clang diagnostic pop

#pragma mark - Private methods

+ (NSString *)requestPath
{
    switch (_endpoint) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        case RMIGetRankLegacyEndpoint:
#if DEBUG
            NSLog(@"😱 MemberInformation/GetRank is deprecated and insecure: you should migrate your app to using the new MemberInformation/GetRankSafe API, which requires the 'memberinfo_read_rank_safe' RAE scope. When your app is configured for using MemberInformation/GetRankSafe, simply add the following line of code when your application launches:\n\n\tRMIGetRankRequest.endpoint = RMIGetRankSafeEndpoint;\n\nAlso, don't forget to request the new scope when you authenticate!");
#endif
            return @"/engine/api/MemberInformation/GetRank/20120808";
#pragma clang diagnostic pop

        case RMIGetRankSafeEndpoint:
            return @"/engine/api/MemberInformation/GetRankSafe/20170314";

        default:
            return nil;
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithAccessToken:self.accessToken serviceIdentifier:self.serviceIdentifier];
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
    NSString *serviceIdentifier = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(serviceIdentifier))];
    return [self initWithAccessToken:accessToken serviceIdentifier:serviceIdentifier];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.accessToken forKey:NSStringFromSelector(@selector(accessToken))];
    [aCoder encodeObject:self.serviceIdentifier forKey:NSStringFromSelector(@selector(serviceIdentifier))];
}


#pragma mark - RWCAppEngineScopedEndpoint

+ (NSString *)requiredScopePermission
{
    switch (_endpoint) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        case RMIGetRankLegacyEndpoint:
            return @"memberinfo_read_rank";
#pragma clang diagnostic pop

        case RMIGetRankSafeEndpoint:
            return @"memberinfo_read_rank_safe";

        default:
            return nil;
    }
}


#pragma mark - RWCURLQueryItemSerializable

- (NSArray *)serializeQueryItemsWithError:(out NSError **)error
{
    return @[[RWCURLQueryItem queryItemWithPercentUnencodedKey:@"service_id" percentUnencodedValue:self.serviceIdentifier]];
}

#pragma mark - RWCURLRequestSerializable

- (NSURLRequest *)serializeURLRequestWithConfiguration:(RWCURLRequestConfiguration *)configuration
                                                 error:(out NSError **)error
{
    NSArray *queryItems = [self serializeQueryItemsWithError:error];
    if (!queryItems)
    {
        return nil;
    }
    
    NSString *path = [self.class requestPath];
    NSString *baseURLString = configuration.baseURL ? configuration.baseURL.absoluteString : RMIDefaultBaseURLString;
    NSURLComponents *URLComponents = [NSURLComponents componentsWithString:baseURLString];
    URLComponents.path = path;
    URLComponents.query = [RWCURLQueryItem queryStringFromQueryItems:queryItems];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URLComponents.URL];
    
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


@implementation RMIGetRankRequest (RMIConvenience)

+ (instancetype)requestWithAccessToken:(NSString *)accessToken serviceIdentifier:(NSString *)serviceIdentifier
{
    return [[self alloc] initWithAccessToken:accessToken serviceIdentifier:serviceIdentifier];
}

@end

