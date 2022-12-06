#import <RPushPNP/RPushPNPManager.h>
#import "_RPushPNPRegistrationCache.h"
#import "_RPushPNPHelpers.h"
#import "_RPushPNPMockedTask.h"
#import "RAEClient.h"
#import "RPushPNPSwiftHeader.h"
#import "RPushPNPAPIParameters.h"
#import "RPushPNPTargetedDevice.h"
#import <RAnalytics/RAnalytics.h>

@interface RPushPNPManager ()
@property (strong, nonatomic) RAEClient *raeClient;
@property (strong, nonatomic) APICClient *apicClient;
@property (strong, nonatomic) id<RPushPNPProtocol> selectedClient;
@property (nonatomic) RPushPNPManagerAPIType apiType;
@property (strong, nonatomic) RAnalyticsRpCookieFetcher *rpCookieFetcher;
@property (strong, nonatomic) RPushPNPTargetedDevice *targetedDevice;
@property (strong, nonatomic) RPushPNPAPIParameters *apiParameters;
@end

@implementation RPushPNPManager

+ (instancetype)sharedInstance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _raeClient = RAEClient.new;
        Requester *requester = [Requester.alloc init:NSURLSession.sharedSession];
        _apicClient = [APICClient.alloc initWithRequester:requester pnpClient:RPushPNPClient.sharedClient];
        [self enableAPI:RPushPNPManagerAPITypeRAE];
        _rpCookieFetcher = [RAnalyticsRpCookieFetcher.alloc initWithCookieStorage:[NSHTTPCookieStorage sharedHTTPCookieStorage]];
        _targetedDevice = [[RPushPNPTargetedDevice alloc] initWithRPCookieFetcher:_rpCookieFetcher];
    }
    return self;
}

#pragma mark - API Client Selection

- (void)enableAPI:(RPushPNPManagerAPIType)apiType {
    _apiType = apiType;

    switch (apiType) {
        case RPushPNPManagerAPITypeRAE:
            _selectedClient = _raeClient;
            break;
            
        case RPushPNPManagerAPITypeAPIC:
            _selectedClient = _apicClient;
            break;
    }
}

- (RPushPNPManagerAPIType)enabledAPI {
    return _apiType;
}

#pragma mark - Access Token

- (void)fetchAccessTokenWithParameters:(RPushPNPAPIParameters * _Nullable)parameters
                     failureCompletion:(void (^)(NSError *))failureCompletion
                     successCompletion:(void (^)(NSString *))successCompletion {
    _apiParameters = parameters;
    
    switch (_apiType) {
        case RPushPNPManagerAPITypeRAE:
            failureCompletion(RPushPNPError.noRAEAccessTokenError);
            break;
            
        case RPushPNPManagerAPITypeAPIC:
            [_apicClient fetchAccessTokenWithParameters:parameters failureCompletion:^(NSError * _Nonnull error) {
                failureCompletion(error);
                
            } successCompletion:^(NSString * _Nonnull token) {
                successCompletion(token);
            }];
            break;
    }
}

#pragma mark - API Client

- (id<RPushPNPClientConfigurable>)client {
    return [_selectedClient client];
}

- (void)setPushAPIClient:(id<RPushPNPClientConfigurable> _Nullable)client {
    [_selectedClient setPushAPIClient:client];
}

#pragma mark - Registration Cache

- (BOOL)isRegisteredToPNP:(NSString *)pnpClientIdentifier
           userIdentifier:(NSString *)userIdentifier
              deviceToken:(NSData *)deviceToken {
    
    NSString *userID = userIdentifier.length == 0 ? nil : userIdentifier;
    _RPushPNPRegistrationCache *cache = [_RPushPNPRegistrationCache cacheWithConfiguration:[self client].clientConfiguration
                                                                                  clientId:pnpClientIdentifier];
    return [cache hasDeviceToken:deviceToken
                          userId:userID
                        rpCookie:[_rpCookieFetcher getRpCookieFromCookieStorage]];
}

#pragma mark - Public API

