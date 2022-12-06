#import "RakutenEngineClient.h"

static BOOL objects_equal(id objA, id objB)
{
    return (!objA && !objB) || (objA && objB && [objA isEqual:objB]);
}

static NSString *create_scope_component_from_lifespan(RETokenLifespan tokenLifespan)
{
    switch (tokenLifespan)
    {
        case RETokenLifespan1Hour:
            return @"1Hour";
        case RETokenLifespan90Days:
            return @"90days";
        case RETokenLifespan365Days:
            return @"365days";
        default:
            return nil;
    }
}

static NSString *const RETokenRequestContextClassNameKey = @"RETokenRequestContextClassNameKey";

@implementation RETokenRequest

- (instancetype)initWithClientIdentifier:(NSString *)clientIdentifier
                            clientSecret:(NSString *)clientSecret
                                 context:(id<RETokenRequestContext>)context
{
    NSParameterAssert(clientIdentifier);
    NSParameterAssert(clientSecret);
    NSParameterAssert(context);
    
    if ((self = [super init]))
    {
        _clientIdentifier = [clientIdentifier copy];
        _clientSecret = [clientSecret copy];
        _context = [(id)context copy];
        
        _accessTokenLifespan = RETokenLifespanCustom;
        _refreshTokenLifespan = RETokenLifespanCustom;
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

- (void)setAccessTokenLifespan:(RETokenLifespan)accessTokenLifespan
{
    if (_accessTokenLifespan != accessTokenLifespan)
    {
        _accessTokenLifespan = accessTokenLifespan;
        
        if (_accessTokenLifespan != RETokenLifespanCustom)
        {
            NSMutableSet *mutableScopes = [NSMutableSet setWithSet:_scopes];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF ENDSWITH %@)", @"@Access"];
            [mutableScopes filterUsingPredicate:predicate];
            _scopes = [mutableScopes copy];
        }
    }
}

- (void)setRefreshTokenLifespan:(RETokenLifespan)refreshTokenLifespan
{
    if (_refreshTokenLifespan != refreshTokenLifespan)
    {
        _refreshTokenLifespan = refreshTokenLifespan;
        
        if (_refreshTokenLifespan != RETokenLifespanCustom)
        {
            NSMutableSet *mutableScopes = [NSMutableSet setWithSet:_scopes];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF ENDSWITH %@)", @"@Refresh"];
            [mutableScopes filterUsingPredicate:predicate];
            _scopes = [mutableScopes copy];
        }
    }
}

- (void)setScopes:(NSSet *)scopes
{
    if (![_scopes isEqualToSet:scopes])
    {
        _scopes = [scopes copy];
        
        NSPredicate *accessLifespanPredicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH %@", @"@Access"];
        BOOL hasAccessLifespanScope = [[_scopes filteredSetUsingPredicate:accessLifespanPredicate] count] > 0;
        if (hasAccessLifespanScope)
        {
            _accessTokenLifespan = RETokenLifespanCustom;
        }
        
        NSPredicate *refreshLifespanPredicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH %@", @"@Refresh"];
        BOOL hasRefreshLifespanScope = [[_scopes filteredSetUsingPredicate:refreshLifespanPredicate] count] > 0;
        if (hasRefreshLifespanScope)
        {
            _refreshTokenLifespan = RETokenLifespanCustom;
        }
    }
}

