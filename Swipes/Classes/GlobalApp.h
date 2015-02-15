//
//  GlobalApp.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APP_StartBackgroundHandler @"APP_StartBackgroundHandler"
#define APP_EndBackgroundHandler @"APP_EndBackgroundHandler"

@interface GlobalApp : NSObject
+ (BOOL)isEvernoteInstalled;
+ (BOOL)isMailboxInstalled;
+ (BOOL)isGoogleMailInstalled;
+ (instancetype)sharedInstance;

+ (CGFloat)statusBarHeight;

+ (void)activityIndicatorVisible:(BOOL)status;
+ (NSString *)machineType;
+ (NSString *)deviceId;

- (void)startBackgroundHandler:(NSNotification *)notification;
- (void)endBackgroundHandler:(NSNotification *)notification;

@end
