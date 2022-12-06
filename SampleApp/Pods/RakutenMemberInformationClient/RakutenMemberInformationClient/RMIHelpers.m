/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */

#import "RMIHelpers.h"

@implementation RMIHelpers

/* RWC_EXPORT */ NSDate *RMIGetDateFromObject(id object)
{
	static NSDateFormatter *formatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = [NSDateFormatter new];
		formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
		formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en-US"];
		formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	});
	
	NSString *dateString = [RWCParserUtilities stringWithObject:object];
	return [formatter dateFromString:dateString];
}

/* RWC_EXPORT */ NSDate *RMIGetJapanDateFromObject(id object)
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"JST"];
    });
    
    NSString *dateString = [RWCParserUtilities stringWithObject:object];
    return [formatter dateFromString:dateString];
}

/* RWC_EXPORT */ NSNumber *RMIGetUnsignedNumberFromObject(id object)
{
	uint64_t number = [RWCParserUtilities unsignedIntegerWithObject:object];
	return (number != UINT64_MAX) ? @(number) : nil;
}
@end
