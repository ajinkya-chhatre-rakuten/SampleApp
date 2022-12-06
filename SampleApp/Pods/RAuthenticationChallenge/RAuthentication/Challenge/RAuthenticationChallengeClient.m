/*
 * © Rakuten, Inc.
 */
#import <RAnalyticsBroadcast/RAnalyticsBroadcast.h>
#import <RAuthenticationChallenge/RAuthenticationChallenge.h>
#if (TARGET_OS_WATCH)
#import "WatchKit/WatchKit.h"
#endif

#pragma mark Constants & Inline helpers

NS_INLINE void _RAuthenticationLog(NSString *format, ...)
{
    va_list args;
    va_start(args, format);
#if DEBUG
    NSLogv([NSString stringWithFormat:@"[RAuthentication] %@", format], args);
#endif
    va_end(args);
}

NS_INLINE void _RAuthenticationLogSuccessOrFailure(NSString *subject, NSError *__nullable error) {
    if (error) _RAuthenticationLog(@"☠️ %@ failed with error: %@ (reason: %@)!", subject, error.localizedDescription, error.localizedFailureReason);
    else       _RAuthenticationLog(@"✅ %@ completed successfully!", subject);
}

NS_INLINE NSBlockOperation *_RAuthenticationDispatchGroupOperation(dispatch_group_t group, dispatch_block_t __nullable completion)
{
    /*
     * DO NOT USE dispatch_group_wait() inside the operaton. It will crash in
     * _dispatch_semaphore_dispose() when the operation is canceled.
     *
     * Rather, use dispatch_group_notify() outside of the operation, and make it
     * mark the latter as completed.
     */
    __block BOOL completed = NO;
    NSBlockOperation *operation = NSBlockOperation.new;
    typeof (operation) __weak weakOperation = operation;
    [operation addExecutionBlock:^{
        while (weakOperation && !weakOperation.isCancelled && !completed) usleep(10000);
    }];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (weakOperation && !weakOperation.isCancelled && completion) completion();
        
        completed = YES;
    });
    return operation;
}

NS_INLINE BOOL _RAuthenticationShouldProceed(NSOperation *operation, NSError *__nullable error)
{
    if (!operation || operation.cancelled) {
        _RAuthenticationLog(@"⚠️ %@ operation was canceled by caller. If unintentional, it might be because you're not holding a strong reference to the object that owns the queue.", operation.name);
        return NO;
    }
    
    _RAuthenticationLogSuccessOrFailure(operation.name, error);
    return YES;
}

NS_INLINE NSString *_RAuthenticationSelectorString(NSObject *object, SEL selector)
{
    return [NSString stringWithFormat:@"[%@ %@]", object.class, NSStringFromSelector(selector)];
}

/* RAUTH_EXPORT */ NSString * const RAuthenticationChallengeClientErrorDomain = @"RAuthenticationChallengeClientErrorDomain";

static const int POW_RETRY_LIMIT = 1;
static const NSTimeInterval POW_SOLVE_TIMOUT = 1.0;

NS_INLINE void MurmurHash3_x64_128 ( const void * key, const uint64_t len, const uint32_t seed, void * out );
static void solve(const char * _Nonnull key, uint32_t seed, const char * _Nonnull maskstr, long * _Nonnull iteration, NSTimeInterval * _Nonnull duration, char * _Nonnull result);

typedef void(^request_cid_completion_block_t)(NSString * _Nullable identifier, NSInteger type, NSError * _Nullable error);
typedef void(^request_cparam_completion_block_t)(NSData * _Nullable parameters, NSError * _Nullable error);

#pragma mark RAuthenticationChallengeClient

@interface RAuthenticationChallengeClient()
@property (copy, nonatomic) NSURL *baseURL;
@property (copy, nonatomic) NSString *pageId;
@property (nonatomic) NSURLSession *session;

- (void)requestChallengeIdentifierWithCompletion:(request_cid_completion_block_t)completion;
- (void)requestChallengeParametersWithIdentifier:(NSString *)identifier completion:(request_cparam_completion_block_t)completion;
@end

@implementation RAuthenticationChallengeClient

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
#pragma clang diagnostic pop

- (instancetype)initWithBaseURL:(NSURL *)baseURL pageId:(NSString *)pageId { \
    if ((self = [super init]))
    {
        self.baseURL = baseURL;
        self.pageId = pageId;
        NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration;
        configuration.timeoutIntervalForRequest = 20.0;
        _session = [NSURLSession sessionWithConfiguration:configuration];
        _session.sessionDescription = NSStringFromClass(self.class);
    }
    return self;
}

