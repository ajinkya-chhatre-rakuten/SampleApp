#import "RakutenMemberInformationClient.h"

@implementation RMIContact

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDictionary
{
    NSParameterAssert(JSONDictionary);
    
    if ((self = [super init]))
    {
        @try
        {
            _contactIdentifier = [RWCParserUtilities stringWithObject:JSONDictionary[@"contactId"]];
            _relationIdentifier = [RWCParserUtilities stringWithObject:JSONDictionary[@"relationId"]];
            _nationalityCode = [RWCParserUtilities stringWithObject:JSONDictionary[@"nationality"]];
            _organization = [RWCParserUtilities stringWithObject:JSONDictionary[@"organization"]];
            _jobTitle = [RWCParserUtilities stringWithObject:JSONDictionary[@"jobTitle"]];
            
            _countryCode = [RWCParserUtilities stringWithObject:JSONDictionary[@"countryCode"]];
            _zipCode = [RWCParserUtilities stringWithObject:JSONDictionary[@"zip"]];
            _stateCode = [RWCParserUtilities stringWithObject:JSONDictionary[@"stateCode"]];
            _state = [RWCParserUtilities stringWithObject:JSONDictionary[@"state"]];
            _city = [RWCParserUtilities stringWithObject:JSONDictionary[@"city"]];
            _street = [RWCParserUtilities stringWithObject:JSONDictionary[@"street"]];
            
            NSString *genderString = [RWCParserUtilities stringWithObject:JSONDictionary[@"gender"]];
            if ([genderString isEqualToString:@"F"])
            {
                _gender = RMIProfileGenderFemale;
            }
            else if ([genderString isEqualToString:@"M"])
            {
                _gender = RMIProfileGenderMale;
            }
            else
            {
                _gender = RMIProfileGenderUndefined;
            }
            
            NSString *dateOfBirthString = [RWCParserUtilities stringWithObject:JSONDictionary[@"birthday"]];
            if (dateOfBirthString)
            {
                _dateOfBirthComponents = [NSDateComponents new];
                _dateOfBirthComponents.year = [[dateOfBirthString substringToIndex:4] integerValue];
                _dateOfBirthComponents.month = [[dateOfBirthString substringWithRange:NSMakeRange(4, 2)] integerValue];
                _dateOfBirthComponents.day = [[dateOfBirthString substringFromIndex:6] integerValue];
            }
            
            _nameInformation = [[RMIName alloc] init];
            _nameInformation.firstName = [RWCParserUtilities stringWithObject:JSONDictionary[@"firstName"]];
            _nameInformation.firstNameKatakana = [RWCParserUtilities stringWithObject:JSONDictionary[@"firstNameKana"]];
            _nameInformation.lastName = [RWCParserUtilities stringWithObject:JSONDictionary[@"lastName"]];
            _nameInformation.lastNameKatakana = [RWCParserUtilities stringWithObject:JSONDictionary[@"lastNameKana"]];
            
            _telephoneInformation = [[RMITelephone alloc] init];
            _telephoneInformation.telephone = [RWCParserUtilities stringWithObject:JSONDictionary[@"tel"]];
            _telephoneInformation.mobilePhone = [RWCParserUtilities stringWithObject:JSONDictionary[@"mobileTel"]];
            _telephoneInformation.faxNumber = [RWCParserUtilities stringWithObject:JSONDictionary[@"fax"]];
            
            _emailInformation = [[RMIEmail alloc] init];
            _emailInformation.emailAddress = [RWCParserUtilities stringWithObject:JSONDictionary[@"email"]];
            _emailInformation.mobileEmailAddress = [RWCParserUtilities stringWithObject:JSONDictionary[@"mobileEmail"]];
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
    [RWCAppEngineResponseParser parseURLResponse:response data:data error:error completionBlock:^(id parsedResult, NSError *parsedError) {
        NSArray *result = nil;
        if (parsedResult)
        {
            NSMutableArray *mutableResults = [NSMutableArray array];
            NSArray *JSONArray = parsedResult[@"contacts"];
            if (![JSONArray isKindOfClass:[NSArray class]])
            {
                JSONArray = nil;
                mutableResults = nil;
            }
            
            for (NSDictionary *JSONDictionary in JSONArray)
            {
                RMIContact *contact = [[self alloc] initWithJSONDictionary:JSONDictionary];
                if (!contact)
                {
                    
                    mutableResults = nil;
                    break;
                }
                else
                {
                    [mutableResults addObject:contact];
                }
            }
            
            result = [mutableResults copy];
            if (!result)
            {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Exception raised while parsing result",
                                           NSLocalizedFailureReasonErrorKey: @"Invalid server response raised an exception while parsing object."};
                parsedError = [NSError errorWithDomain:RWCAppEngineResponseParserErrorDomain
                                                  code:RWCAppEngineResponseParserErrorInvalidResponse
                                              userInfo:userInfo];
            }
        }
        
        completionBlock(result, parsedError);
    }];
}

@end
