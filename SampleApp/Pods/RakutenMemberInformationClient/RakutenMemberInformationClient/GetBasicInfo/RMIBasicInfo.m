#import "RakutenMemberInformationClient.h"

static NSDateComponents *create_date_of_birth_from_string(NSString *dateOfBirthString)
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        dateFormatter.calendar = [NSCalendar.alloc initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        dateFormatter.dateFormat = @"yyyy/MM/dd";
    });
    
    NSDate *birthDate = [dateFormatter dateFromString:dateOfBirthString];
    
    return [dateFormatter.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:birthDate];
}

@implementation RMIBasicInfo

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDictionary
{
    NSParameterAssert(JSONDictionary);
    
    if ((self = [super init]))
    {
        @try
        {
            int64_t genderInteger = [RWCParserUtilities integerWithObject:JSONDictionary[@"sex"]];
            switch (genderInteger)
            {
                case 0:
                    _gender = RMIProfileGenderMale;
                    break;
                case 1:
                    _gender = RMIProfileGenderFemale;
                    break;
                default:
                    _gender = RMIProfileGenderUndefined;
                    break;
            }
            
            NSString *dateOfBirthString = [RWCParserUtilities stringWithObject:JSONDictionary[@"birthDay"]];
            if (dateOfBirthString)
            {
                _dateOfBirthComponents = create_date_of_birth_from_string(dateOfBirthString);
            }
            
            _nickname = [RWCParserUtilities stringWithObject:JSONDictionary[@"nickName"]];
            _prefecture = [RWCParserUtilities stringWithObject:JSONDictionary[@"prefecture"]];
        }
        @catch (NSException *exception)
        {
            return nil;
        }
    }
    
    return self;
}

#pragma mark - RWCURLResponseParser

+ (void)parseURLResponse:(NSURLResponse *)response
                    data:(NSData *)data
                   error:(NSError *)error
         completionBlock:(void (^)(id, NSError *))completionBlock
{
    [RWCAppEngineResponseParser parseURLResponse:response data:data error:error completionBlock:^(NSDictionary *RAEResult, NSError *RAEError) {
        if (RAEResult)
        {
            NSError *resultParsingError = nil;
            RMIBasicInfo *result = [[self alloc] initWithJSONDictionary:RAEResult];
            if (!result)
            {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Exception raised while parsing result",
                                           NSLocalizedFailureReasonErrorKey: @"Invalid server response raised an exception while parsing object."};
                resultParsingError = [NSError errorWithDomain:RWCAppEngineResponseParserErrorDomain
                                                         code:RWCAppEngineResponseParserErrorInvalidResponse
                                                     userInfo:userInfo];
            }
            
            completionBlock(result, resultParsingError);
        }
        else
        {
            completionBlock(nil, RAEError);
        }
    }];
}

@end