#pragma mark Public methods

- (NSOperation *)requestChallengeWithCompletion:(void(^)(RAuthenticationSolvedChallenge * _Nullable solvedChallenge, NSError * _Nullable error))completion;
{
    request_cid_completion_block_t __block cidRequestCompletion;
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSOperation *operation = _RAuthenticationDispatchGroupOperation(group, ^{
        cidRequestCompletion = nil;
    });
    operation.name = _RAuthenticationSelectorString(self, _cmd);
    
    int __block attempts = 0;
    
    cidRequestCompletion = ^void(NSString * _Nullable identifier, NSInteger type, NSError * _Nullable error)
    {
        attempts += 1;
        if (_RAuthenticationShouldProceed(operation, error))
        {
            if (error)
            {
                completion(nil, error);
            }
            else
            {
                switch (type)
                {
                    case 0: // Clear pass
                    {
                        RAuthenticationSolvedChallenge * solved = RAuthenticationSolvedChallenge.new;
                        solved.pageId = self.pageId;
                        solved.identifier = identifier;
                        solved.result = @"";
                        completion(solved, nil);
                        break;
                    }
                    case 127: // Proof of Work
                    {
                        dispatch_group_enter(group);
                        [self requestChallengeParametersWithIdentifier:identifier completion:^(NSData * _Nullable parameters, NSError * _Nullable error)
                         {
                             if (_RAuthenticationShouldProceed(operation, error))
                             {
                                 if (error)
                                 {
                                     completion(nil, error);
                                 }
                                 else
                                 {
                                     NSString * result = [self.class processProofOfWorkWithParameters:parameters attempts:attempts];
                                     if (result.length != 0)
                                     {
                                         RAuthenticationSolvedChallenge * solved = RAuthenticationSolvedChallenge.new;
                                         solved.pageId = self.pageId;
                                         solved.identifier = identifier;
                                         solved.result = result;
                                         completion(solved, nil);
                                     }
                                     else if (POW_RETRY_LIMIT - attempts >= 0)
                                     {
                                         dispatch_group_enter(group);
                                         [self requestChallengeIdentifierWithCompletion:cidRequestCompletion];
                                     }
                                     else
                                     {
                                         completion(nil, [NSError errorWithDomain:RAuthenticationChallengeClientErrorDomain code:RAuthenticationChallengeClientErrorCodeProofOfWorkTimeout userInfo:nil]);
                                     }
                                 }
                             }
                             else
                             {
                                 cidRequestCompletion = nil;
                             }
                             dispatch_group_leave(group);
                         }];
                        break;
                    }
                    default:
                        completion(nil, [NSError errorWithDomain:RAuthenticationChallengeClientErrorDomain code:RAuthenticationChallengeClientErrorCodeUnsupportedChallengeType userInfo:@{@"type":[NSNumber numberWithInteger:type]}]);
                        break;
                }
            }
        }
        else
        {
            cidRequestCompletion = nil;
        }
        dispatch_group_leave(group);
    };
    
    [self requestChallengeIdentifierWithCompletion:cidRequestCompletion];
    return operation;
}

#pragma mark Private methods

- (void)requestChallengeIdentifierWithCompletion:(request_cid_completion_block_t)completion
{
    NSString *appBundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
#if (TARGET_OS_WATCH)
    NSString *osVersion = WKInterfaceDevice.currentDevice.systemVersion;
    NSString *os = WKInterfaceDevice.currentDevice.systemName;
#else
    NSString *osVersion = [UIDevice currentDevice].systemVersion;
    NSString *os = [UIDevice currentDevice].systemName;
#endif
    
    NSDictionary * rat = @{@"app" : appBundleIdentifier ? appBundleIdentifier : @"",
                           @"app_version" : appVersion ? appVersion : @"",
                           @"os_version" : osVersion ? osVersion : @"",
                           @"os" : os ? os : @""};
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"pid":_pageId, @"rat":rat} options:NSJSONWritingPrettyPrinted error:0];
    NSURL *url = [_baseURL URLByAppendingPathComponent:@"/v1.0/c"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = data;
    
    [[_session dataTaskWithRequest:request completionHandler:^(NSData *resultData, NSURLResponse *response, NSError *error)
      {
          if (error)
          {
              completion(nil, 0, error);
          }
          else if (resultData)
          {
              NSError *JSONSerializationError;
              NSDictionary * parsedResult = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&JSONSerializationError];
              NSDictionary *parsedResponse = parsedResult[@"result"];
              NSString *challengeIdentifier = parsedResponse[@"cid"];
              NSNumber *challengeType= parsedResponse[@"ctype"];
              if( [challengeIdentifier isKindOfClass:NSString.class] && [challengeType isKindOfClass:NSNumber.class] )
              {
                  completion(challengeIdentifier, challengeType.integerValue, nil);
              }
              else
              {
                  completion(nil, 0, [NSError errorWithDomain:RAuthenticationChallengeClientErrorDomain code:RAuthenticationChallengeClientErrorCodeInvalidResponse userInfo:@{NSURLErrorKey:url, @"response":response, @"data":resultData}]);
              }
          }
          else
          {
              completion(nil, 0, [NSError errorWithDomain:RAuthenticationChallengeClientErrorDomain code:RAuthenticationChallengeClientErrorCodeInvalidResponse userInfo:@{NSURLErrorKey:url, @"response":response,}]);
          }
      }] resume];
}

