#import "RPushPNPHistoryData.h"
#import "RPushPNPConstants.h"
#import "_RPushPNPHelpers.h"

@implementation RPushPNPHistoryRecordModel
- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDictionary {
    NSParameterAssert(JSONDictionary);
    if ((self = [super init])) {
        @try {
            id record = JSONDictionary[@"record"];
            if ([record isKindOfClass:[NSDictionary class]]) {
                _requestIdentifier = [RWCParserUtilities stringWithObject:record[@"requestId"]];
                _deviceName = [RWCParserUtilities stringWithObject:record[@"deviceName"]];
                _deviceFamily = [RWCParserUtilities stringWithObject:record[@"device"]];
                _alertMessage = [RWCParserUtilities stringWithObject:record[@"alert"]];
                _soundName = [RWCParserUtilities stringWithObject:record[@"sound"]];
                _pushType = [RWCParserUtilities stringWithObject:record[@"pushtype"]];

                int64_t badgeValue = [RWCParserUtilities integerWithObject:record[@"badge"]];
                if (badgeValue != INT64_MAX) {
                    _badgeNumber = @(badgeValue);
                }

                int64_t timestamp = [RWCParserUtilities integerWithObject:record[@"registerDate"]];
                if (timestamp != INT64_MAX) {
                    int64_t seconds = timestamp / 1000ll;
                    int64_t milliseconds = timestamp % 1000ll;

                    NSTimeInterval timeInteveralSince1970 = (double)seconds + (double)milliseconds / 1000.0;
                    _registrationDate = [NSDate dateWithTimeIntervalSince1970:timeInteveralSince1970];
                }

                NSString *statusString = [RWCParserUtilities stringWithObject:record[@"status"]];
                if ([statusString isEqualToString:@"read"]) {
                    _status = RPushPNPHistoryRecordStatusRead;
                }
                else if ([statusString isEqualToString:@"open"]) {
                    _status = RPushPNPHistoryRecordStatusOpen;
                }
                else if ([statusString isEqualToString:@"unread"]) {
                    _status = RPushPNPHistoryRecordStatusUnread;
                }

                NSString *customValue = [RWCParserUtilities stringWithObject:record[@"custom"]];
                if (customValue) {
                    NSError *error = nil;
                    _customKeyedValues = [NSJSONSerialization JSONObjectWithData:(id)[customValue dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
                    if (error) {
                        [NSException raise:NSInvalidArgumentException format:@"Not a valid JSON string: \"%@\"", customValue];
                        return nil;
                    }
                }

                NSString *dataValue = [RWCParserUtilities stringWithObject:record[@"data"]];
                if (dataValue) {
                    NSError *error = nil;
                    _data = [NSJSONSerialization JSONObjectWithData:(id)[dataValue dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
                    if (error) {
                        [NSException raise:NSInvalidArgumentException format:@"Not a valid JSON string: \"%@\"", dataValue];
                        return nil;
                    }
                }

                if (!_requestIdentifier && !_deviceFamily && !_registrationDate) {
                    return nil;
                }
            }
        }
        @catch (NSException *exception) {
            return nil;
        }
    }
    return self;
}
@end

@implementation RPushPNPHistoryData

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDictionary {
    NSParameterAssert(JSONDictionary);

    if ((self = [super init])) {
        @try {
            id records = JSONDictionary[@"historyData"];
            if ([records isKindOfClass:[NSArray class]]) {
                NSMutableArray *mutableRecords = [NSMutableArray arrayWithCapacity:((NSArray *)records).count];
                for (id recordJSON in records) {
                    RPushPNPHistoryRecordModel *record = [RPushPNPHistoryRecordModel.alloc initWithJSONDictionary:recordJSON];
                    if (record) {
                        [mutableRecords addObject:record];
                    }
                }
                _records = mutableRecords.copy;
                return self;
            }
            else if (records) {
                [NSException raise:NSInvalidArgumentException format:@"\"historyData\" is not an array: %@", records];
            }
        }
        @catch (NSException *exception) {
            return nil;
        }
    }
    return nil;
}

#pragma mark - RWCURLResponseParser

+ (void)parseURLResponse:(nullable NSURLResponse *)response
                    data:(nullable NSData *)data
                   error:(nullable NSError *)error
         completionBlock:(void (^)(id __nullable parsedResult, NSError *__nullable parsedError))completionBlock {
    
    /* https://confluence.rakuten-it.com/confluence/display/PNPD/Push+Notification+Platform+APIs#PushNotificationPlatformAPIs-StatusCode states that the
       PNP history API returns an RAE (not HTTP) status code of 400 when the history list is empty.
       So just check for valid payload and let AppEngine parser handle other cases.
     */
    if (!error && data) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
        if ([json isKindOfClass:[NSDictionary class]]) {
            RPushPNPHistoryData *history = [[self alloc] initWithJSONDictionary:json];
            if (history) {
                return completionBlock(history, nil);
            }
        }
    }
    
    [RWCAppEngineResponseParser parseURLResponse:response
                                            data:data
                                           error:error
                                 completionBlock:^(NSDictionary *RAEResult, NSError *RAEError) {
                                     RPushPNPHistoryData *history = nil;
                                     if (RAEResult) {
                                         history = [[self alloc] initWithJSONDictionary:RAEResult];
                                         if (!history) {
                                             NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Exception raised while parsing result",
                                                                        NSLocalizedFailureReasonErrorKey: @"Invalid server response raised an exception while parsing object."};
                                             RAEError = [NSError errorWithDomain:RWCAppEngineResponseParserErrorDomain
                                                                            code:RWCAppEngineResponseParserErrorInvalidResponse
                                                                        userInfo:userInfo];
                                         }
                                         completionBlock(history, RAEError);
                                     }
                                     else {
                                         completionBlock(nil, RAEError);
                                     }
                                 }];
}

@end
