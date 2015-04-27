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

#import <DropboxSDK/DropboxSDK.h>

#import "NSDate-Utilities.h"
#import "Appirater.h"
#import "UtilityClass.h"
#import "KPToDo.h"

#import "NotificationHandler.h"


#import "PaymentHandler.h"
#import "CoreSyncHandler.h"
#import "AnalyticsHandler.h"
#import "URLHandler.h"
#import "KPTopClock.h"

#import "UIWindow+DHCShakeRecognizer.h"

#import "SettingsHandler.h"
#import "RootViewController.h"
#import "GAI.h"

#import "SWADefinitions.h"

#import "AppDelegate.h"

static NSString * const kFromAppleWatch = @"Apple Watch";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
#ifdef RELEASE
    
#else

#endif
    
#define EVERNOTE_HOST BootstrapServerBaseURLStringUS
    NSString* const CONSUMER_KEY = @"swipes";
    NSString* const CONSUMER_SECRET = @"e862f0d879e2c2b6";
    [ENSession setSharedSessionConsumerKey:CONSUMER_KEY
                            consumerSecret:CONSUMER_SECRET
                              optionalHost:nil];
    
    [Appirater setAppId:@"657882159"];
    [Appirater setDaysUntilPrompt:1];
    [Appirater setUsesUntilPrompt:15];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:1];
    [Appirater appLaunched:YES];
    
    [Parse setApplicationId:@"nf9lMphPOh3jZivxqQaMAg6YLtzlfvRjExUEKST3"
                  clientKey:@"SrkvKzFm51nbKZ3hzuwnFxPPz24I9erkjvkf0XzS"];
    
    [PFFacebookUtils initializeFacebook];
    
    [Crashlytics startWithAPIKey:@"17aee5fa869f24b705e00dba6d43c51becf5c7e4"];
    if(kCurrent){
        [Crashlytics setUserIdentifier:kCurrent.objectId];
        [Crashlytics setUserEmail:kCurrent.username];
    }
    
    [GAI sharedInstance].dispatchInterval = 20;
    //[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-41592802-4"];
    //[[GAI sharedInstance] defaultTracker].allowIDFACollection = YES;
    
    KPCORE;
    NOTIHANDLER;
    
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification)
        [self application:application didReceiveLocalNotification:notification];
    
    
    [PaymentHandler sharedInstance];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // this call blocks when there is an internet connection but no real data passes through
        [self tagLaunchSource:launchOptions];
    });

    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShake:) name:DHCSHakeNotificationName object:nil];
   
    [USER_DEFAULTS setBool:[GlobalApp isMailboxInstalled] forKey:@"isMailboxInstalled"];
    [USER_DEFAULTS synchronize];
    [self.window makeKeyAndVisible];
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
    
    NSDictionary* attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:[[NSBundle mainBundle] bundlePath] error:nil];
    NSNumber *daysSinceInstall = @([[NSDate date] daysAfterDate:[attrs fileCreationDate]]);
    BOOL isFirstTime = ![USER_DEFAULTS boolForKey:@"hasLaunchedBefore"];
    [ANALYTICS trackCategory:@"Session" action:@"App Launch" label:launchMechanism value:daysSinceInstall];
    if(isFirstTime){
        [ANALYTICS trackCategory:@"Onboarding" action:@"Installation" label:nil value:nil];
        [USER_DEFAULTS setBool:YES forKey:@"hasLaunchedBefore"];
        [USER_DEFAULTS synchronize];
    }
}

