#import "_RPushPNPMockedTask.h"
#import "_RPushPNPHelpers.h"

@interface _RPushPNPMockedTask ()
@property (nonatomic, copy) dispatch_block_t completionBlock;
@end

@implementation _RPushPNPMockedTask
{
    NSURLSessionTaskState _state;
}

- (NSURLSessionTaskState)state {
    return _state;
}

- (void)setState:(NSURLSessionTaskState)state {
    if (_state != state) {
        [self willChangeValueForKey:@"state"];
        _state = state;
        [self didChangeValueForKey:@"state"];
    }
}

- (void)fire {
    @synchronized(self) {
        if (self.state == NSURLSessionTaskStateRunning) {
            self.state = NSURLSessionTaskStateCompleted;

            dispatch_block_t block = self.completionBlock;
            self.completionBlock = nil;
            block();
        }
    }
}

- (instancetype)initWithCompletionBlock:(dispatch_block_t)completionBlock {
    if ((self = [super init])) {
        _state = NSURLSessionTaskStateSuspended;
        _completionBlock = [completionBlock copy];
    }
    return self;
}

- (void)resume {
    if (self.state == NSURLSessionTaskStateSuspended) {
        self.state = NSURLSessionTaskStateRunning;
        [self performSelectorOnMainThread:@selector(fire) withObject:nil waitUntilDone:NO];
    }
}

- (void)suspend {
    if (self.state == NSURLSessionTaskStateRunning) {
        self.state = NSURLSessionTaskStateSuspended;
    }
}

- (void)cancel {
    if (self.state == NSURLSessionTaskStateSuspended || self.state == NSURLSessionTaskStateRunning) {
        self.state = NSURLSessionTaskStateCanceling;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.state = NSURLSessionTaskStateCompleted;
        });
    }
}
@end
