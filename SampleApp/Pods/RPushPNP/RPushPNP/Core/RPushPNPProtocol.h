#import <Foundation/Foundation.h>

@class RWClient;
@class RPushPNPGetDenyTypeRequest;
@class RPushPNPDenyType;
@class RPushPNPSetDenyTypeRequest;
@class RPushPNPRegisterDeviceRequest;
@class RPushPNPUnregisterDeviceRequest;
@class RPushPNPGetPushedHistoryRequest;
@class RPushPNPHistoryData;
@class RPushPNPGetUnreadCountRequest;
@class RPushPNPUnreadCount;
@class RPushPNPSetHistoryStatusRequest;

NS_ASSUME_NONNULL_BEGIN

@protocol RPushPNPClientConfigurable <NSObject>

@property (copy, nonatomic) RWCURLRequestConfiguration *clientConfiguration;

- (nullable NSURLSessionDataTask *)dataTaskForRequestSerializer:(id<RWCURLRequestSerializable>)requestSerializer
                                                 responseParser:(Class<RWCURLResponseParser>)responseParser
                                                completionBlock:(void (^)(id __nullable result, NSError *__nullable error))completionBlock;
@end

@protocol RPushPNPProtocol <NSObject>

- (void)setPushAPIClient:(id<RPushPNPClientConfigurable> __nullable)client;

- (id<RPushPNPClientConfigurable>)client;

- (nullable NSURLSessionDataTask *)registerDeviceWithRequest:(RPushPNPRegisterDeviceRequest *)request
                                             completionBlock:(void (^)(BOOL result, NSError *__nullable error))completionBlock;

- (nullable NSURLSessionDataTask *)unregisterDeviceWithRequest:(RPushPNPUnregisterDeviceRequest *)request
                                               completionBlock:(void (^)(BOOL result, NSError *__nullable error))completionBlock;

- (nullable NSURLSessionDataTask *)getDenyTypeWithRequest:(RPushPNPGetDenyTypeRequest *)request
                                          completionBlock:(void (^)(RPushPNPDenyType *__nullable result, NSError *__nullable error))completionBlock;

- (nullable NSURLSessionDataTask *)setDenyTypeWithRequest:(RPushPNPSetDenyTypeRequest *)request
                                          completionBlock:(void (^)(BOOL result, NSError *__nullable error))completionBlock;

- (nullable NSURLSessionDataTask *)getPushedHistoryWithRequest:(RPushPNPGetPushedHistoryRequest *)request
                                               completionBlock:(void (^)(RPushPNPHistoryData *__nullable result, NSError *__nullable error))completionBlock;

- (nullable NSURLSessionDataTask *)getUnreadCountWithRequest:(RPushPNPGetUnreadCountRequest *)request
                                             completionBlock:(void (^)(RPushPNPUnreadCount *__nullable result, NSError *__nullable error))completionBlock;

- (nullable NSURLSessionDataTask *)setHistoryStatusWithRequest:(RPushPNPSetHistoryStatusRequest *)request
                                               completionBlock:(void (^)(BOOL result, NSError *__nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
