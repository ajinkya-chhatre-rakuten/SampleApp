#import "_RPushPNPHelpers.h"
#import "RPushPNPConstants.h"
#import <CommonCrypto/CommonDigest.h>

/* RWC_EXPORT */ NSString *_RPushPNPDataToHex(NSData *data) {
    if (!data.length) {
        return nil;
    }

    const unsigned char *bytes = data.bytes;
    NSMutableString *hexBuilder = [NSMutableString stringWithCapacity:data.length * 2];
    for (NSUInteger byteIndex = 0; byteIndex < data.length; ++byteIndex) {
        [hexBuilder appendFormat:@"%02x", (unsigned int)bytes[byteIndex]];
    }
    return hexBuilder.copy;
}

/* RWC_EXPORT */ NSString *_RPushPNPSafeDeviceToken(NSString *clientId, NSData *deviceToken) {

    /*
     * Note: The format used for the output has been specified by the backend. Do not change it.
     *       It is of the form `url_safe_base64(sha256("<client_id>@ios:<device_token>"))`
     */

    NSString *token = _RPushPNPDataToHex(deviceToken);
    if (!token || !clientId.length) {
        return nil;
    }

    token = [NSString stringWithFormat:@"%@@ios:%@", clientId, token];

    NSData *dataIn = [token dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *dataOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(dataIn.bytes, (CC_LONG)dataIn.length, dataOut.mutableBytes);

    /*
     * URL-safe base 64.
     * See https://commons.apache.org/proper/commons-codec/apidocs/org/apache/commons/codec/binary/Base64.html#encodeBase64URLSafeString(byte[])
     */

    token = [dataOut base64EncodedStringWithOptions:0];
    token = [token stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    token = [token stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    token = [token stringByReplacingOccurrencesOfString:@"=" withString:@""];

    return token;
}

@implementation NSURLRequest (RPushPNP)
+ (nullable instancetype)rpushpnp_requestAPI:(NSString *)api
                                     version:(NSUInteger)version
                               configuration:(RWCURLRequestConfiguration *)configuration
                                 accessToken:(NSString *)accessToken
                       queryItemSerializable:(id<RWCURLQueryItemSerializable>)queryItemSerializable
                                       error:(out NSError **)error {
    static NSURL *defaultBaseURL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultBaseURL = [NSURL URLWithString:RPushPNPDefaultBaseURLString];
    });
    
    if (![api isKindOfClass:NSString.class] ||
        (configuration && ![configuration isKindOfClass:RWCURLRequestConfiguration.class]) ||
        ![accessToken isKindOfClass:NSString.class] ||
        !queryItemSerializable) {
        return nil;
    }

    NSString *path = [NSString stringWithFormat:@"/engine/api/%@/%@", api, @(version)];
    NSURL *url = [configuration.baseURL ?: defaultBaseURL URLByAppendingPathComponent:path].absoluteURL;

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";

    id HTTPHeaderFields = @{@"Accept": @"application/json",
                            @"Authorization": [NSString stringWithFormat:@"OAuth2 %@", accessToken]};

    if (configuration.HTTPHeaderFields.count) {
        HTTPHeaderFields = [HTTPHeaderFields mutableCopy];
        [HTTPHeaderFields addEntriesFromDictionary:configuration.HTTPHeaderFields];
    }

    request.allHTTPHeaderFields = HTTPHeaderFields;

    if (configuration.cachePolicy != NSURLRequestUseProtocolCachePolicy) {
        request.cachePolicy = configuration.cachePolicy;
    }

    NSArray *queryItems = [queryItemSerializable serializeQueryItemsWithError:error];
    if (!queryItems) {
        return nil;
    }
    NSString *queryString = [[queryItems valueForKeyPath:NSStringFromSelector(@selector(description))] componentsJoinedByString:@"&"];
    request.HTTPBody = [queryString dataUsingEncoding:NSUTF8StringEncoding];

    if (error) {
        *error = nil;
    }
    return request.copy;
}
@end
