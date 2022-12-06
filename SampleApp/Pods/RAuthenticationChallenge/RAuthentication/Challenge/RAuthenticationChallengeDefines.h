/*
 * © Rakuten, Inc.
 */
#import <Foundation/Foundation.h>

#ifdef __cplusplus
#   define RAUTH_EXPORT extern "C" __attribute__((visibility ("default")))
#else
#   define RAUTH_EXPORT extern __attribute__((visibility ("default")))
#endif
