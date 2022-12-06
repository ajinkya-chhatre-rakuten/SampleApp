/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationCore.h>
#import "_RAuthenticationHelpers.h"

/* RAUTH_EXPORT */ NSString *const RJapanPrivacyPolicyUpdateNotification = @"RJapanPrivacyPolicyUpdateNotification";

@implementation RJapanPrivacyPolicy

static NSString *_latestVersion = @"20170213";
static NSString *_activeVersion = nil;

+ (NSString *)latestVersion
{
    return [_latestVersion copy];
}

+ (NSString *)activeVersion
{
    return [_activeVersion ?: _latestVersion copy];
}

+ (void)setActiveVersion:(NSString *)activeVersion
{
    _activeVersion = activeVersion.copy;
}
@end

NSString *const kLatestVersionKey = @"jp.co.rakuten.privacy-policy.latest";

static void fetchLatestVersion(void)
{
    /*
     * Try every 15s for 2 minutes (120s), then multiply the delay by 2 to a maximum of 5 minutes,
     * unless the backend is dead (stop).
     */

    static int64_t delay = NSEC_PER_SEC * 15;
    static int     keep  = /* 120s / 15s */ 8;

    if (keep) --keep;
    else delay = MIN(delay * 2, NSEC_PER_SEC * /* 5 * 60s */ 300);

    NSURL *url = [NSURL URLWithString:@"https://privacy.rakuten.co.jp/date/generic.txt"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:15];
    [[NSURLSession.sharedSession dataTaskWithRequest:request
                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
        NSString *body = nil;
        if (data)
        {
            body = [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
            body = [body stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        }

        BOOL retry = YES;
        if (error)
        {
            _RAuthenticationLog(@"⚠️ Failed to access %@: %@", url, error.debugDescription);
        }
        else if (http.statusCode != 200)
        {
            _RAuthenticationLog(@"⚠️ Failed to retrieve %@: Status code = %@, Body = %@", url, @(http.statusCode), body);
            if (http.statusCode == 404 || http.statusCode >= 500) retry = NO;
        }
        else if (!body.length)
        {
            _RAuthenticationLog(@"⚠️ %@ returned empty content.", url);
        }
        else if (![body isEqualToString:_latestVersion])
        {
            // New version!
            _latestVersion = body;

            [NSUserDefaults.standardUserDefaults setObject:_latestVersion forKey:kLatestVersionKey];
            [NSNotificationCenter.defaultCenter postNotificationName:RJapanPrivacyPolicyUpdateNotification object:_latestVersion];
            return;
        }

        // Retry
        if (retry)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_global_queue(0, 0), ^{
                fetchLatestVersion();
            });
        }
    }] resume];
}

static __attribute__((constructor)) void initLatestVersion(void)
{
    NSString *previous = [NSUserDefaults.standardUserDefaults stringForKey:kLatestVersionKey];
    if (previous.length) _latestVersion = previous;

    fetchLatestVersion();
}
