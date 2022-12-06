#import "RPushPNPGetUnreadCountRequest.h"
#import "_RPushPNPHelpers.h"

@implementation RPushPNPGetUnreadCountRequest

#pragma mark - Equal

- (NSUInteger)hash {
    return self.accessToken.hash ^ self.pnpClientIdentifier.hash ^ self.pnpClientSecret.hash ^ self.deviceToken.hash ^ self.userIdentifier.hash ^ self.pushType.hash;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    else if (![object isKindOfClass:[self class]] || (self.hash != [object hash])) {
        return NO;
    }
    else {
        RPushPNPGetUnreadCountRequest *other = object;
        return _RPushPNPEqualObjects(self.accessToken, other.accessToken) &&
               _RPushPNPEqualObjects(self.pnpClientIdentifier, other.pnpClientIdentifier) &&
               _RPushPNPEqualObjects(self.pnpClientSecret, other.pnpClientSecret) &&
               _RPushPNPEqualObjects(self.deviceToken, other.deviceToken) &&
               _RPushPNPEqualObjects(self.userIdentifier, other.userIdentifier) &&
               _RPushPNPEqualObjects(self.pushType, other.pushType);
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    RPushPNPGetUnreadCountRequest *copy = [[[self class] allocWithZone:zone] initWithAccessToken:self.accessToken
                                                                   pnpClientIdentifier:self.pnpClientIdentifier
                                                                       pnpClientSecret:self.pnpClientSecret
                                                                           deviceToken:self.deviceToken];
    copy.userIdentifier = self.userIdentifier;
    copy.pushType = self.pushType;
    return copy;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSString *accessToken = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(accessToken))];
    NSString *pnpClientIdentifier = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(pnpClientIdentifier))];
    NSString *pnpClientSecret = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(pnpClientSecret))];
    NSData *deviceToken = [aDecoder decodeObjectOfClass:[NSData class] forKey:NSStringFromSelector(@selector(deviceToken))];

    if ((self = [RPushPNPGetUnreadCountRequest requestWithAccessToken:accessToken
                                                  pnpClientIdentifier:pnpClientIdentifier
                                                      pnpClientSecret:pnpClientSecret
                                                          deviceToken:deviceToken])) {
        self.userIdentifier = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(userIdentifier))];
        self.pushType = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(pushType))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.accessToken forKey:NSStringFromSelector(@selector(accessToken))];
    [aCoder encodeObject:self.pnpClientIdentifier forKey:NSStringFromSelector(@selector(pnpClientIdentifier))];
    [aCoder encodeObject:self.pnpClientSecret forKey:NSStringFromSelector(@selector(pnpClientSecret))];
    [aCoder encodeObject:self.deviceToken forKey:NSStringFromSelector(@selector(deviceToken))];
    if (self.userIdentifier) {
        [aCoder encodeObject:self.userIdentifier forKey:NSStringFromSelector(@selector(userIdentifier))];
    }
    if (self.pushType) {
        [aCoder encodeObject:self.pushType forKey:NSStringFromSelector(@selector(pushType))];
    }
}

#pragma mark - RWCAppEngineScopedEndpoint

+ (NSString *)requiredScopePermission {
    return @"pnp_common_getunreadcount";
}

#pragma mark - RWCURLQueryItemSerializable

- (NSArray *)serializeQueryItemsWithError:(out NSError **)error {
    NSMutableArray *queryItems = [NSMutableArray array];

    void (^add_query_item)(NSString *key, NSString *value) = ^(NSString *key, NSString *value) {
        if (value.length > 0) {
            [queryItems addObject:[RWCURLQueryItem queryItemWithPercentUnencodedKey:key percentUnencodedValue:value]];
        }
    };

    add_query_item(@"pnpClientId", self.pnpClientIdentifier);
    add_query_item(@"pnpClientSecret", self.pnpClientSecret);
    add_query_item(@"deviceId", _RPushPNPDataToHex(self.deviceToken));
    add_query_item(@"userid", self.userIdentifier);
    add_query_item(@"pushtype", self.pushType);
    return [queryItems copy];
}

#pragma mark - RWCURLRequestSerializable

- (NSURLRequest *)serializeURLRequestWithConfiguration:(RWCURLRequestConfiguration *)configuration
                                                 error:(out NSError **)error {
    return [NSURLRequest rpushpnp_requestAPI:@"PNP/GetUnreadCount"
                                     version:20181029
                               configuration:(id)configuration
                                 accessToken:self.accessToken
                       queryItemSerializable:self
                                       error:error];
}

@end

@implementation RPushPNPGetUnreadCountRequest (RPushPNPConvenience)

+ (instancetype)requestWithAccessToken:(NSString *)accessToken
                   pnpClientIdentifier:(NSString *)pnpClientIdentifier
                       pnpClientSecret:(NSString *)pnpClientSecret
                           deviceToken:(NSData *)deviceToken {
    return [[self alloc] initWithAccessToken:accessToken
                         pnpClientIdentifier:pnpClientIdentifier
                             pnpClientSecret:pnpClientSecret
                                 deviceToken:deviceToken];
}

@end
