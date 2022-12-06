#import "RAEClient.h"
#import "_RPushPNPRegistrationCache.h"
#import "_RPushPNPHelpers.h"
#import "_RPushPNPMockedTask.h"
#import "RPushPNPSwiftHeader.h"

@interface RAEClient ()
@property (nonatomic, readonly) id<RPushPNPClientConfigurable> client;
@property (nonatomic, nullable) id<RPushPNPClientConfigurable> customClient;
@end

@implementation RAEClient

- (id<RPushPNPClientConfigurable>)client {
    return _customClient ?: RPushPNPClient.sharedClient;
}

- (void)setPushAPIClient:(id<RPushPNPClientConfigurable> _Nullable)client {
    _customClient = client;
}

- (nullable NSURLSessionDataTask *)getDenyTypeWithRequest:(RPushPNPGetDenyTypeRequest *)request
                                          completionBlock:(void (^)(RPushPNPDenyType *__nullable result, NSError *__nullable error))completionBlock {
    return [[self client] dataTaskForRequestSerializer:request
                                  responseParser:[RPushPNPDenyType class]
                                 completionBlock:completionBlock];
}

- (nullable NSURLSessionDataTask *)setDenyTypeWithRequest:(RPushPNPSetDenyTypeRequest *)request
                                          completionBlock:(void (^)(BOOL result, NSError *__nullable error))completionBlock {
    return [[self client] dataTaskForRequestSerializer:request
                                  responseParser:[RWCAppEngineResponseParser class]
                                 completionBlock:^(id result, NSError *error) {
                                     completionBlock(error == nil, error);
                                 }];
}

- (nullable NSURLSessionDataTask *)registerDeviceWithRequest:(RPushPNPRegisterDeviceRequest *)request
                                             completionBlock:(void (^)(BOOL result, NSError *__nullable error))completionBlock {
    return [_RPushPNPMockedTask.alloc initWithCompletionBlock:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[[self client] dataTaskForRequestSerializer:request
                                   responseParser:[RWCAppEngineResponseParser class]
                                  completionBlock:^(id result, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(error == nil, error);
                });
            }] resume];
        });
    }];
}

- (nullable NSURLSessionDataTask *)unregisterDeviceWithRequest:(RPushPNPUnregisterDeviceRequest *)request
                                               completionBlock:(void (^)(BOOL result, NSError *__nullable error))completionBlock {
    // Default to using our shared client if a custom client isn't set
    return [[self client] dataTaskForRequestSerializer:request
                                  responseParser:[RWCAppEngineResponseParser class]
                                 completionBlock:^(id result, NSError *error) {
                                     completionBlock(error == nil, error);
                                 }];
}

- (nullable NSURLSessionDataTask *)getPushedHistoryWithRequest:(RPushPNPGetPushedHistoryRequest *)request
                                               completionBlock:(void (^)(RPushPNPHistoryData *__nullable result, NSError *__nullable error))completionBlock {
    return [[self client] dataTaskForRequestSerializer:request
                                  responseParser:[RPushPNPHistoryData class]
                                 completionBlock:completionBlock];
}

- (nullable NSURLSessionDataTask *)getUnreadCountWithRequest:(RPushPNPGetUnreadCountRequest *)request
                                             completionBlock:(void (^)(RPushPNPUnreadCount *__nullable result, NSError *__nullable error))completionBlock {
    return [[self client] dataTaskForRequestSerializer:request
                                  responseParser:[RPushPNPUnreadCount class]
                                 completionBlock:completionBlock];
}

- (nullable NSURLSessionDataTask *)setHistoryStatusWithRequest:(RPushPNPSetHistoryStatusRequest *)request
                                               completionBlock:(void (^)(BOOL result, NSError *__nullable error))completionBlock {
    return [[self client] dataTaskForRequestSerializer:request
                                  responseParser:[RWCAppEngineResponseParser class]
                                 completionBlock:^(id result, NSError *error) {
                                     completionBlock(error == nil, error);
                                 }];
}

@end
