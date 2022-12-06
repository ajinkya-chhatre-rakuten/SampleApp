/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import "RakutenIdInformationClient.h"

@implementation RIIClient

- (nullable NSURLSessionDataTask *)getOpenIdWithRequest:(RIIGetOpenIdRequest *)request
                                        completionBlock:(void (^)(RIIOpenId * __nullable result, NSError *__nullable error))completionBlock
{
    return [self dataTaskForRequestSerializer:request responseParser:[RIIOpenId class] completionBlock:completionBlock];
}

- (nullable NSURLSessionDataTask *)getEncryptedEasyIdWithRequest:(RIIGetEncryptedEasyIdRequest *)request
                                                 completionBlock:(void (^)(RIIEncryptedEasyId * __nullable result, NSError *__nullable error))completionBlock
{
    return [self dataTaskForRequestSerializer:request responseParser:[RIIEncryptedEasyId class] completionBlock:completionBlock];
}

- (nullable NSURLSessionDataTask *)getRaWithRequest:(RIIGetRaRequest *)request
                                    completionBlock:(void (^)(RIIRa * __nullable result, NSError *__nullable error))completionBlock
{
    return [self dataTaskForRequestSerializer:request responseParser:[RIIRa class] completionBlock:completionBlock];
}

@end
