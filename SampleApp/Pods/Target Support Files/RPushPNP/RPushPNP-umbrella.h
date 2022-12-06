#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "RPushPNPDenyType.h"
#import "RPushPNPGetDenyTypeRequest.h"
#import "RPushPNPGetPushedHistoryRequest.h"
#import "RPushPNPHistoryData.h"
#import "RPushPNPGetUnreadCountRequest.h"
#import "RPushPNPUnreadCount.h"
#import "RPushPNPRegisterDeviceRequest.h"
#import "RPushPNPTargetedDevice.h"
#import "RPushPNPBaseRequest.h"
#import "RPushPNPClient.h"
#import "RPushPNPSetDenyTypeRequest.h"
#import "RPushPNPSetHistoryStatusRequest.h"
#import "RPushPNPUnregisterDeviceRequest.h"
#import "RPushPNP.h"
#import "RPushPNPAPIParameters.h"
#import "RPushPNPConstants.h"
#import "RPushPNPManager.h"
#import "RPushPNPProtocol.h"

FOUNDATION_EXPORT double RPushPNPVersionNumber;
FOUNDATION_EXPORT const unsigned char RPushPNPVersionString[];

