/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RIIGetEncryptedEasyIdRequest;
@class RIIEncryptedEasyId;
@class RIIGetOpenIdRequest;
@class RIIOpenId;
@class RIIGetRaRequest;
@class RIIRa;

/**
 *  Client for Rakuten App Engine's IdInformation service.
 *
 *  A client instance can be used in conjunction with specific request classes to conveniently create NSURLSessionData tasks which can then
 *  be resumed. Like all RWClient subclasses, RIIClient inherits the RWClient::sharedClient singleton which can be used for convenience.
 *
 *  For example:
 *  @code
 *  RIIGetOpenIdRequest *request = [RIIGetOpenIdRequest requestWithAccessToken:accessToken];
 *
 *  NSURLSessionDataTask *dataTask;
 *  dataTask = [[RIIClient sharedClient] getOpenIdWithRequest:request 
 *                                            completionBlock:^(RIIOpenId * __nullable result, NSError * __nullable error) 
 *  {
 *      // Use the returned result;
 *  }];
 *  [dataTask resume];
 *
 *  @endcode
 *
 *  @note This uses the @c +sharedSession of NSURLSession to generate NSURLSessionDataTasks. All returned data tasks must be resumed.
 *
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=276662257
 *
 *  @class RIIClient RIIClient.h <RakutenIdInformationClient/RIIClient.h>
 *  @ingroup RIICoreComponents
 */
RWC_EXPORT @interface RIIClient : RWClient

/**
 *  Produces an NSURLSessionDataTask for requesting to get an open Id from the endpoint.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=384374896
 *
 *  @param request
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)getOpenIdWithRequest:(RIIGetOpenIdRequest *)request
                                        completionBlock:(void (^)(RIIOpenId * __nullable result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask for requesting to get an encrypted easy Id from the endpoint.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=660276417
 *
 *  @param request
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)getEncryptedEasyIdWithRequest:(RIIGetEncryptedEasyIdRequest *)request
                                                 completionBlock:(void (^)(RIIEncryptedEasyId * __nullable result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask for requesting to get a Ra key from the endpoint.
 *
 *  @note The returned data task must be resumed.
 *  @see http://ws-jenkins.stg-jpe1.rakuten.rpaas.net/job/rae.document/lastSuccessfulBuild/artifact/dist/index.html#/main
 *
 *  @param request
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)getRaWithRequest:(RIIGetRaRequest *)request
                                    completionBlock:(void (^)(RIIRa * __nullable result, NSError *__nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END