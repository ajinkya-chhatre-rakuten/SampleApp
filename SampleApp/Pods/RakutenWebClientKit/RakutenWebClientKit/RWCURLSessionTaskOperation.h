/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RWCDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  States for an RWCURLSessionTaskOperation.
 *
 *  @internal For use by SDK components only.
 *  @enum RWCURLSessionTaskOperationState
 */
typedef NS_ENUM(NSInteger, RWCURLSessionTaskOperationState)
{
    /** Initial state. The RWCURLSessionTaskOperation hasn't been started yet. */
    RWCURLSessionTaskOperationStateWaiting = 0,

    /** The RWCURLSessionTaskOperation has been started. */
    RWCURLSessionTaskOperationStateExecuting,

    /** The task has ended. */
    RWCURLSessionTaskOperationStateFinished
};

/**
 *  `NSOperation` subclass that wraps around an `NSURLSessionTask`.
 *
 *  @internal For use by SDK components only.
 *  @class RWCURLSessionTaskOperation RWCURLSessionTaskOperation.h <RakutenWebClientKit/RWCURLSessionTaskOperation.h>
 */
RWC_EXPORT @interface RWCURLSessionTaskOperation : NSOperation

/**
 *  Designated initializer.
 *
 *  @note The task **MUST NOT** have been resumed already. It will be resumed internally by the
 *  wrapping operation once the latter is started.
 *
 *  @param task URL session task to manage.
 *  @return The receiver.
 */
- (instancetype)initWithURLSessionTask:(NSURLSessionTask *)task NS_DESIGNATED_INITIALIZER;

/**
 *  Read-only accessor for the task's internal state.
 */
@property (readonly) RWCURLSessionTaskOperationState state;
@end

NS_ASSUME_NONNULL_END

