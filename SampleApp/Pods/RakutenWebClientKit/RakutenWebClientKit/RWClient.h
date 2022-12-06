/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RWCDefines.h>

NS_ASSUME_NONNULL_BEGIN

@class RWCURLRequestConfiguration;
@protocol RWCURLRequestSerializable;
@protocol RWCURLResponseParser;

/**
 *  Client for producing network tasks for Rakuten web services.
 *
 *  This class can be used as-is, extended using categories, or subclassed to change initialized properties. Subclasses are not required
 *  to override any method, but if they provide a new designated initializer other than @c -init they should also either override @c -init
 *  as a convenience initializer or override @c RWClient::sharedClient to utilize the new designated initializer.
 *
 *  By default the RWClient uses the @c NSURLSession::sharedSession to produce its data tasks. Subclasses can choose to override this using
 *  the exposed Ivar.
 *
 *  @class RWClient RWClient.h <RakutenWebClientKit/RWClient.h>
 *  @ingroup RWCCoreComponents
 */
RWC_EXPORT @interface RWClient : NSObject
{
    @protected
    /**
     *  Ivar for subclasses to directly access the client configuration of the receiver
     */
    RWCURLRequestConfiguration *_clientConfiguration;
    
    /**
     *  Ivar for subclasses to directly access the session backing the receiver
     */
    NSURLSession *_session;
}

/**
 *  Shared class-specific client singleton
 *
 *  @note Unlike most singleton implementations, this method is class specific, meaning subclasses automatically receive their own class
 *        singleton without having to override this method.
 *
 *  @return The shared singleton client for the receiving class
 */
+ (instancetype)sharedClient;

/**
 *  The request configuration applied to all requests made by the client.
 *
 *  @note This property is copied for both reading and writing, meaning that the configuration object's properties cannot be altered
 *        directly without invoking the setter.
 */
@property (copy, nonatomic) RWCURLRequestConfiguration *clientConfiguration;

/**
 *  Produces a data task for issuing a Rakuten web service request.
 *
 *  This method uses the private session of the receiver to generate an NSURLSessionDataTask by serializing the request object into an
 *  NSURLRequest. If the request serialization fails, this method returns nil and immediately executes the completion block with any
 *  generated serialization error. Otherwise, when the returned data task is resumed and finishes, any resulting network response will be
 *  parsed by the given response parser class before executing the completion block with the parsed results.
 *
 *  @note The returned data task must be resumed before the network request will begin.
 *
 *  @param requestSerializer The serializable request object
 *  @param responseParser    The response parser class
 *  @param completionBlock   A completion block executed when the request finishes in success or failure. It is also executed if the
 *                           request object cannot be serialized into an NSURLRequest. This block is guaranteed to execute on the main
 *                           thread.
 *
 *  @return A resumable NSURLSessionDataTask or nil if the request could not be serialized
 */
- (nullable NSURLSessionDataTask *)dataTaskForRequestSerializer:(id<RWCURLRequestSerializable>)requestSerializer
                                                 responseParser:(Class<RWCURLResponseParser>)responseParser
                                                completionBlock:(void (^)(id __nullable result, NSError *__nullable error))completionBlock;
@end

NS_ASSUME_NONNULL_END

