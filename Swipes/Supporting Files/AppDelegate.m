//
//  AppDelegate.m
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "RootViewController.h"
#import "KPParseCoreData.h"
#import "AnalyticsHandler.h"
#import "AppsFlyer.h"
#import "NSDate-Utilities.h"
#import "Appirater.h"
#import "GAI.h"
@implementation AppDelegate
+ (NSInteger)OSVersion
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *parseApplicationKey;
    NSString *parseClientKey;
    NSString *mixpanelToken;
#ifdef RELEASE
    parseApplicationKey = @"nf9lMphPOh3jZivxqQaMAg6YLtzlfvRjExUEKST3";
    parseClientKey = @"SrkvKzFm51nbKZ3hzuwnFxPPz24I9erkjvkf0XzS";
    mixpanelToken = @"376b7b4c4c42cbdf5294ade7d15db3c4";
#else
    //parseApplicationKey = @"nf9lMphPOh3jZivxqQaMAg6YLtzlfvRjExUEKST3";
    //parseClientKey = @"SrkvKzFm51nbKZ3hzuwnFxPPz24I9erkjvkf0XzS";
    parseApplicationKey = @"0qD3LLZIOwLOPRwbwLia9GJXTEUnEsSlBCufqDvr";
    parseClientKey = @"zkaCbiWV0ieyDq5pinRuzclnaeLZG9G6GFJkmXMB";
    mixpanelToken = @"c2d2126bfce5e54436fa131cfe6085ad";
#endif
    
    [Appirater setAppId:@"657882159"];
    [Appirater setDaysUntilPrompt:1];
    [Appirater setUsesUntilPrompt:15];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:1];
    
    [Parse setApplicationId:parseApplicationKey
                  clientKey:parseClientKey];
    [PFFacebookUtils initializeFacebook];
    KPCORE;
    [Mixpanel sharedInstanceWithToken:mixpanelToken];
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 5;
    
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-41592802-2"];
    
    
    [Appirater appLaunched:YES];
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) [self application:application didReceiveLocalNotification:notification];
    
    /*NSArray *notifications = [application scheduledLocalNotifications];
    for(UILocalNotification *lNoti in notifications){
        NSLog(@"t: %i - %@ - %@",lNoti.applicationIconBadgeNumber,lNoti.alertBody,lNoti.fireDate);
    }*/

    return YES;
}
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    [ROOT_CONTROLLER.menuViewController receivedLocalNotification:notification];
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    return [PFFacebookUtils handleOpenURL:url];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [ANALYTICS endSession];
    [ROOT_CONTROLLER closeApp];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
    [ROOT_CONTROLLER openApp];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [AppsFlyer notifyAppID:@"657882159;TwJuYgpTKp9ENbxf6wMi8j"];
    NSString *isLoggedIn = ([PFUser currentUser]) ? @"yes" : @"no";
    if([isLoggedIn isEqualToString:@"yes"]) [ANALYTICS startSession];
    else [MIXPANEL track:@"Opened app" properties:@{@"Is logged in":isLoggedIn}];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
