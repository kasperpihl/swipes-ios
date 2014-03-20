//
//  AppDelegate.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "RootViewController.h"
#import "KPParseCoreData.h"
#import "AnalyticsHandler.h"
#import "AppsFlyerTracker.h"
#import "NSDate-Utilities.h"
#import "Appirater.h"

#import <Crashlytics/Crashlytics.h>
#import <FacebookSDK/FBAppCall.h>
#import <DropboxSDK/DropboxSDK.h>

#import "RMStore.h"
#import "PaymentHandler.h"
#import "NotificationHandler.h"

#import "ContactHandler.h"

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *parseApplicationKey;
    NSString *parseClientKey;
    NSString *analyticsKey;
#ifdef RELEASE
    parseApplicationKey = @"nf9lMphPOh3jZivxqQaMAg6YLtzlfvRjExUEKST3";
    parseClientKey = @"SrkvKzFm51nbKZ3hzuwnFxPPz24I9erkjvkf0XzS";
    analyticsKey = @"twdwnk4ywb";
    
#else
    //parseApplicationKey = @"nf9lMphPOh3jZivxqQaMAg6YLtzlfvRjExUEKST3";
    //parseClientKey = @"SrkvKzFm51nbKZ3hzuwnFxPPz24I9erkjvkf0XzS";
    parseApplicationKey = @"0qD3LLZIOwLOPRwbwLia9GJXTEUnEsSlBCufqDvr";
    parseClientKey = @"zkaCbiWV0ieyDq5pinRuzclnaeLZG9G6GFJkmXMB";
    analyticsKey = @"ncm4wfr7qc";
    #define EVERNOTE_HOST BootstrapServerBaseURLStringSandbox
    //NSString* const CONSUMER_KEY = @"sulio22";
    //NSString* const CONSUMER_SECRET = @"c7ed7298b3666bc4"; // when set to release also fix in Swipes-Info.plist file !
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
    
    [Analytics debug:YES];
    
    
    // Initialize the Analytics instance with the
    // write key for username/acme-co
    [Analytics initializeWithSecret:analyticsKey];
    
    
    [Appirater appLaunched:YES];
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification)
        [self application:application didReceiveLocalNotification:notification];
    
    /*NSArray *notifications = [application scheduledLocalNotifications];
    for(UILocalNotification *lNoti in notifications){
        NSLog(@"t: %i - %@ - %@",lNoti.applicationIconBadgeNumber,lNoti.alertBody,lNoti.fireDate);
    }*/
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = @"TwJuYgpTKp9ENbxf6wMi8j";
    [AppsFlyerTracker sharedTracker].appleAppID = @"657882159";
    
    [PaymentHandler sharedInstance];
    [self tagLaunchSource:launchOptions];
    
    if (OSVER >= 7) {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
        [[UITextField appearance] setTintColor:tcolor(TextColor)];

    }
    
    //[EvernoteSession setSharedSessionHost:EVERNOTE_HOST consumerKey:CONSUMER_KEY consumerSecret:CONSUMER_SECRET];
    
    //NSLog(@"%@",[kCurrent sessionToken]);
    
    
    
    
    
    
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
    NSString *isLoggedIn = (kCurrent) ? @"yes" : @"no";
    
    [ANALYTICS tagEvent:@"App Launch" options:@{ @"Mechanism" : launchMechanism , @"Is Logged in" : isLoggedIn }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
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


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
            sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL canHandle = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
    if (!canHandle) {
        if ([[NSString stringWithFormat:@"en-%@", [[EvernoteSession sharedSession] consumerKey]] isEqualToString:[url scheme]] == YES) {
            canHandle = [[EvernoteSession sharedSession] canHandleOpenURL:url];
        }
    }
    if (!canHandle) {
        if ([[DBSession sharedSession] handleOpenURL:url]) {
            if ([[DBSession sharedSession] isLinked]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"dropboxLinked" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"linked"]];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"dropboxLinked" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"linked"]];
            }
            canHandle = YES;
        }
    }
    return canHandle;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
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
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    
    
    [[PaymentHandler sharedInstance] refreshProductsWithBlock:nil];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    UIBackgroundFetchResult result = [KPCORE synchronizeForce:YES async:NO];
    completionHandler(result);
}

@end