- (nullable NSURLSessionDataTask *)getDenyTypeWithRequest:(RPushPNPGetDenyTypeRequest *)request
                                          completionBlock:(void (^)(RPushPNPDenyType *__nullable result, NSError *__nullable error))completionBlock {
    __weak typeof(self) weakSelf = self;
    return [_selectedClient getDenyTypeWithRequest:request completionBlock:^(RPushPNPDenyType * _Nullable result, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        BOOL errorIsRaised = [strongSelf checkAccessTokenValidityError:error forRequest:request retryBlock:^() {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf getDenyTypeWithRequest:request completionBlock:completionBlock];
        }];
        if (!errorIsRaised) { completionBlock(result, error); }
    }];
}

- (nullable NSURLSessionDataTask *)setDenyTypeWithRequest:(RPushPNPSetDenyTypeRequest *)request
                                          completionBlock:(void (^)(BOOL result, NSError *__nullable error))completionBlock {
    __weak typeof(self) weakSelf = self;
    return [_selectedClient setDenyTypeWithRequest:request completionBlock:^(BOOL result, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        BOOL errorIsRaised = [strongSelf checkAccessTokenValidityError:error forRequest:request retryBlock:^() {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf setDenyTypeWithRequest:request completionBlock:completionBlock];
        }];
        if (!errorIsRaised) { completionBlock(result, error); }
    }];
}

- (nullable NSURLSessionDataTask *)registerDeviceWithRequest:(RPushPNPRegisterDeviceRequest *)request
                                             completionBlock:(void (^)(BOOL result, NSError *__nullable error))completionBlock {
    RPushPNPRegisterDeviceRequest *requestCopy = [request copy];
    RWClient *client = [self client];
    
    _RPushPNPRegistrationCache *cache = [_RPushPNPRegistrationCache cacheWithConfiguration:client.clientConfiguration
                                                                                  clientId:requestCopy.pnpClientIdentifier];
    NSHTTPCookie* cookie = [self _fetchCookieIfNeeded];
    request.rpCookie = cookie;
    requestCopy.rpCookie = cookie;
    
    if ([self _isRegisteredToPNP:requestCopy.pnpClientIdentifier
                  userIdentifier:requestCopy.userIdentifier
                     deviceToken:requestCopy.deviceToken
                          cookie:requestCopy.rpCookie]) {
        dispatch_async(dispatch_get_main_queue(), ^{ // Note: Maybe not needed, legacy code.
            completionBlock(YES, nil);
        });
        return nil;
    }
    
    // Re-register API
    if (![cache hasSafeToken:requestCopy.deviceToken]) {
        requestCopy.safePreviousDeviceToken = [cache cachedSafeToken];
        request.safePreviousDeviceToken = [cache cachedSafeToken];
    }
    
    __weak typeof(self) weakSelf = self;
    return [_selectedClient registerDeviceWithRequest:request completionBlock:^(BOOL result, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!error) {
            [cache setDeviceToken:requestCopy.deviceToken
                           userId:requestCopy.userIdentifier
                         rpCookie:requestCopy.rpCookie];
        }
        BOOL errorIsRaised = [strongSelf checkAccessTokenValidityError:error forRequest:request retryBlock:^() {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf registerDeviceWithRequest:request completionBlock:completionBlock];
        }];
        if (!errorIsRaised) { completionBlock(result, error); }
    }];
}

- (nullable NSURLSessionDataTask *)unregisterDeviceWithRequest:(RPushPNPUnregisterDeviceRequest *)request
                                               completionBlock:(void (^)(BOOL result, NSError *__nullable error))completionBlock {
    RWClient *client = [self client];
    RWCURLRequestConfiguration *config = client.clientConfiguration;
    RPushPNPUnregisterDeviceRequest *requestCopy = [request copy];

    __weak typeof(self) weakSelf = self;
    return [_selectedClient unregisterDeviceWithRequest:request completionBlock:^(BOOL result, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!error) {
            [[_RPushPNPRegistrationCache cacheWithConfiguration:config
                                                       clientId:requestCopy.pnpClientIdentifier] invalidate];
        }
        BOOL errorIsRaised = [strongSelf checkAccessTokenValidityError:error forRequest:request retryBlock:^() {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf unregisterDeviceWithRequest:request completionBlock:completionBlock];
        }];
        if (!errorIsRaised) { completionBlock(result, error); }
    }];
}

