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
#import "LocalyticsSession.h"
#import "LocalyticsAmpSession.h"
#import <Crashlytics/Crashlytics.h>
#import <FacebookSDK/FBAppCall.h>

#import "RMStore.h"
#import "PaymentHandler.h"
#import "NotificationHandler.h"

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *parseApplicationKey;
    NSString *parseClientKey;
    NSString *mixpanelToken;
    NSString *localyticsKey;
    NSString *kitLocateKey = @"ebeea91e-563e-4b32-acf3-6505d9857789";
#ifdef RELEASE
    parseApplicationKey = @"nf9lMphPOh3jZivxqQaMAg6YLtzlfvRjExUEKST3";
    parseClientKey = @"SrkvKzFm51nbKZ3hzuwnFxPPz24I9erkjvkf0XzS";
    mixpanelToken = @"376b7b4c4c42cbdf5294ade7d15db3c4";
    localyticsKey = @"0c159f237171213e5206f21-6bd270e2-076d-11e3-11ec-004a77f8b47f";
    
#else
    //parseApplicationKey = @"nf9lMphPOh3jZivxqQaMAg6YLtzlfvRjExUEKST3";
    //parseClientKey = @"SrkvKzFm51nbKZ3hzuwnFxPPz24I9erkjvkf0XzS";
    parseApplicationKey = @"0qD3LLZIOwLOPRwbwLia9GJXTEUnEsSlBCufqDvr";
    parseClientKey = @"zkaCbiWV0ieyDq5pinRuzclnaeLZG9G6GFJkmXMB";
    mixpanelToken = @"c2d2126bfce5e54436fa131cfe6085ad";
    localyticsKey = @"f2f927e0eafc7d3c36835fe-c0a84d84-18d8-11e3-3b24-00a426b17dd8";
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
    
    [Crashlytics startWithAPIKey:@"17aee5fa869f24b705e00dba6d43c51becf5c7e4"];
    
    [[LocalyticsSession shared] startSession:localyticsKey];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [KitLocate initKitLocateWithDelegate:NOTIHANDLER APIKey:kitLocateKey];
    
    [Appirater appLaunched:YES];
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) [self application:application didReceiveLocalNotification:notification];
    
    /*NSArray *notifications = [application scheduledLocalNotifications];
    for(UILocalNotification *lNoti in notifications){
        NSLog(@"t: %i - %@ - %@",lNoti.applicationIconBadgeNumber,lNoti.alertBody,lNoti.fireDate);
    }*/
    [PaymentHandler sharedInstance];
    [self tagLaunchSource:launchOptions];
    return YES;
}
- (void)tagLaunchSource:(NSDictionary *)launchOptions
{
    /*
     More information about these launch options keys can be found at:
     
     http://developer.apple.com/library/ios/#documentation/uikit/reference/UIApplicationDelegate_Protocol/Reference/Reference.html
     
     */
    NSDictionary *launchMapping = @{
                                    UIApplicationLaunchOptionsURLKey : @"Protocol Handler",
                                    UIApplicationLaunchOptionsSourceApplicationKey : @"Another App",
                                    UIApplicationLaunchOptionsLocalNotificationKey : @"Local Notification",
                                    UIApplicationLaunchOptionsRemoteNotificationKey : @"Push Notification",
                                    UIApplicationLaunchOptionsAnnotationKey: @"Annotation Key",
                                    UIApplicationLaunchOptionsLocationKey : @"Location Event",
                                    UIApplicationLaunchOptionsNewsstandDownloadsKey : @"Newsstand"
                                    };
    NSString *launchMechanism = @"Direct";
    
    if (launchOptions)
    {
        for(NSString *launchKey in launchOptions)
        {
            if (launchMapping[launchKey])
            {
                // Record the friendly name of the launchKey
                launchMechanism = launchMapping[launchKey];
            }
            else
            {
                // Just record the key name for new source types which may be added by Apple
                launchMechanism = launchKey;
            }
            
            break;
        }
    }
    [ANALYTICS tagEvent:@"App Launch" options:@{ @"Mechanism" : launchMechanism }];
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
    if([[LocalyticsAmpSession shared] handleURL:url])
        return YES;
    else return NO;
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    [[LocalyticsSession shared] close];
    [[LocalyticsSession shared] upload];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [ROOT_CONTROLLER closeApp];
    [[LocalyticsSession shared] close];
    [[LocalyticsSession shared] upload];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
    [ROOT_CONTROLLER openApp];
    [[LocalyticsSession shared] resume];
    [[LocalyticsSession shared] upload];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [AppsFlyer notifyAppID:@"657882159;TwJuYgpTKp9ENbxf6wMi8j"];
    NSString *isLoggedIn = (kCurrent) ? @"yes" : @"no";
    [ANALYTICS tagEvent:@"App Open" options:@{@"Is Logged in":isLoggedIn}];
    
    [[LocalyticsSession shared] resume];
    [[LocalyticsSession shared] upload];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[LocalyticsSession shared] close];
    [[LocalyticsSession shared] upload];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
