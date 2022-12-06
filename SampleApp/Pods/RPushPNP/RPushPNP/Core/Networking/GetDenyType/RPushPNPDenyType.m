#import "RPushPNPDenyType.h"

@implementation RPushPNPDenyType

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDictionary
{
    NSParameterAssert(JSONDictionary);

    if ((self = [super init]))
    {
        @try
        {
            NSMutableSet *acceptableTypes = NSMutableSet.new;
            NSMutableSet *deniedTypes     = NSMutableSet.new;

            NSString *pushtype = [RWCParserUtilities stringWithObject:JSONDictionary[@"pushtype"]];
            NSArray *encodedKeyValuePairs = [pushtype componentsSeparatedByString:@"&"];
            for (NSString *encodedKeyValuePair in encodedKeyValuePairs)
            {
                NSArray *fragments = [encodedKeyValuePair componentsSeparatedByString:@"="];
                NSString *key = fragments.firstObject;
                uint64_t flag = [RWCParserUtilities unsignedIntegerWithObject:fragments.lastObject];

                if (fragments.count != 2 || !key.length || (flag != 0ull && flag != 1ull))
                {
                    [NSException raise:NSInvalidArgumentException format:@"Bad value for key 'pushtype': %@", pushtype];
                    return nil;
                }

                if (flag)
                {
                    [deniedTypes addObject:key];
                }
                else
                {
                    [acceptableTypes addObject:key];
                }
            }

            _acceptableTypes = acceptableTypes.copy;
            _deniedTypes     = deniedTypes.copy;

            if (!_acceptableTypes.count && !_deniedTypes.count)
            {
                return nil;
            }
        }
        @catch (NSException *exception)
        {
            return nil;
        }
    }
    return self;
}

#pragma mark - RWCURLResponseParser

+ (void)parseURLResponse:(nullable NSURLResponse *)response
                    data:(nullable NSData *)data
                   error:(nullable NSError *)error
         completionBlock:(void (^)(id __nullable parsedResult, NSError *__nullable parsedError))completionBlock
{
    [RWCAppEngineResponseParser parseURLResponse:response data:data error:error completionBlock:^(NSDictionary *RAEResult, NSError *RAEError) {
        RPushPNPDenyType *result = nil;
        if (RAEResult)
        {
            // Handling of the Empty deny type
            if (![RWCParserUtilities stringWithObject:RAEResult[@"pushtype"]].length)
            {
                completionBlock(nil, nil);
            }
            else
            {
                result = [[self alloc] initWithJSONDictionary:RAEResult];
                if (!result)
                {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Exception raised while parsing result",
                                               NSLocalizedFailureReasonErrorKey: @"Invalid server response raised an exception while parsing object."};
                    RAEError = [NSError errorWithDomain:RWCAppEngineResponseParserErrorDomain
                                                   code:RWCAppEngineResponseParserErrorInvalidResponse
                                               userInfo:userInfo];
                }
                completionBlock(result, RAEError);
            }
        }
        else
        {
            completionBlock(nil, RAEError);
        }
    }];
}

@end
