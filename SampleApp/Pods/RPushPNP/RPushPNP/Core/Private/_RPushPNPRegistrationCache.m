@import Darwin.libkern;
#import <CommonCrypto/CommonDigest.h>
#import "_RPushPNPRegistrationCache.h"
#import "_RPushPNPHelpers.h"

typedef NSDictionary<NSString *, NSString *> PropertyStringMap;

NS_INLINE NSString *_RPushPNPDataToSha256Hex(NSData *dataIn) {
    if (!dataIn.length) {
        return nil;
    }

    NSMutableData *dataOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(dataIn.bytes, (CC_LONG)dataIn.length, dataOut.mutableBytes);
    return _RPushPNPDataToHex(dataOut);
}

NS_INLINE NSString *_RPushPNPStringToSha256Hex(NSString *inStr) {
    return _RPushPNPDataToSha256Hex([inStr dataUsingEncoding:NSUTF8StringEncoding]);
}

NSString *const DeviceTokenKey = @"DeviceTokenKey";
NSString *const UserIdKey = @"UserIdKey";
NSString *const RPCookieKey = @"RPCookieKey";

@interface _RPushPNPRegistrationCache ()
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *clientId;
@end

@implementation _RPushPNPRegistrationCache
- (instancetype)initWithConfiguration:(RWCURLRequestConfiguration *)configuration clientId:(NSString *)clientId {
    NSParameterAssert(configuration);
    NSParameterAssert(clientId);

    if ((self = [super init])) {
        // This might fail if the device is currently locked
        NSURL *cacheDirectoryURL = [NSFileManager.defaultManager URLsForDirectory:NSCachesDirectory
                                                                        inDomains:NSUserDomainMask]
                                       .firstObject;
        if (!cacheDirectoryURL) {
            return nil;
        }

        // use PNPv2
        NSUInteger platform = 2;

        NSURL *url = configuration.baseURL ?: [NSURL URLWithString:RPushPNPDefaultBaseURLString];
        NSString *filename = [NSString stringWithFormat:@"com.rakuten.pnp.%@", // use "pnp" to keep backwards compatibility with cache in PNP API module
                                                        _RPushPNPStringToSha256Hex([NSString stringWithFormat:@"%@:%@:%@:%@",
                                                                                                              url.host,
                                                                                                              [url.path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" /\t"]],
                                                                                                              @(platform),
                                                                                                              clientId])];
        url = [cacheDirectoryURL URLByAppendingPathComponent:filename].absoluteURL;

        if (!url) {
            return nil;
        }

        _url = url;
        _clientId = clientId.copy;
    }
    return self;
}

+ (instancetype)cacheWithConfiguration:(RWCURLRequestConfiguration *)configuration clientId:(NSString *)clientId {
    return [self.alloc initWithConfiguration:configuration clientId:clientId];
}

- (BOOL)setDeviceToken:(NSData *)deviceToken
                userId:(nullable NSString *)userId
              rpCookie:(nullable NSHTTPCookie *)cookie {
    NSParameterAssert(deviceToken);

    NSMutableDictionary *propertyRegisterMap = [[NSMutableDictionary alloc] initWithDictionary:@{DeviceTokenKey: _RPushPNPSafeDeviceToken(_clientId, deviceToken)}];

    if (userId && userId.length > 0) {
        propertyRegisterMap[UserIdKey] = _RPushPNPStringToSha256Hex(userId);
    }

    if (cookie && [cookie.name.lowercaseString isEqualToString:@"rp"]) {
        propertyRegisterMap[RPCookieKey] = _RPushPNPStringToSha256Hex(cookie.value);
    }
    
    return [propertyRegisterMap writeToURL:_url atomically:YES];
}

- (BOOL)hasDeviceToken:(NSData *)deviceToken
                userId:(nullable NSString *)userId
              rpCookie:(nullable NSHTTPCookie *)cookie {
    NSParameterAssert(deviceToken);

    PropertyStringMap *propertyRegisterMap = [[NSDictionary alloc] initWithContentsOfURL:_url];

    if (!propertyRegisterMap) {
        return NO;
    }

    NSString *cachedSafeDeviceTokenString = propertyRegisterMap[DeviceTokenKey];
    NSString *cachedUserId = propertyRegisterMap[UserIdKey];
    NSString *cachedCookieString = propertyRegisterMap[RPCookieKey];

    NSString *safeDeviceTokenString = _RPushPNPSafeDeviceToken(_clientId, deviceToken);
    NSString *safeCookieString = cookie ? _RPushPNPStringToSha256Hex(cookie.value) : nil;
    NSString *safeUserId = userId ? _RPushPNPStringToSha256Hex(userId) : nil;

    return (_RPushPNPEqualObjects(cachedSafeDeviceTokenString, safeDeviceTokenString) &&
            _RPushPNPEqualObjects(cachedUserId, safeUserId) &&
            _RPushPNPEqualObjects(cachedCookieString, safeCookieString));
}

- (BOOL)hasSafeToken:(nullable NSData *)deviceToken {
    if (!deviceToken) {
        return NO;
    }

    PropertyStringMap *propertyRegisterMap = [[NSDictionary alloc] initWithContentsOfURL:_url];

    if (!propertyRegisterMap) {
        return NO;
    }

    NSString *safeDeviceTokenString = _RPushPNPSafeDeviceToken(_clientId, deviceToken);
    NSString *cachedSafeDeviceTokenString = propertyRegisterMap[DeviceTokenKey];

    return (_RPushPNPEqualObjects(safeDeviceTokenString, cachedSafeDeviceTokenString));
}

- (nullable NSString *)cachedSafeToken {
    PropertyStringMap *propertyMap = [[NSDictionary alloc] initWithContentsOfURL:_url];
    if (propertyMap) {
        return propertyMap[DeviceTokenKey];
    }
    return nil;
}

- (void)invalidate {
    [NSFileManager.defaultManager removeItemAtURL:_url error:0];
}
@end