- (NSUInteger)hash
{
    return self.clientIdentifier.hash ^
           self.clientSecret.hash ^
           self.context.hash ^
           self.accessTokenLifespan ^
           self.refreshTokenLifespan ^
           self.scopes.hash;
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
    
    RETokenRequest *other = object;
    return objects_equal(self.clientIdentifier, other.clientIdentifier) &&
           objects_equal(self.clientSecret, other.clientSecret) &&
           objects_equal(self.context, other.context) &&
           self.accessTokenLifespan == other.accessTokenLifespan &&
           self.refreshTokenLifespan == other.refreshTokenLifespan &&
           objects_equal(self.scopes, other.scopes);
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    RETokenRequest *copy = [[[self class] allocWithZone:zone] initWithClientIdentifier:self.clientIdentifier
                                                                          clientSecret:self.clientSecret
                                                                               context:self.context];
    
    copy.accessTokenLifespan = self.accessTokenLifespan;
    copy.refreshTokenLifespan = self.refreshTokenLifespan;
    copy.scopes = self.scopes;
    
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
    NSString *clientIdentifier = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(clientIdentifier))];
    NSString *clientSecret = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(clientSecret))];
    NSString *contextClassString = [aDecoder decodeObjectOfClass:[NSString class] forKey:RETokenRequestContextClassNameKey];
    id<RETokenRequestContext> context = [aDecoder decodeObjectOfClass:NSClassFromString(contextClassString) forKey:NSStringFromSelector(@selector(context))];
    
    if ((self = [self initWithClientIdentifier:clientIdentifier
                                  clientSecret:clientSecret
                                       context:context]))
    {
        _accessTokenLifespan = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(accessTokenLifespan))];
        _refreshTokenLifespan = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(refreshTokenLifespan))];
        _scopes = [aDecoder decodeObjectOfClasses:[NSSet setWithObjects:[NSSet class], [NSString class], nil] forKey:NSStringFromSelector(@selector(scopes))];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.clientIdentifier forKey:NSStringFromSelector(@selector(clientIdentifier))];
    [aCoder encodeObject:self.clientSecret forKey:NSStringFromSelector(@selector(clientSecret))];
    
    [aCoder encodeObject:NSStringFromClass([self.context class]) forKey:RETokenRequestContextClassNameKey];
    [aCoder encodeObject:self.context forKey:NSStringFromSelector(@selector(context))];
    
    [aCoder encodeInteger:self.accessTokenLifespan forKey:NSStringFromSelector(@selector(accessTokenLifespan))];
    [aCoder encodeInteger:self.refreshTokenLifespan forKey:NSStringFromSelector(@selector(refreshTokenLifespan))];
    [aCoder encodeObject:self.scopes forKey:NSStringFromSelector(@selector(scopes))];
}


#pragma mark - RWCURLQueryItemSerializable

- (NSArray *)serializeQueryItemsWithError:(out NSError **)error
{
    NSArray *contextQueryItems = [self.context serializeQueryItemsWithError:error];
    if (!contextQueryItems)
    {
        return nil;
    }
    
    NSMutableArray *queryItems = [NSMutableArray arrayWithArray:contextQueryItems];
    
    [queryItems addObject:[RWCURLQueryItem queryItemWithPercentUnencodedKey:@"client_id" percentUnencodedValue:self.clientIdentifier]];
    [queryItems addObject:[RWCURLQueryItem queryItemWithPercentUnencodedKey:@"client_secret" percentUnencodedValue:self.clientSecret]];
    
    NSMutableSet *mutableScopes = [NSMutableSet setWithSet:self.scopes];
    
    NSString *accessTokenLifespanScopeComponent = create_scope_component_from_lifespan(self.accessTokenLifespan);
    if (accessTokenLifespanScopeComponent)
    {
        [mutableScopes addObject:[accessTokenLifespanScopeComponent stringByAppendingString:@"@Access"]];
    }
    
    NSString *refreshTokenLifespanScopeComponent = create_scope_component_from_lifespan(self.refreshTokenLifespan);
    if (refreshTokenLifespanScopeComponent)
    {
        [mutableScopes addObject:[refreshTokenLifespanScopeComponent stringByAppendingString:@"@Refresh"]];
    }
    
    NSString *scopeString = [[[mutableScopes allObjects] sortedArrayUsingSelector:@selector(compare:)] componentsJoinedByString:@","];
    
    if (scopeString.length > 0)
    {
        [queryItems addObject:[RWCURLQueryItem queryItemWithPercentUnencodedKey:@"scope" percentUnencodedValue:scopeString]];
    }
    
    [queryItems sortUsingSelector:@selector(compare:)];
    return [queryItems copy];
}


#pragma mark - RWCURLRequestSerializable