- (void)requestChallengeParametersWithIdentifier:(NSString *)identifier completion:(request_cparam_completion_block_t)completion
{
    NSURL *url = [NSURL URLWithString:@"/v1.0/m" relativeToURL:_baseURL];
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    components.queryItems = @[[NSURLQueryItem queryItemWithName:@"cid" value:identifier], [NSURLQueryItem queryItemWithName:@"mtype" value:@"0"]];
    NSURL *requestURL = components.URL;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    request.HTTPMethod = @"GET";
    
    [[_session dataTaskWithRequest:request completionHandler:^(NSData *resultData, NSURLResponse *response, NSError *error)
      {
          if (error)
          {
              completion(nil, error);
          }
          else if (resultData)
          {
              completion(resultData, nil);
          }
          else
          {
              completion(nil, [NSError errorWithDomain:RAuthenticationChallengeClientErrorDomain code:RAuthenticationChallengeClientErrorCodeInvalidResponse userInfo:@{NSURLErrorKey:url, @"response":response,}]);
          }
      }] resume];
}

#pragma mark Proof of work solver wrapper

+ (NSString *)solveKey:(NSString *)key seed:(NSNumber *)seed mask:(NSString *)mask iteration:(out long *)iteration duration:(out NSTimeInterval *)duration
{
    char strbuf[17] = {'\0'};
    solve([key UTF8String], [seed unsignedIntValue], [mask UTF8String], iteration, duration, strbuf);
    return [NSString stringWithUTF8String:strbuf];
}

+ (NSString *)processProofOfWorkWithParameters:(NSData *)parameters attempts:(int)attempts
{
    NSError *JSONSerializationError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:parameters options:0 error:&JSONSerializationError];
    if (!json)
    {
        return @"";
    }
    NSString *mask = json[@"mask"];
    NSString *key = json[@"key"];
    NSNumber *seed = json[@"seed"];
    if (![mask isKindOfClass:NSString.class] || ![key isKindOfClass:NSString.class] || ![seed isKindOfClass:NSNumber.class])
    {
        return @"";
    }
    
    long iteration;
    NSTimeInterval duration;
    NSString * result = [self solveKey:key seed:seed mask:mask iteration:&iteration duration:&duration];
    NSDictionary * analytics = @{
                                 @"seed":[NSString stringWithFormat:@"%@", seed],
                                 @"key":key,
                                 @"mask":mask,
                                 @"bandwidth":[NSString stringWithFormat:@"%ld", (long)(iteration / duration)],
                                 @"time":[NSString stringWithFormat:@"%ld", (long)(duration * 1000)],
                                 @"attempts":[NSString stringWithFormat:@"%d", attempts]
                                 };
    [RABEventBroadcaster sendEventName:result.length ? @"_rem_pow_stats" : @"_rem_pow_timeout" dataObject:analytics];
    return result;
}

@end

#pragma mark Proof of work solver function

static const char * CORPUS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
static const int CORPUS_SIZE = 62;

static void solve(const char * key, uint32_t seed, const char * maskstr, long * iteration, NSTimeInterval * duration, char * result)
{
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    *duration = 0;
    *iteration = 0;
    
    uint64_t mask = strtoull(maskstr, nil, 16);
    uint32_t keylength = (uint32_t)strlen(key);
    uint64_t murmurResult[2];
    char guess[17] = {'\0'};
    strcpy(guess, key);
    
    while(true)
    {
        *iteration += 1;
        for (int i = keylength - 1; i < 16; i++) {
            int r = arc4random_uniform(CORPUS_SIZE - 1);
            guess[i] = CORPUS[r];
        }
        MurmurHash3_x64_128(guess, strlen(guess), seed, murmurResult);
        uint64_t hash = murmurResult[0] >> 48;
        *duration = [NSDate timeIntervalSinceReferenceDate] - start;
        if (mask == hash)
        {
            strcpy(result, guess);
            return;
        }
        else if (*duration > POW_SOLVE_TIMOUT)
        {
            return;
        }
    }
}

