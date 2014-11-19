//
//  AppDelegate.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <Crashlytics/Crashlytics.h>
#import <FacebookSDK/FBAppCall.h>
#import <DropboxSDK/DropboxSDK.h>

#import "AppsFlyerTracker.h"
#import "NSDate-Utilities.h"
#import "Appirater.h"
#import "UtilityClass.h"
#import "LocalyticsSession.h"
#import "LocalyticsAmpSession.h"

#import "RMStore.h"
#import "NotificationHandler.h"

#import "ContactHandler.h"
#import "PaymentHandler.h"
#import "CoreSyncHandler.h"
#import "AnalyticsHandler.h"
#import "URLHandler.h"
#import "EvernoteIntegration.h"

#import "UIWindow+DHCShakeRecognizer.h"

#import <Leanplum/Leanplum.h>

#import "RootViewController.h"
#import "KPTopClock.h"
#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *parseApplicationKey;
    NSString *parseClientKey;
    NSString *analyticsKey;
    NSString *localyticsKey;
    
#ifdef RELEASE
    [Leanplum setAppId:@"8J2O981BSPJg1536460xS0tqlMRrO4u9PykB25TE9Jc" withProductionKey:@"DGeyaY7QsAtw2IuAytry41IZaC9wyhDaUSCSMoaHDFo"];
    parseApplicationKey = @"nf9lMphPOh3jZivxqQaMAg6YLtzlfvRjExUEKST3";
    parseClientKey = @"SrkvKzFm51nbKZ3hzuwnFxPPz24I9erkjvkf0XzS";
    analyticsKey = @"twdwnk4ywb";
    localyticsKey = @"0c159f237171213e5206f21-6bd270e2-076d-11e3-11ec-004a77f8b47f";
#define EVERNOTE_HOST BootstrapServerBaseURLStringUS
    NSString* const CONSUMER_KEY = @"swipes";
    NSString* const CONSUMER_SECRET = @"e862f0d879e2c2b6"; // when set to release also fix in Swipes-Info.plist file !
#else
    LEANPLUM_USE_ADVERTISING_ID;
    [Leanplum setAppId:@"8J2O981BSPJg1536460xS0tqlMRrO4u9PykB25TE9Jc" withDevelopmentKey:@"Tv0mQ7d8o3pEybHlju4DsoEIu7ryptnsXLG79BSoQSA"];
    parseApplicationKey = @"nf9lMphPOh3jZivxqQaMAg6YLtzlfvRjExUEKST3";
    parseClientKey = @"SrkvKzFm51nbKZ3hzuwnFxPPz24I9erkjvkf0XzS";
//    parseApplicationKey = @"0qD3LLZIOwLOPRwbwLia9GJXTEUnEsSlBCufqDvr";
//    parseClientKey = @"zkaCbiWV0ieyDq5pinRuzclnaeLZG9G6GFJkmXMB";
    analyticsKey = @"ncm4wfr7qc";
    localyticsKey = @"f2f927e0eafc7d3c36835fe-c0a84d84-18d8-11e3-3b24-00a426b17dd8";
#define EVERNOTE_HOST BootstrapServerBaseURLStringUS
    NSString* const CONSUMER_KEY = @"swipes";
    NSString* const CONSUMER_SECRET = @"e862f0d879e2c2b6";
/*#define EVERNOTE_HOST BootstrapServerBaseURLStringSandbox
    
    NSString* const CONSUMER_KEY = @"sulio22";
    NSString* const CONSUMER_SECRET = @"c7ed7298b3666bc4"; // when set to release also fix in Swipes-Info.plist file !*/
    //[KeenClient enableLogging];