- (nullable NSURLSessionDataTask *)getPushedHistoryWithRequest:(RPushPNPGetPushedHistoryRequest *)request
                                               completionBlock:(void (^)(RPushPNPHistoryData *__nullable result, NSError *__nullable error))completionBlock {
    __weak typeof(self) weakSelf = self;
    return [_selectedClient getPushedHistoryWithRequest:request completionBlock:^(RPushPNPHistoryData * _Nullable result, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        BOOL errorIsRaised = [strongSelf checkAccessTokenValidityError:error forRequest:request retryBlock:^() {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf getPushedHistoryWithRequest:request completionBlock:completionBlock];
        }];
        if (!errorIsRaised) { completionBlock(result, error); }
    }];
}

- (nullable NSURLSessionDataTask *)getUnreadCountWithRequest:(RPushPNPGetUnreadCountRequest *)request
                                             completionBlock:(void (^)(RPushPNPUnreadCount *__nullable result, NSError *__nullable error))completionBlock {
    __weak typeof(self) weakSelf = self;
    return [_selectedClient getUnreadCountWithRequest:request completionBlock:^(RPushPNPUnreadCount * _Nullable result, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        BOOL errorIsRaised = [strongSelf checkAccessTokenValidityError:error forRequest:request retryBlock:^() {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf getUnreadCountWithRequest:request completionBlock:completionBlock];
        }];
        if (!errorIsRaised) { completionBlock(result, error); }
    }];
}

- (nullable NSURLSessionDataTask *)setHistoryStatusWithRequest:(RPushPNPSetHistoryStatusRequest *)request
                                               completionBlock:(void (^)(BOOL result, NSError *__nullable error))completionBlock {
    __weak typeof(self) weakSelf = self;
    return [_selectedClient setHistoryStatusWithRequest:request completionBlock:^(BOOL result, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        BOOL errorIsRaised = [strongSelf checkAccessTokenValidityError:error forRequest:request retryBlock:^() {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf setHistoryStatusWithRequest:request completionBlock:completionBlock];
        }];
        if (!errorIsRaised) { completionBlock(result, error); }
    }];
}

#pragma mark - Private API

/**
 *  Retry the passed request if the access token is invalid.
 *
 *  @param error  The returned error by the PNP Backend.
 *  @param request  The request to retry.
 *  @param retryBlock The retry block.
 *
 *  @return YES if the access token is invalid and the request is retried, NO otherwise.
 *
 */
- (BOOL)checkAccessTokenValidityError:(NSError *)error
                           forRequest:(RPushPNPBaseRequest *)request
                           retryBlock:(void (^)(void))retryBlock {
    if (error.isInvalidTokenError
        && _accessTokenIsExpiredCompletionBlock != nil) {
        __weak typeof(request) weakRequest = request;
        request.updateTokenBlock = ^(NSString * _Nonnull token) {
            __strong typeof(request) strongRequest = weakRequest;
            strongRequest.accessToken = token;
            retryBlock();
        };
        
        _accessTokenIsExpiredCompletionBlock(request.updateTokenBlock);
        return YES;
    }
    return NO;
}

- (nullable NSHTTPCookie *)_fetchCookieIfNeeded {
    dispatch_group_t fetchCookieGroup = dispatch_group_create();

    __block NSHTTPCookie *_Nullable rpCookie;
    
    dispatch_group_enter(fetchCookieGroup);
        
    [_targetedDevice fetchRPCookie:^(NSHTTPCookie *_Nullable cookie) {
        rpCookie = cookie;
        dispatch_group_leave(fetchCookieGroup);
    }];

    dispatch_group_wait(fetchCookieGroup, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    return rpCookie;
}

- (BOOL)_isRegisteredToPNP:(NSString *)pnpClientIdentifier
            userIdentifier:(NSString *)userIdentifier
               deviceToken:(NSData *)deviceToken
                    cookie:(NSHTTPCookie *_Nullable)cookie {
    
    NSString *userID = userIdentifier.length == 0 ? nil : userIdentifier;
    _RPushPNPRegistrationCache *cache = [_RPushPNPRegistrationCache cacheWithConfiguration:[self client].clientConfiguration
                                                                                  clientId:pnpClientIdentifier];
    return [cache hasDeviceToken:deviceToken
                          userId:userID
                        rpCookie:cookie];
}

@end
