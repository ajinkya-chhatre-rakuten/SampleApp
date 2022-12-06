/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import "RWCURLSessionTaskOperation.h"

static void *_RWCURLSessionTaskOperationKVOContext = &_RWCURLSessionTaskOperationKVOContext;

@interface RWCURLSessionTaskOperation ()
@property (nonatomic) NSURLSessionTask *task;
@property (readwrite) RWCURLSessionTaskOperationState state;
@property (getter=isObservingTaskState) BOOL observingTaskState;
@end

@implementation RWCURLSessionTaskOperation

- (instancetype)initWithURLSessionTask:(NSURLSessionTask *)task
{
    NSParameterAssert(task);
    
    if ((self = [super init]))
    {
        _task = task;
        _state = RWCURLSessionTaskOperationStateWaiting;
    }
    
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
#pragma clang diagnostic pop

- (void)dealloc
{
    if (self.isObservingTaskState)
    {
        // Just in case the operation deallocates before the task completes we need to remove the operation as an observer.
        [self.task removeObserver:self forKeyPath:NSStringFromSelector(@selector(state)) context:_RWCURLSessionTaskOperationKVOContext];
    }
}


#pragma mark - State notifications

+ (NSSet *)keyPathsForValuesAffectingIsExecuting
{
    return [NSSet setWithObject:NSStringFromSelector(@selector(state))];
}

- (BOOL)isExecuting
{
    return self.state == RWCURLSessionTaskOperationStateExecuting;
}

+ (NSSet *)keyPathsForValuesAffectingIsFinished
{
    return [NSSet setWithObject:NSStringFromSelector(@selector(state))];
}

- (BOOL)isFinished
{
    return self.state == RWCURLSessionTaskOperationStateFinished;
}


#pragma mark - State flow

- (void)start
{
    [super start];
    
    if (self.isCancelled)
    {
        [self finish];
    }
}

- (void)main
{
    if (!self.isCancelled)
    {
        NSAssert(self.task.state == NSURLSessionTaskStateSuspended, @"URL Session Task (%@) was resumed by something other than %@", self.task, self);
        
        // This triggers the isExecuting key-value notification
        self.state = RWCURLSessionTaskOperationStateExecuting;
        
        [self.task addObserver:self forKeyPath:NSStringFromSelector(@selector(state)) options:0 context:_RWCURLSessionTaskOperationKVOContext];
        self.observingTaskState = YES;
        
        [self.task resume];
    }
    else
    {
        [self finish];
    }
}

- (void)finish
{
    // This triggers the isFinished key-value notification
    self.state = RWCURLSessionTaskOperationStateFinished;
}

- (void)cancel
{
    // Theoretically this should cause the task to move to NSURLSessionTaskStateCancelling -> NSURLSessionTaskStateCompleted
    [self.task cancel];
    [super cancel];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == _RWCURLSessionTaskOperationKVOContext)
    {
        if (object == self.task &&
            [keyPath isEqualToString:NSStringFromSelector(@selector(state))] &&
            self.task.state == NSURLSessionTaskStateCompleted)
        {
            // When the task completes it will no longer update its state so we can remove the operation as an observer
            [self.task removeObserver:self forKeyPath:keyPath context:_RWCURLSessionTaskOperationKVOContext];
            self.observingTaskState = NO;

            dispatch_async(dispatch_get_main_queue(), ^{
                [self finish];
            });
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


@end