- (NSURLRequest *)serializeURLRequestWithConfiguration:(RWCURLRequestConfiguration *)configuration error:(out NSError **)error
{
    NSArray *queryItems = [self serializeQueryItemsWithError:error];
    if (!queryItems)
    {
        return nil;
    }
    
    NSURL *baseURL = configuration.baseURL ?: [NSURL URLWithString:REDefaultBaseURLString];
    NSURL *requestURL = [baseURL URLByAppendingPathComponent:[self.context requestURLPath]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    request.HTTPMethod = @"POST";

    NSArray *preferredLanguages = NSLocale.preferredLanguages;
    NSMutableArray *acceptLanguagesComponents =[NSMutableArray arrayWithCapacity:preferredLanguages.count];
    [preferredLanguages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        float q = 1.0f - (idx * 0.1f);
        [acceptLanguagesComponents addObject:[NSString stringWithFormat:@"%@;q=%0.1g", obj, q]];
        *stop = q <= 0.5f;
    }];
    NSString *acceptLanguages = [acceptLanguagesComponents componentsJoinedByString:@", "];

    NSMutableDictionary *HTTPHeaderFields = [@{@"Accept": @"application/json",
                                               @"Accept-Language": acceptLanguages,
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

+ (instancetype)clientCredentialsTokenRequestWithClientIdentifier:(NSString *)clientIdentifier clientSecret:(NSString *)clientSecret
{
    REClientCredentialsTokenRequestContext *context = [REClientCredentialsTokenRequestContext new];
    RETokenRequest *request = [[self alloc] initWithClientIdentifier:clientIdentifier
                                                        clientSecret:clientSecret
                                                             context:context];
    return request;
}

+ (instancetype)japanPasswordTokenRequestWithClientIdentifier:(NSString *)clientIdentifier
                                                 clientSecret:(NSString *)clientSecret
                                                     username:(NSString *)username
                                                     password:(NSString *)password
{
    return [self japanPasswordTokenRequestWithClientIdentifier:clientIdentifier
                                                  clientSecret:clientSecret
                                                      username:username
                                                      password:password
                                             serviceIdentifier:nil
                                          privacyPolicyVersion:nil];
}

+ (instancetype)japanPasswordTokenRequestWithClientIdentifier:(NSString *)clientIdentifier
                                                 clientSecret:(NSString *)clientSecret
                                                     username:(NSString *)username
                                                     password:(NSString *)password
                                            serviceIdentifier:(nullable NSString *)serviceIdentifier
                                         privacyPolicyVersion:(nullable NSString *)privacyPolicyVersion
{
    REJapanPasswordTokenRequestContext *context = [REJapanPasswordTokenRequestContext.alloc initWithUsername:username password:password];
    context.serviceIdentifier    = serviceIdentifier;
    context.privacyPolicyVersion = privacyPolicyVersion;

    return [self.alloc initWithClientIdentifier:clientIdentifier clientSecret:clientSecret context:context];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (instancetype)globalPasswordTokenRequestWithClientIdentifier:(NSString *)clientIdentifier
                                                  clientSecret:(NSString *)clientSecret
                                                      username:(NSString *)username
                                                      password:(NSString *)password
                                         marketplaceIdentifier:(NSString *)marketplaceIdentifier
{
    REGlobalPasswordTokenRequestContext *context = [[REGlobalPasswordTokenRequestContext alloc] initWithUsername:username
                                                                                                        password:password
                                                                                           marketplaceIdentifier:marketplaceIdentifier];
    RETokenRequest *request = [[self alloc] initWithClientIdentifier:clientIdentifier
                                                        clientSecret:clientSecret
                                                             context:context];
    return request;
}
#pragma clang diagnostic pop

+ (instancetype)refreshTokenRequestWithClientIdentifier:(NSString *)clientIdentifier
                                           clientSecret:(NSString *)clientSecret
                                           refreshToken:(NSString *)refreshToken
{
    RERefreshTokenRequestContext *context = [[RERefreshTokenRequestContext alloc] initWithRefreshToken:refreshToken];
    RETokenRequest *request = [[self alloc] initWithClientIdentifier:clientIdentifier
                                                        clientSecret:clientSecret
                                                             context:context];
    return request;
}

@end
