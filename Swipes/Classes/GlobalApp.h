//
//  GlobalApp.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalApp : NSObject
+ (BOOL)isEvernoteInstalled;
+ (BOOL)isMailboxInstalled;
+ (BOOL)isGoogleMailInstalled;
+ (BOOL)isCloudMagicInstalled;
+ (instancetype)sharedInstance;

+ (CGFloat)statusBarHeight;

+ (void)activityIndicatorVisible:(BOOL)status;
+ (NSString *)machineType;
+ (NSString *)deviceId;
+ (UIView *)topView;
+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController;

- (void)startBackgroundHandler;
- (void)endBackgroundHandler;

@end
