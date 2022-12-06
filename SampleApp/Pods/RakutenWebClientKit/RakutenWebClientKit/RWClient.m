/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
@import ObjectiveC.runtime;
@import Darwin.libkern;
#import "RakutenWebClientKit.h"

static void perform_locked(dispatch_block_t block)
{
    static OSSpinLock spinLock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        spinLock = OS_SPINLOCK_INIT;
    });
    
    OSSpinLockLock(&spinLock);
    block();
    OSSpinLockUnlock(&spinLock);
}

static void perform_on_main_thread(dispatch_block_t block)
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@implementation RWClient

+ (instancetype)sharedClient
{
    // Unlike typical singletons using a static variable and dispatch_once, we use a global lock and associated objects to ensure that each
    // subclass of RWClient (identified by self) will receive a unique singleton specific to their class.
    __block RWClient *sharedClient;
    
    perform_locked(^{
        sharedClient = objc_getAssociatedObject(self, _cmd);
        
        if (!sharedClient)
        {
            sharedClient = [[self alloc] init];
            objc_setAssociatedObject(self, _cmd, sharedClient, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    });
    
    return sharedClient;
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        _clientConfiguration = [RWCURLRequestConfiguration new];
        _session = [NSURLSession sharedSession];
    }
    
    return self;
}

- (RWCURLRequestConfiguration *)clientConfiguration
{
    // To stop configurations from being mutated unsafely, we only return copies of the client configuration from the getter. This forces
    // the setter to be invoked to mutate the configuration.
    return [(id)_clientConfiguration copy];
}

- (void)setClientConfiguration:(RWCURLRequestConfiguration *)clientConfiguration
{
    NSParameterAssert(clientConfiguration);
    
    RWCURLRequestConfiguration *clientConfigurationCopy = [(id)clientConfiguration copy];
    
    // The global lock for the singleton is also reused (out of laziness) to lock the alteration of client configurations so we can have
    // some measure of thread safety. This shouldn't prove an issue as client configurations should not be mutated 10000x per second.
    perform_locked(^{
        if (![self->_clientConfiguration isEqual:clientConfigurationCopy])
        {
            self->_clientConfiguration = clientConfigurationCopy;
        }
    });
}

- (NSURLSessionDataTask *)dataTaskForRequestSerializer:(id<RWCURLRequestSerializable>)requestSerializer
                                        responseParser:(Class<RWCURLResponseParser>)responseParser
                                       completionBlock:(void (^)(id __nullable, NSError * __nullable))completionBlock
{
    NSParameterAssert(requestSerializer);
    NSParameterAssert(responseParser);
    NSParameterAssert(completionBlock);
    
    NSError *requestSerializationError = nil;
    NSURLRequest *request = [requestSerializer serializeURLRequestWithConfiguration:_clientConfiguration error:&requestSerializationError];
    if (!request)
    {
        perform_on_main_thread(^{
            completionBlock(nil, requestSerializationError);
        });
        
        return nil;
    }
    
    NSURLSessionDataTask *dataTask = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [responseParser parseURLResponse:response
                                    data:data
                                   error:error
                         completionBlock:^(id parsedResult, NSError *parsedError)
         {
             perform_on_main_thread(^{
                 completionBlock(parsedResult, parsedError);
             });
         }];
    }];
    
    return dataTask;
}

@end

