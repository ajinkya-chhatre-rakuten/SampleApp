#import <RPushPNP/RPushPNP.h>

NS_ASSUME_NONNULL_BEGIN

NS_INLINE BOOL _RPushPNPEqualObjects(id __nullable objA, id __nullable objB) {
    return (!objA && !objB) || (objA && objB && [objA isEqual:objB]);
}

RWC_EXPORT NSString *_RPushPNPDataToHex(NSData *data);
RWC_EXPORT NSString *_RPushPNPSafeDeviceToken(NSString *clientId, NSData *deviceToken);

@interface RPushPNPRegisterDeviceRequest ()
@property (nonatomic, copy) NSString *safePreviousDeviceToken;
@end

@interface NSURLRequest (RPushPNP)

/*
 * Create a request.
 *
 * @param api                    API name, e.g. `PNPiOS/GetFoo`.
 * @param version                Endpoint version.
 * @param configuration          URL request configuration.
 * @param accessToken            The current access token.
 * @param queryItemSerializable  The query items.
 * @param [out] error            Where to put the error if one arises.
 * @return A request object, or `nil` if an error happens.
 */
+ (nullable instancetype)rpushpnp_requestAPI:(NSString *)api
                            version:(NSUInteger)version
                      configuration:(RWCURLRequestConfiguration *)configuration
                        accessToken:(NSString *)accessToken
              queryItemSerializable:(id<RWCURLQueryItemSerializable>)queryItemSerializable
                              error:(out NSError **)error;
@end

NS_ASSUME_NONNULL_END
