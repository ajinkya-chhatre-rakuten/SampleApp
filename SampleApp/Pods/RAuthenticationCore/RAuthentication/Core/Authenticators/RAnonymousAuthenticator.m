/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationCore.h>
#import <RakutenEngineClient/RakutenEngineClient.h>
#import <RakutenWebClientKit/RakutenWebClientKit.h>
#import "_RAuthenticationHelpers.h"

@implementation RAnonymousAuthenticator

#pragma mark RAuthenticator
- (NSOperation *)requestTokenWithCompletion:(void (^)(RAuthenticationToken *, NSError *))completion
{
    NSParameterAssert(completion);
    if (!completion) { return nil; }

    RAuthenticationSettings *settings = self.settings;
    RETokenRequest *request = [RETokenRequest clientCredentialsTokenRequestWithClientIdentifier:settings.clientId
                                                                                   clientSecret:settings.clientSecret];
    request.scopes = self.requestedScopes;

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSOperation *operation = _RAuthenticationDispatchGroupOperation(group, 0);
    operation.name = _RAuthenticationSelectorString(self, _cmd);
    [self.operationQueue addOperation:operation];

    [[[_RAuthenticationEngineClient with:settings] tokenWithRequest:request
                                                    completionBlock:^(RETokenResult *result, NSError *error)
    {
        if (_RAuthenticationShouldProceed(operation, error))
        {
            completion(result._convertedToken, error);
        }

        dispatch_group_leave(group);
    }] resume];

    return operation;
}

- (NSOperation *)requestUserInformationWithToken:(RAuthenticationToken __unused *)token
                                      completion:(void (^)(RAuthenticationAccountUserInformation *, NSError *))completion
{
    NSParameterAssert(completion);
    if (!completion) { return nil; }

    // Anonymous authenticators don't have any user associated
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{ completion(nil, nil); }];
    [self.operationQueue addOperation:operation];
    return operation;
}

- (NSOperation *)requestTrackingIdentifierWithToken:(RAuthenticationToken *)token
                                         completion:(void(^)(NSString * __nullable trackingIdentifier, NSError * __nullable error))completion
{
    NSParameterAssert(completion);
    if (!completion) { return nil; }

    // Anonymous authenticators don't have any user associated
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{ completion(nil, nil); }];
    [self.operationQueue addOperation:operation];
    return operation;
}

- (NSOperation *)revokeToken:(RAuthenticationToken *)token
                  completion:(void(^)(NSError *error))completion
{
    NSParameterAssert(token);
    NSParameterAssert(completion);
    if (!completion) { return nil; }

    RAuthenticationSettings *settings = self.settings;
    RERevokeTokenRequest *request = [RERevokeTokenRequest requestWithClientIdentifier:settings.clientId
                                                                         clientSecret:settings.clientSecret
                                                                          accessToken:token.accessToken];
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSOperation *operation = _RAuthenticationDispatchGroupOperation(group, 0);
    operation.name = _RAuthenticationSelectorString(self, _cmd);
    [self.operationQueue addOperation:operation];

    [[[_RAuthenticationEngineClient with:settings] revokeTokenWithRequest:request
                                                                        completionBlock:^(BOOL __unused result, NSError *error)
    {
        if ([error.domain isEqualToString:RWCAppEngineResponseParserErrorDomain] &&
            (error.code == RWCAppEngineResponseParserErrorInvalidParameter ||
             error.code == RWCAppEngineResponseParserErrorUnauthorized))
        {
            // The access token is already invalid, so we can simply ignore the error
            error = nil;
        }

        if (_RAuthenticationShouldProceed(operation, error))
        {
            completion(error);
        }

        dispatch_group_leave(group);
    }] resume];

    return operation;
}

- (NSOperation *)refreshToken:(RAuthenticationToken *)token
                       scopes:(NSSet *)scopes
                   completion:(void(^)(NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(token.refreshToken);
    if (!completion) { return nil; }

    RAuthenticationSettings *settings = self.settings;
    RETokenRequest *request = [RETokenRequest refreshTokenRequestWithClientIdentifier:settings.clientId
                                                                         clientSecret:settings.clientSecret
                                                                         refreshToken:(id)token.refreshToken];
    request.scopes = scopes;

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSOperation *operation = _RAuthenticationDispatchGroupOperation(group, 0);
    operation.name = _RAuthenticationSelectorString(self, _cmd);
    [self.operationQueue addOperation:operation];

    [[[_RAuthenticationEngineClient with:settings] tokenWithRequest:request
                                                                  completionBlock:^(RETokenResult *result, NSError *error)
    {
        if (_RAuthenticationShouldProceed(operation, error))
        {
            if (!error) [result _populateExistingToken:token];

            completion(error);
        }

        dispatch_group_leave(group);
    }] resume];

    return operation;
}

#pragma mark NSObject
- (void)dealloc
{
    [self.operationQueue cancelAllOperations];
}

#pragma mark <NSSecureCoding>
+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark <NSCoding>
- (instancetype)initWithCoder:(NSCoder *)coder
{
    return ((self = [super initWithCoder:coder]));
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
}
@end
