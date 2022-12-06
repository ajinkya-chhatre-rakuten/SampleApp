#import "RPushPNPRegisterDeviceRequest.h"
#import "_RPushPNPHelpers.h"

@interface RPushPNPRegisterDeviceRequest()
@end

@implementation RPushPNPRegisterDeviceRequest

- (instancetype)initWithAccessToken:(NSString *)accessToken pnpClientIdentifier:(NSString *)pnpClientIdentifier pnpClientSecret:(NSString *)pnpClientSecret deviceToken:(NSData *)deviceToken {
    self = [super initWithAccessToken:accessToken pnpClientIdentifier:pnpClientIdentifier pnpClientSecret:pnpClientSecret deviceToken:deviceToken];
    
    if (self) {
    }
    
    return self;
}

- (NSUInteger)hash {
    return super.hash ^ self.safePreviousDeviceToken.hash ^ self.deviceName.hash ^ self.options.hash;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    else if (![object isKindOfClass:[self class]] || (self.hash != [object hash])) {
        return NO;
    }
    else {
        RPushPNPRegisterDeviceRequest *other = object;
        return [super isEqual:other] &&
        _RPushPNPEqualObjects(self.safePreviousDeviceToken, other.safePreviousDeviceToken) &&
        _RPushPNPEqualObjects(self.deviceName, other.deviceName) &&
        _RPushPNPEqualObjects(self.options, other.options);
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    RPushPNPRegisterDeviceRequest *copy = [super copyWithZone:zone];
    copy.deviceName = self.deviceName;
    copy.safePreviousDeviceToken = self.safePreviousDeviceToken;
    copy.options = self.options;

    return copy;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _deviceName = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(deviceName))];
        _options = [aDecoder decodeObjectOfClass:[NSDictionary class] forKey:NSStringFromSelector(@selector(options))];
        _safePreviousDeviceToken = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(safePreviousDeviceToken))];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.safePreviousDeviceToken forKey:NSStringFromSelector(@selector(safePreviousDeviceToken))];
    [aCoder encodeObject:self.deviceName forKey:NSStringFromSelector(@selector(deviceName))];
    [aCoder encodeObject:self.options forKey:NSStringFromSelector(@selector(options))];
}

#pragma mark - RWCAppEngineScopedEndpoint

+ (NSString *)requiredScopePermission
{
    return @"pnp_ios_register";
}

#pragma mark - RWCURLQueryItemSerializable

- (NSArray *)serializeQueryItemsWithError:(out NSError**)error
{
    NSMutableArray *queryItems = [NSMutableArray array];

    void (^add_query_item)(NSString *key, NSString *value) = ^(NSString *key, NSString *value) {
        if (value.length > 0)
        {
            [queryItems addObject:[RWCURLQueryItem queryItemWithPercentUnencodedKey:key percentUnencodedValue:value]];
        }
    };

    add_query_item(@"pnpClientId", self.pnpClientIdentifier);
    add_query_item(@"pnpClientSecret", self.pnpClientSecret);
    add_query_item(@"deviceId", _RPushPNPDataToHex(self.deviceToken));
    add_query_item(@"previousDeviceId", self.safePreviousDeviceToken);
    add_query_item(@"userid", self.userIdentifier);
    add_query_item(@"deviceName", self.deviceName);
    
    // Opts
    
    [self updateOptionsWithRPCookie:_rpCookie.value];
    NSString *optsQueryString = [self opts];
    if (optsQueryString) {
        add_query_item(@"opts", optsQueryString);
    }
    
    return [queryItems copy];
}

#pragma mark - Opts

- (NSString * _Nullable)opts {
    if (self.options.count)
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.options options:0 error:nil];
        NSString *queryString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return queryString;
    }
    
    return nil;
}

#pragma mark - RPCookie

- (void)updateOptionsWithRPCookie:(NSString * _Nullable)rpCookieValue
{
    NSMutableDictionary *optsWithCookieDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"type": @"set_tags", @"body": @{}}];
    
    NSString *mode = self.options.count > 0 ? @"append|update|remove": @"append|update";
    
    if (rpCookieValue == nil) {
        NSMutableDictionary *tagsDictionary = [NSMutableDictionary dictionaryWithDictionary:self.options];
        optsWithCookieDictionary[@"body"] = @{@"mode": mode, @"tags": [tagsDictionary copy]};
        
    } else if (self.options.count > 0) {
        NSMutableDictionary *tagsDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"_rpCookie": rpCookieValue}];
        [tagsDictionary addEntriesFromDictionary:self.options];
        
        optsWithCookieDictionary[@"body"] = @{@"mode": mode, @"tags": [tagsDictionary copy]};
        
    } else {
        optsWithCookieDictionary[@"body"] = @{@"mode": mode, @"tags": @{@"_rpCookie": rpCookieValue}};
    }
    
    self.options = [optsWithCookieDictionary copy];
}

#pragma mark - RWCURLRequestSerializable

- (NSURLRequest *)serializeURLRequestWithConfiguration:(RWCURLRequestConfiguration *)configuration
                                                 error:(out NSError**)error
{
    return [NSURLRequest rpushpnp_requestAPI:@"PNPiOS/RegisterDevice"
                                     version:20160301
                               configuration:configuration
                                 accessToken:self.accessToken
                       queryItemSerializable:self
                                       error:error];
}

@end

@implementation RPushPNPRegisterDeviceRequest (RPushPNPConvenience)

+ (instancetype)requestWithAccessToken:(NSString *)accessToken
                   pnpClientIdentifier:(NSString *)pnpClientIdentifier
                       pnpClientSecret:(NSString *)pnpClientSecret
                           deviceToken:(NSData *)deviceToken
{
    NSParameterAssert(deviceToken);
    return [[self alloc] initWithAccessToken:accessToken
                         pnpClientIdentifier:pnpClientIdentifier
                             pnpClientSecret:pnpClientSecret
                                 deviceToken:deviceToken];
}

@end