#pragma mark MurmurHash3

//-----------------------------------------------------------------------------
// Codes from: https://github.com/aappleby/smhasher/blob/master/src/MurmurHash3.cpp

#define BIG_CONSTANT(x) (x##LLU)

NS_INLINE uint64_t ROTL64 ( uint64_t x, int8_t r )
{
    return (x << r) | (x >> (64 - r));
}

//-----------------------------------------------------------------------------
// Block read - if your platform needs to do endian-swapping or can only
// handle aligned reads, do the conversion here

NS_INLINE uint64_t getblock64 ( const uint64_t * p, uint64_t i )
{
    return p[i];
}

NS_INLINE uint64_t fmix64 ( uint64_t k )
{
    k ^= k >> 33;
    k *= BIG_CONSTANT(0xff51afd7ed558ccd);
    k ^= k >> 33;
    k *= BIG_CONSTANT(0xc4ceb9fe1a85ec53);
    k ^= k >> 33;
    
    return k;
}

NS_INLINE void MurmurHash3_x64_128 ( const void * key, const uint64_t len,
                                    const uint32_t seed, void * out )
{
    const uint8_t * data = (const uint8_t*)key;
    const uint64_t nblocks = len / 16;
    
    uint64_t h1 = seed;
    uint64_t h2 = seed;
    
    const uint64_t c1 = BIG_CONSTANT(0x87c37b91114253d5);
    const uint64_t c2 = BIG_CONSTANT(0x4cf5ad432745937f);
    
    //----------
    // body
    
    const uint64_t * blocks = (const uint64_t *)(data);
    
    for(uint64_t i = 0; i < nblocks; i++)
    {
        uint64_t k1 = getblock64(blocks,i*2+0);
        uint64_t k2 = getblock64(blocks,i*2+1);
        
        k1 *= c1; k1  = ROTL64(k1,31); k1 *= c2; h1 ^= k1;
        
        h1 = ROTL64(h1,27); h1 += h2; h1 = h1*5+0x52dce729;
        
        k2 *= c2; k2  = ROTL64(k2,33); k2 *= c1; h2 ^= k2;
        
        h2 = ROTL64(h2,31); h2 += h1; h2 = h2*5+0x38495ab5;
    }
    
    //----------
    // tail
    
    const uint8_t * tail = (const uint8_t*)(data + nblocks*16);
    
    uint64_t k1 = 0;
    uint64_t k2 = 0;
    
    switch(len & 15)
    {
        case 15: k2 ^= ((uint64_t)tail[14]) << 48;
        case 14: k2 ^= ((uint64_t)tail[13]) << 40;
        case 13: k2 ^= ((uint64_t)tail[12]) << 32;
        case 12: k2 ^= ((uint64_t)tail[11]) << 24;
        case 11: k2 ^= ((uint64_t)tail[10]) << 16;
        case 10: k2 ^= ((uint64_t)tail[ 9]) << 8;
        case  9: k2 ^= ((uint64_t)tail[ 8]) << 0;
            k2 *= c2; k2  = ROTL64(k2,33); k2 *= c1; h2 ^= k2;
            
        case  8: k1 ^= ((uint64_t)tail[ 7]) << 56;
        case  7: k1 ^= ((uint64_t)tail[ 6]) << 48;
        case  6: k1 ^= ((uint64_t)tail[ 5]) << 40;
        case  5: k1 ^= ((uint64_t)tail[ 4]) << 32;
        case  4: k1 ^= ((uint64_t)tail[ 3]) << 24;
        case  3: k1 ^= ((uint64_t)tail[ 2]) << 16;
        case  2: k1 ^= ((uint64_t)tail[ 1]) << 8;
        case  1: k1 ^= ((uint64_t)tail[ 0]) << 0;
            k1 *= c1; k1  = ROTL64(k1,31); k1 *= c2; h1 ^= k1;
    };
    
    //----------
    // finalization
    
    h1 ^= len; h2 ^= len;
    
    h1 += h2;
    h2 += h1;
    
    h1 = fmix64(h1);
    h2 = fmix64(h2);
    
    h1 += h2;
    h2 += h1;
    
    ((uint64_t*)out)[0] = h1;
    ((uint64_t*)out)[1] = h2;
}
//-----------------------------------------------------------------------------