/* Handling interactive notifications */
-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler{
    if([notification.category isEqualToString:@"OneTaskCategory"] || [notification.category isEqualToString:@"BatchTasksCategory"]){
        NSArray *taskIdentifiers = [notification.userInfo objectForKey:@"identifiers"];
        NSArray *toDos;
        if(taskIdentifiers && taskIdentifiers.count > 0){
            NSPredicate *taskByTempIdPredicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@",@"tempId",taskIdentifiers];
            toDos = [KPToDo MR_findAllWithPredicate:taskByTempIdPredicate];
        }
        
        if(toDos && toDos.count > 0){
            if([identifier isEqualToString:@"Later"]){
                NSNumber *laterToday = (NSNumber*)[kSettings valueForSetting:SettingLaterToday];
                NSDate *date = [[[NSDate date] dateByAddingTimeInterval:laterToday.integerValue] dateToNearest15Minutes];
                [KPToDo scheduleToDos:toDos forDate:date save:YES from:nil];
            }
            if([identifier isEqualToString:@"Complete"]){
                [KPToDo completeToDos:toDos save:YES context:nil from:nil];
            }
        }
    }
    completionHandler();
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    completionHandler();
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
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [NOTIHANDLER updateUpcomingNotifications];
    [ROOT_CONTROLLER closeApp];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{    
    
    [ROOT_CONTROLLER willOpen];
    [Appirater appEnteredForeground:YES];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    [ROOT_CONTROLLER openApp];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    UIBackgroundFetchResult result = [KPCORE synchronizeForce:YES async:NO];
    [NOTIHANDLER updateLocalNotifications];
    completionHandler(result);
}

- (void)onShake:(id)sender
{
    [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Undo last action") andMessage:LOCALIZE_STRING(@"Do you want to undo the last action?") block:^(BOOL succeeded, NSError *error) {

        if ( succeeded ){
            [KPCORE undo];
        }
    }];
}

- (void)completeByTempId:(NSString *)tempId
{
    DLog(@"Completing with tempId: %@", tempId);
    NSArray* todos = [KPToDo findByTempId:tempId];
    if (todos) {
        [KPToDo completeToDos:todos save:YES context:nil from:kFromAppleWatch];
        DLog(@"Completing with tempId: %@ ... done", tempId);
    }
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *replyInfo))reply
{
    NSMutableDictionary* replyInfo = [NSMutableDictionary dictionary];
    id tempId;
//    tempId = [userInfo valueForKey:kKeyCmdDelete];
//    if (tempId) {
//        NSArray* todos = [KPToDo findByTempId:tempId];
//        if (todos)
//            [KPToDo deleteToDos:todos save:YES force:NO];
//    }
   
    tempId = [userInfo objectForKey:kKeyCmdComplete];
    if (tempId) {
        if ([tempId isKindOfClass:NSArray.class]) {
            NSSet* ids = tempId;
            for (NSString* tid in ids) {
                [self completeByTempId:tid];
            }
        }
        else {
            [self completeByTempId:tempId];
        }
    }

    tempId = [userInfo valueForKey:kKeyCmdSchedule];
    if (tempId) {
        NSArray* todos = [KPToDo findByTempId:tempId];
        if (todos && 0 < todos.count) {
            NSDate* scheduleDate = [userInfo valueForKey:kKeyCmdDate];
            if ((NSDate *)[NSNull null] == scheduleDate)
                scheduleDate = nil;
            [KPToDo scheduleToDos:todos forDate:scheduleDate save:YES from:kFromAppleWatch];
        }
    }

    tempId = [userInfo valueForKey:kKeyCmdAdd];
    if (tempId) {
        [KPToDo addItem:tempId priority:NO tags:nil save:YES from:kFromAppleWatch];
    }
    
    tempId = [userInfo valueForKey:kKeyCmdError];
    if (tempId) {
        [UtilityClass sendError:[NSError errorWithDomain:[tempId description] code:801 userInfo:userInfo] type:kFromAppleWatch];
    }
    
    tempId = [userInfo valueForKey:kKeyCmdAnalytics];
    if (tempId) {
        NSDictionary* data = tempId;
        if (data[kKeyAnalyticsAction] && data[kKeyAnalyticsCategory]) {
            [ANALYTICS trackEvent:data[kKeyAnalyticsAction] options:@{ @"From": kFromAppleWatch }];
            [ANALYTICS trackCategory:data[kKeyAnalyticsCategory] action:data[kKeyAnalyticsAction] label:kFromAppleWatch value:data[kKeyAnalyticsValue]];
        }
    }
    
    reply(replyInfo);
}

@end
