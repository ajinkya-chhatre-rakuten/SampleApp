#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RMIGetBasicInfoRequest;
@class RMIBasicInfo;
@class RMIGetNameRequest;
@class RMIName;
@class RMIGetPointRequest;
@class RMIPoint;
@class RMIGetRankRequest;
@class RMIRank;
@class RMIGetEmailRequest;
@class RMIEmail;
@class RMIGetAddressRequest;
@class RMIAddress;
@class RMIGetTelephoneRequest;
@class RMITelephone;
@class RMIGetSafeBulkRequest;
@class RMISafeBulk;
@class RMIGetAddressListRequest;
@class RMIContact;
@class RMIGetUserInfoRequest;
@class RMIUserInfo;
@class RMIGetCreditCardRequest;
@class RMICreditCard;
@class RMIGetLimitedTimePointRequest;
@class RMILimitedTimePoint;

/**
 *  Client for Rakuten App Engine's MemberInformation service.
 *
 *  A client instance can be used in conjunction with specific request classes to conveniently create NSURLSessionData tasks which can then
 *  be resumed. Like all RWClient subclasses, RMIClient inherits the RWClient::sharedClient singleton which can be used for convenience.
 *
 *  For example:
 *  @code
 *  RMIGetBasicInfoRequest *request = [RMIGetBasicInfoRequest requestWithAccessToken:memberAccessToken];
 *
 *  NSURLSessionDataTask *dataTask;
 *  dataTask = [[RMIClient sharedClient] getBasicInfoWithRequest:request
 *                                               completionBlock:^(RMIBasicInfo *result, NSError *error)
 *  {
 *      // Use the returned result
 *  }];
 *
 *  [dataTask resume];
 *  @endcode
 *
 *  @note This uses the @c +sharedSession of NSURLSession to generate NSURLSessionDataTasks. All returned data tasks must be resumed.
 *
 *  @see https://confluence.rakuten-it.com/confluence/display/RAED/MemberInformation+API and
 *       https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=657983438
 *
 *  @class RMIClient RMIClient.h <RakutenMemberInformationClient/RMIClient.h>
 *  @ingroup RMICoreComponents
 */
RWC_EXPORT @interface RMIClient : RWClient

/**
 *  Produces an NSURLSessionDataTask for requesting basic Japan Ichiba member profile information.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=274144424
 *
 *  @param request         The Japan Ichiba member profile information to request
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)getBasicInfoWithRequest:(RMIGetBasicInfoRequest *)request
                                           completionBlock:(void (^)(RMIBasicInfo * __nullable result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask for requesting basic Japan Ichiba member's name information.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/display/RAED/Get+Name+API+version+2011-09-01
 *
 *  @param request         The Japan Ichiba member name information to request
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)getNameWithRequest:(RMIGetNameRequest *)request
                                      completionBlock:(void (^)(RMIName *__nullable result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask for requesting basic Japan Ichiba member's Rakuten point information.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/display/RAED/Get+Point+API+version+2011-06-01
 *
 *  @param request         The Japan Ichiba member Rakuten point information to request
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)getPointWithRequest:(RMIGetPointRequest *)request
                                       completionBlock:(void (^)(RMIPoint *__nullable result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask for requesting basic Japan Ichiba member's rank information.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/display/RAED/Get+Point+Rank+API
 *
 *  @param request         The Japan Ichiba member rank information to request
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)getRankWithRequest:(RMIGetRankRequest *)request
                                      completionBlock:(void (^)(RMIRank *__nullable result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask for requesting basic Japan Ichiba member's email information(both mobile and pc).
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=654674622
 *
 *  @param request         The Japan Ichiba member email information(both mobile and pc) to request
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)getEmailWithRequest:(RMIGetEmailRequest *)request
                                       completionBlock:(void (^)(RMIEmail *__nullable result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask for requesting basic Japan Ichiba member's address information.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/display/RAED/Get+Address+API+version+2011-09-11
 *
 *  @param request         The Japan Ichiba member address information to request
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)getAddressWithRequest:(RMIGetAddressRequest *)request
                                         completionBlock:(void (^)(RMIAddress *__nullable result, NSError *__nullable error))completionBlock;


/**
 *  Produces an NSURLSessionDataTask for requesting basic Japan Ichiba member's telephone, mobile phone and fax number information.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=654679391
 *
 *  @param request         The Japan Ichiba member telephone, mobile phone and fax number information to request
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)getTelephoneWithRequest:(RMIGetTelephoneRequest *)request
                                           completionBlock:(void (^)(RMITelephone *__nullable result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask for requesting bulk Japan Ichiba member information.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=507645794
 *
 *  @param request         The Japan Ichiba member information to request.
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)getSafeBulkWithRequest:(RMIGetSafeBulkRequest *)request
                                          completionBlock:(void (^)(RMISafeBulk *__nullable result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask for requesting Japan Ichiba member contact information.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=654677455
 *
 *  @param request         The Japan Ichiba member information to request.
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)getAddressListWithRequest:(RMIGetAddressListRequest *)request
                                             completionBlock:(void (^)(NSArray RWC_GENERIC(RMIContact *) *__nullable result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask for requesting Japan Ichiba member information.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=274144424
 *
 *  @param request         The Japan Ichiba member information to request.
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)getUserInfoWithRequest:(RMIGetUserInfoRequest *)request
                                          completionBlock:(void (^)(RMIUserInfo *__nullable result, NSError *__nullable error))completionBlock;

/**
 *  Produces an NSURLSessionDataTask for requesting Japan Ichiba credit card information.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=709317428
 *
 *  @param request         The Japan Ichiba member's credit card information to request.
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */
- (nullable NSURLSessionDataTask *)getCreditCardWithRequest:(RMIGetCreditCardRequest *)request
                                            completionBlock:(void (^)(RMICreditCard *__nullable result, NSError *__nullable error))completionBlock
                                            DEPRECATED_MSG_ATTRIBUTE("Do not use. The RAE MemberInformation/GetCredit/20120425 API has been abolished.");


/**
 *  Produces an NSURLSessionDataTask for requesting basic Japan Ichiba member's earliest expiring 8 Term Limited Points information.
 *
 *  @note The returned data task must be resumed.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=1195209459
 *
 *  @param request         The Japan Ichiba member's limited time points information to request
 *  @param completionBlock A completion block executed when the returned data task resolves
 *
 *  @return A resumable data task or nil if an error occured
 */

- (nullable NSURLSessionDataTask *)getLimitedTimePointWithRequest:(RMIGetLimitedTimePointRequest *)request
												  completionBlock:(void (^)(RMILimitedTimePoint *__nullable result, NSError *__nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
