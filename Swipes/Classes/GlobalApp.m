//
//  GlobalApp.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <sys/utsname.h>
#import "SettingsHandler.h"
#import "GlobalApp.h"

static int g_activityIndicatorStack = 0;

@interface GlobalApp ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;

@end

@implementation GlobalApp

+ (BOOL)isMailboxInstalled
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"dbx-mailbox://"]];
}

+ (BOOL)isGoogleMailInstalled
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlegmail://"]];
}

+ (BOOL)isCloudMagicInstalled
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cloudmagic://"]];
}

+ (BOOL)isEvernoteInstalled
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"en://"]];
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (CGFloat)statusBarHeight
{
    BOOL value = [[kSettings valueForSetting:SettingUseStandardStatusBar] boolValue];
    if (value) {
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
            return [UIApplication sharedApplication].statusBarFrame.size.height;
        }
        else {
            return [UIApplication sharedApplication].statusBarFrame.size.width;
        }
    }
    return 20; // this is a constant in KPTopClock
}

+ (UIImage*)screenshot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (void)activityIndicatorVisible:(BOOL)status
{
    //DLog("activity: %@\n%@", status ? @"ON" : @"OFF", [NSThread callStackSymbols]);
    if (status) {
        if (++g_activityIndicatorStack && (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible])) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
    }
    else {
        if (0 >= --g_activityIndicatorStack) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            g_activityIndicatorStack = 0;
        }
    }
}

// check http://stackoverflow.com/questions/11197509/ios-iphone-get-device-model-and-make
+ (NSString *)machineType
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *)deviceId
{
    return [UIDevice currentDevice].identifierForVendor.UUIDString;
}

+ (UIView *)topView
{
    UIWindow *topWindow = [[[UIApplication sharedApplication].windows sortedArrayUsingComparator:^NSComparisonResult(UIWindow *win1, UIWindow *win2) {
        return win1.windowLevel - win2.windowLevel;
    }] lastObject];
    return [[topWindow subviews] lastObject];
}

+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController
{
    // Handling Modal views
    if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    }
    // Handling UIViewController's added as subviews to some other views.
    else {
        for (UIView *view in [rootViewController.view subviews]) {
            id subViewController = [view nextResponder];    // Key property which most of us are unaware of / rarely use.
            if (subViewController && [subViewController isKindOfClass:[UIViewController class]]) {
                return [self topViewControllerWithRootViewController:subViewController];
            }
        }
        return rootViewController;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
    return self;
}

-(void)dealloc
{
    clearNotify();
}

- (void)endBackgroundHandler
{
    if (self.backgroundTask != UIBackgroundTaskInvalid) {
        //NSLog(@"Background time remaining = %f seconds", [UIApplication sharedApplication].backgroundTimeRemaining);
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

- (void)startBackgroundHandler
{
    if (self.backgroundTask == UIBackgroundTaskInvalid) {
        self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            //NSLog(@"Background handler called. Not running background tasks anymore.");
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }];
    }
}

@end
