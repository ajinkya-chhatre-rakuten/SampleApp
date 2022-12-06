#import "RPushPNPSetHistoryStatusRequest.h"
#import "_RPushPNPHelpers.h"
#import "RPushPNPSwiftHeader.h"

@implementation RPushPNPSetHistoryStatusRequest

- (NSUInteger)hash {
    return super.hash ^ self.requestIdentifier.hash ^ self.markAsRead ^ self.pushType.hash ^ self.registerDateStart.hash ^ self.registerDateEnd.hash;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    else if (![object isKindOfClass:[self class]] || (self.hash != [object hash])) {
        return NO;
    }
    else {
        RPushPNPSetHistoryStatusRequest *other = object;
        return
        [super isEqual:other] &&
        _RPushPNPEqualObjects(self.requestIdentifier, other.requestIdentifier) &&
        self.markAsRead == other.markAsRead &&
        self.pushType ? [self.pushType isEqualToString:other.pushType] : self.pushType == other.pushType &&
        self.registerDateStart == other.registerDateStart &&
        self.registerDateEnd == other.registerDateEnd;
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    RPushPNPSetHistoryStatusRequest *copy = [super copyWithZone:zone];
    copy.requestIdentifier = self.requestIdentifier;
    copy.markAsRead = self.markAsRead;
    copy.pushType = self.pushType;
    copy.registerDateStart = self.registerDateStart;
    copy.registerDateEnd = self.registerDateEnd;

    return copy;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        _markAsRead = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(markAsRead))];
        _requestIdentifier = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(requestIdentifier))];
        _pushType = [aDecoder decodeObjectOfClass: [NSString class] forKey:NSStringFromSelector(@selector(pushType))];
        _registerDateStart = [aDecoder decodeObjectOfClass: [NSDate class] forKey:NSStringFromSelector(@selector(registerDateStart))];
        _registerDateEnd = [aDecoder decodeObjectOfClass: [NSDate class] forKey:NSStringFromSelector(@selector(registerDateEnd))];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.requestIdentifier forKey:NSStringFromSelector(@selector(requestIdentifier))];
    [aCoder encodeBool:self.markAsRead forKey:NSStringFromSelector(@selector(markAsRead))];
    [aCoder encodeObject:self.pushType forKey:NSStringFromSelector(@selector(pushType))];
    [aCoder encodeObject:self.registerDateStart forKey:NSStringFromSelector(@selector(registerDateStart))];
    [aCoder encodeObject:self.registerDateEnd forKey:NSStringFromSelector(@selector(registerDateEnd))];
}

#pragma mark - RWCAppEngineScopedEndpoint

+ (NSString *)requiredScopePermission {
    return @"pnp_common_sethistorystatus";
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
    add_query_item(@"requestId", self.requestIdentifier);
    add_query_item(@"pushtype", self.pushType);
    add_query_item(@"registerDateStart", self.registerDateStart.toISO8601String);
    add_query_item(@"registerDateEnd", self.registerDateEnd.toISO8601String);
    return [queryItems copy];
}

#pragma mark - RWCURLRequestSerializable

- (NSURLRequest *)serializeURLRequestWithConfiguration:(RWCURLRequestConfiguration *)configuration
                                                 error:(out NSError **)error {
    return [NSURLRequest rpushpnp_requestAPI:self.markAsRead ? @"PNP/SetHistoryStatusRead" : @"PNP/SetHistoryStatusUnread"
                                     version:20181029
                               configuration:(id)configuration
                                 accessToken:self.accessToken
                       queryItemSerializable:self
                                       error:error];
}

@end

@implementation RPushPNPSetHistoryStatusRequest (RPushPNPConvenience)

+ (instancetype)requestWithAccessToken:(NSString *)accessToken
                   pnpClientIdentifier:(NSString *)pnpClientIdentifier
                       pnpClientSecret:(NSString *)pnpClientSecret
                           deviceToken:(NSData *)deviceToken
                            markAsRead:(BOOL)markAsRead {
    RPushPNPSetHistoryStatusRequest *request = [[self alloc] initWithAccessToken:accessToken
                                                             pnpClientIdentifier:pnpClientIdentifier
                                                                 pnpClientSecret:pnpClientSecret
                                                                     deviceToken:deviceToken];
    request.markAsRead = markAsRead;
    return request;
}

@end
