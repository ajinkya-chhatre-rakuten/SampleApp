#import "RakutenMemberInformationClient.h"
#import "RMIHelpers.h"

@implementation RMITermPointInfo
@end

@implementation RMILimitedTimePoint

+ (void)parseURLResponse:(NSURLResponse *)response
					data:(NSData *)data
				   error:(NSError *)error
		 completionBlock:(void (^)(id, NSError *))completionBlock
{
	[RWCAppEngineResponseParser parseURLResponse:response data:data error:error completionBlock:^(NSDictionary *RAEResult, NSError *RAEError) {
		RMILimitedTimePoint *result = nil;
		if (RAEResult)
		{
			@try
			{
				result = [[self alloc] init];
				
				result.termPointTotal = RMIGetUnsignedNumberFromObject(RAEResult[@"termPointTotal"]);

				NSNumber *truncatedValue = [RAEResult objectForKey:@"truncated"];
				if(truncatedValue != nil)
				{
					result.truncated = truncatedValue.boolValue;
				}
				
				NSArray *termPointInfoDetails = [RAEResult objectForKey:@"termPointInfo"];
				NSMutableArray *termPointInfos = [NSMutableArray new];
				for(NSDictionary *termPointInfoData in termPointInfoDetails)
				{
					RMITermPointInfo *termPointInfo = [RMITermPointInfo new];
					termPointInfo.termPoint = RMIGetUnsignedNumberFromObject(termPointInfoData[@"termPoint"]);
					termPointInfo.termEnd = RMIGetJapanDateFromObject(termPointInfoData[@"termEnd"]);
					[termPointInfos addObject:termPointInfo];
				}
				result.termPointInfo = termPointInfos;
			}
			@catch (NSException *exception)
			{
				result = nil;
				NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Exception raised while parsing result",
										   NSLocalizedFailureReasonErrorKey: exception.reason ?: @"Invalid server response raised an exception while parsing object."};
				RAEError = [NSError errorWithDomain:RWCAppEngineResponseParserErrorDomain
											   code:RWCAppEngineResponseParserErrorInvalidResponse
										   userInfo:userInfo];
			}
		}
		completionBlock(result, RAEError);
	}];
}

@end
