#import "RPushPNPBaseRequest.h"
#import <RPushPNP/_RPushPNPHelpers.h>

@implementation RPushPNPBaseRequest

- (instancetype)initWithAccessToken:(NSString *)accessToken
                pnpClientIdentifier:(NSString *)pnpClientIdentifier
                    pnpClientSecret:(NSString *)pnpClientSecret
                        deviceToken:(nullable NSData *)deviceToken {
    NSParameterAssert(accessToken);
    NSParameterAssert(pnpClientIdentifier);
    NSParameterAssert(pnpClientSecret);
    if ((self = [super init])) {
        _accessToken = [accessToken copy];
        _pnpClientIdentifier = [pnpClientIdentifier copy];
        _pnpClientSecret = [pnpClientSecret copy];
        if (deviceToken) {
            _deviceToken = [deviceToken copy];
        }
    }

    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
#pragma clang diagnostic pop

- (NSUInteger)hash {
    return self.accessToken.hash ^ self.pnpClientIdentifier.hash ^ self.pnpClientSecret.hash ^ self.deviceToken.hash ^ self.userIdentifier.hash;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    else if (![object isKindOfClass:[self class]] || (self.hash != [object hash])) {
        return NO;
    }
    else {
        RPushPNPBaseRequest *other = object;
        return _RPushPNPEqualObjects(self.accessToken, other.accessToken) &&
               _RPushPNPEqualObjects(self.pnpClientIdentifier, other.pnpClientIdentifier) &&
               _RPushPNPEqualObjects(self.pnpClientSecret, other.pnpClientSecret) &&
               _RPushPNPEqualObjects(self.deviceToken, other.deviceToken) &&
               _RPushPNPEqualObjects(self.userIdentifier, other.userIdentifier);
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    RPushPNPBaseRequest *copy = [[[self class] allocWithZone:zone] initWithAccessToken:self.accessToken
                                                                   pnpClientIdentifier:self.pnpClientIdentifier
                                                                       pnpClientSecret:self.pnpClientSecret
                                                                           deviceToken:self.deviceToken];
    copy.userIdentifier = self.userIdentifier;
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

    if ((self = [self initWithAccessToken:accessToken pnpClientIdentifier:pnpClientIdentifier pnpClientSecret:pnpClientSecret deviceToken:deviceToken])) {
        _userIdentifier = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(userIdentifier))];
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
}

@end
