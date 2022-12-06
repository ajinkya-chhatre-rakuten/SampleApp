#import "RakutenMemberInformationClient.h"

@implementation RMIClient

- (NSURLSessionDataTask *)getBasicInfoWithRequest:(RMIGetBasicInfoRequest *)request
                                  completionBlock:(void (^)(RMIBasicInfo *, NSError *))completionBlock
{
    return [self dataTaskForRequestSerializer:request responseParser:[RMIBasicInfo class] completionBlock:completionBlock];
}

- (NSURLSessionDataTask *)getNameWithRequest:(RMIGetNameRequest *)request
                             completionBlock:(void (^)(RMIName *, NSError *))completionBlock
{
    return [self dataTaskForRequestSerializer:request responseParser:[RMIName class] completionBlock:completionBlock];
}

- (NSURLSessionDataTask *)getPointWithRequest:(RMIGetPointRequest *)request
                              completionBlock:(void (^)(RMIPoint *, NSError *))completionBlock
{
    return [self dataTaskForRequestSerializer:request responseParser:[RMIPoint class] completionBlock:completionBlock];
}

- (NSURLSessionDataTask *)getRankWithRequest:(RMIGetRankRequest *)request
                             completionBlock:(void (^)(RMIRank *, NSError *))completionBlock
{
    return [self dataTaskForRequestSerializer:request responseParser:[RMIRank class] completionBlock:completionBlock];
}

- (NSURLSessionDataTask *)getEmailWithRequest:(RMIGetEmailRequest *)request
                              completionBlock:(void (^)(RMIEmail *, NSError *))completionBlock
{
    return [self dataTaskForRequestSerializer:request responseParser:[RMIEmail class] completionBlock:completionBlock];
}

- (NSURLSessionDataTask *)getAddressWithRequest:(RMIGetAddressRequest *)request
                                completionBlock:(void (^)(RMIAddress *, NSError *))completionBlock
{
    return [self dataTaskForRequestSerializer:request responseParser:[RMIAddress class] completionBlock:completionBlock];
}

- (NSURLSessionDataTask *)getTelephoneWithRequest:(RMIGetTelephoneRequest *)request
                                  completionBlock:(void (^)(RMITelephone *, NSError *))completionBlock
{
    return [self dataTaskForRequestSerializer:request responseParser:[RMITelephone class] completionBlock:completionBlock];
}

- (NSURLSessionDataTask *)getSafeBulkWithRequest:(RMIGetSafeBulkRequest *)request
                                        completionBlock:(void (^)(RMISafeBulk *, NSError *))completionBlock
{
    return [self dataTaskForRequestSerializer:request responseParser:[RMISafeBulk class] completionBlock:completionBlock];
}

- (NSURLSessionDataTask *)getAddressListWithRequest:(RMIGetAddressListRequest *)request
                                    completionBlock:(void (^)(NSArray RWC_GENERIC(RMIContact *) *, NSError *))completionBlock
{
    return [self dataTaskForRequestSerializer:request responseParser:[RMIContact class] completionBlock:completionBlock];
}

- (NSURLSessionDataTask *)getUserInfoWithRequest:(RMIGetUserInfoRequest *)request
                                 completionBlock:(void (^)(RMIUserInfo *, NSError *))completionBlock
{
    return [self dataTaskForRequestSerializer:request responseParser:[RMIUserInfo class] completionBlock:completionBlock];
}

- (NSURLSessionDataTask *)getCreditCardWithRequest:(RMIGetCreditCardRequest *)request
                                   completionBlock:(void (^)(RMICreditCard *, NSError *))completionBlock
{
    return [self dataTaskForRequestSerializer:request responseParser:[RMICreditCard class] completionBlock:completionBlock];
}

- (NSURLSessionDataTask *)getLimitedTimePointWithRequest:(RMIGetLimitedTimePointRequest *)request
										 completionBlock:(void (^)(RMILimitedTimePoint *, NSError *))completionBlock
{
	return [self dataTaskForRequestSerializer:request responseParser:[RMILimitedTimePoint class] completionBlock:completionBlock];
}

@end