#endif
    
    /*[Leanplum syncResourcesAsync:YES];
    [Leanplum trackAllAppScreens];
    [Leanplum start];*/
    
    
    [Appirater setAppId:@"657882159"];
    [Appirater setDaysUntilPrompt:1];
    [Appirater setUsesUntilPrompt:15];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:1];
    
    [Parse setApplicationId:parseApplicationKey
                  clientKey:parseClientKey];
    [PFFacebookUtils initializeFacebook];
    KPCORE;
    NOTIHANDLER;
    
    [Crashlytics startWithAPIKey:@"17aee5fa869f24b705e00dba6d43c51becf5c7e4"];
    [[LocalyticsSession shared] startSession:localyticsKey];

    
    
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
    [AppsFlyerTracker sharedTracker].isDebug = NO;
    [PaymentHandler sharedInstance];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // this call blocks when there is an internet connection but no real data passes through
        [self tagLaunchSource:launchOptions];
    });

    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:tcolor(TextColor)];
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [[UITextField appearance] setTintColor:tcolor(TextColor)];
    
    [ENSession setSharedSessionConsumerKey:CONSUMER_KEY
                            consumerSecret:CONSUMER_SECRET
                              optionalHost:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShake:) name:DHCSHakeNotificationName object:nil];
    /** NOTIFICATION ACTIONS
    UIMutableUserNotificationAction *action= [[UIMutableUserNotificationAction alloc] init];
    action.identifier = @"Snooze"; // The id passed when the user selects the action
    action.title = NSLocalizedString(@"Snooze",nil); // The title displayed for the action
    action.activationMode = UIUserNotificationActivationModeBackground; // Choose whether the application is launched in foreground when the action is clicked
    action.destructive = NO; // If YES, then the action is red
    action.authenticationRequired = NO; // Whether the user must authenticate to execute the action
    
    UIMutableUserNotificationCategory *category= [[UIMutableUserNotificationCategory alloc] init];
    category.identifier = @"CATEGORY_ID"; // Identifier passed in the payload
    [category setActions:@[action] forContext:UIUserNotificationActionContextDefault]; // The context determines the number of actions presented (see documentation)
    
    NSSet *categories = [NSSet setWithObjects:category,nil];
    NSUInteger types = UIUserNotificationTypeNone|UIUserNotificationTypeBadge|UIUserNotificationTypeAlert; // Add badge, sound, or alerts here
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    */
    
    //DLog(@"%lu",(long)[NSTimeZone localTimeZone].secondsFromGMT);
    //DLog(@"Machine type: %@", [GlobalApp machineType]);
    //DLog(@"Device id: %@", [GlobalApp deviceId]);
    NSLog(@"%@",[UIFont fontNamesForFamilyName:@"Gotham Rounded"]);
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
    if(![USER_DEFAULTS boolForKey:@"hasLaunchedBefore"]){
        NSDictionary* attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:[[NSBundle mainBundle] bundlePath] error:nil];
        if(!kCurrent)
            [ANALYTICS tagEvent:@"Installation" options:@{ @"Mechanism" : launchMechanism,@"Time since real install" : [NSString stringWithFormat:@"%li days",(long)[[NSDate date] daysAfterDate:[attrs fileCreationDate]]]}];
        [USER_DEFAULTS setBool:YES forKey:@"hasLaunchedBefore"];
        [USER_DEFAULTS synchronize];
    }
}
-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler{

    
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

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if([[LocalyticsAmpSession shared] handleURL:url])
        return YES;
    else
        return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
            sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL canHandle = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
    if (!canHandle) {
        canHandle = [[ENSession sharedSession] handleOpenURL:url];
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
    if (!canHandle) {
        canHandle = [[URLHandler sharedInstance] handleURL:url];
    }
    return canHandle;
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
    [NOTIHANDLER updateUpcomingNotifications];
    [ROOT_CONTROLLER closeApp];
    [[LocalyticsSession shared] close];
    [[LocalyticsSession shared] upload];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{    
    
    [ROOT_CONTROLLER willOpen];
    [Appirater appEnteredForeground:YES];
    [[LocalyticsSession shared] resume];
    [[LocalyticsSession shared] upload];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    [ROOT_CONTROLLER openApp];
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

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    UIBackgroundFetchResult result = [KPCORE synchronizeForce:YES async:NO];
    completionHandler(result);
}

- (void)onShake:(id)sender
{
    [UTILITY confirmBoxWithTitle:@"Undo last action" andMessage:@"Do you want to undo the last action?" block:^(BOOL succeeded, NSError *error) {

        if ( succeeded ){
            
            [KPCORE undo];
        
        }
        
        
    }];
}

@end
