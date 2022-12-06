#import "RPushPNPGetDenyTypeRequest.h"
#import "_RPushPNPHelpers.h"

@implementation RPushPNPGetDenyTypeRequest

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

#pragma mark - RWCAppEngineScopedEndpoint

+ (NSString *)requiredScopePermission {
    return @"pnp_ios_denytype_check";
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
    return [queryItems copy];
}

#pragma mark - RWCURLRequestSerializable

- (NSURLRequest *)serializeURLRequestWithConfiguration:(RWCURLRequestConfiguration *)configuration
                                                 error:(out NSError**)error
{
    return [NSURLRequest rpushpnp_requestAPI:@"PNPiOS/CheckDenyType"
                                     version:20160301
                               configuration:configuration
                                 accessToken:self.accessToken
                       queryItemSerializable:self
                                       error:error];
}

@end

@implementation RPushPNPGetDenyTypeRequest (RPushPNPConvenience)

+ (instancetype)requestWithAccessToken:(NSString *)accessToken
                   pnpClientIdentifier:(NSString *)pnpClientIdentifier
                       pnpClientSecret:(NSString *)pnpClientSecret {
    return [[self alloc] initWithAccessToken:accessToken
                         pnpClientIdentifier:pnpClientIdentifier
                             pnpClientSecret:pnpClientSecret
                                 deviceToken:nil];
}

@end
