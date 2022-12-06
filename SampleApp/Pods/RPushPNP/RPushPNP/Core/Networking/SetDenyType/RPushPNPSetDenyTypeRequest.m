#import "RPushPNPSetDenyTypeRequest.h"
#import "_RPushPNPHelpers.h"

@implementation RPushPNPSetDenyTypeRequest

- (NSUInteger)hash {
    return super.hash ^ self.pushFilter.hash;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    else if (![object isKindOfClass:[self class]] || (self.hash != [object hash])) {
        return NO;
    }
    else {
        RPushPNPSetDenyTypeRequest *other = object;
        return [super isEqual:other] &&
        _RPushPNPEqualObjects(self.pushFilter, other.pushFilter);
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    RPushPNPSetDenyTypeRequest *copy = [super copyWithZone:zone];
    copy.pushFilter = self.pushFilter;

    return copy;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _pushFilter = [aDecoder decodeObjectOfClass:[NSDictionary class] forKey:NSStringFromSelector(@selector(pushFilter))];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.pushFilter forKey:NSStringFromSelector(@selector(pushFilter))];
}

#pragma mark - RWCAppEngineScopedEndpoint

+ (NSString *)requiredScopePermission {
    return @"pnp_ios_denytype_update";
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
    add_query_item(@"userid", self.userIdentifier);
    if (self.pushFilter.count)
    {
        NSMutableArray *pushItems = [NSMutableArray array];
        for (NSString *key in self.pushFilter)
        {
            id value = [self.pushFilter objectForKey:key];
            [pushItems addObject:[RWCURLQueryItem queryItemWithPercentUnencodedKey:key percentUnencodedValue:[RWCParserUtilities stringWithObject:value]]];
        }
        NSString *queryString = [RWCURLQueryItem queryStringFromQueryItems:[pushItems copy]];
        add_query_item(@"pushtype", queryString);
    }
    return [queryItems copy];
}

#pragma mark - RWCURLRequestSerializable

- (NSURLRequest *)serializeURLRequestWithConfiguration:(RWCURLRequestConfiguration *)configuration
                                                 error:(out NSError**)error
{
    return [NSURLRequest rpushpnp_requestAPI:@"PNPiOS/UpdateDenyType"
                                     version:20160301
                               configuration:configuration
                                 accessToken:self.accessToken
                       queryItemSerializable:self
                                       error:error];
}

@end

@implementation RPushPNPSetDenyTypeRequest (RPNPConvenience)

+ (instancetype)requestWithAccessToken:(NSString *)accessToken
                   pnpClientIdentifier:(NSString *)pnpClientIdentifier
                       pnpClientSecret:(NSString *)pnpClientSecret
                            pushFilter:(NSDictionary *)pushFilter
{
    NSParameterAssert(pushFilter);
    RPushPNPSetDenyTypeRequest *request = [[self alloc] initWithAccessToken:accessToken
                                                        pnpClientIdentifier:pnpClientIdentifier
                                                            pnpClientSecret:pnpClientSecret
                                                                deviceToken:nil];
    request.pushFilter = pushFilter;
    return request;
}

@end
