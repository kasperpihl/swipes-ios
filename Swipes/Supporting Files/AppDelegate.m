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
#import "Mixpanel.h"
#import "AppsFlyer.h"
#import "NSDate-Utilities.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"%@",[UIFont familyNames]);
    NSLog(@"%@",[UIFont fontNamesForFamilyName:@"Proxima Nova"]);
    [Parse setApplicationId:@"nf9lMphPOh3jZivxqQaMAg6YLtzlfvRjExUEKST3"
                  clientKey:@"SrkvKzFm51nbKZ3hzuwnFxPPz24I9erkjvkf0XzS"];
    [PFFacebookUtils initializeFacebook];
    KPCORE;
    [Mixpanel sharedInstanceWithToken:@"376b7b4c4c42cbdf5294ade7d15db3c4"];
    /*MSNavigationPaneViewController *paneViewController = (MSNavigationPaneViewController *)self.window.rootViewController;
    ROOT_CONTROLLER.paneNavigationViewController = paneViewController;*/
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
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
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
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [AppsFlyer notifyAppID:@"657882159;TwJuYgpTKp9ENbxf6wMi8j"];
    NSString *isLoggedIn = ([PFUser currentUser]) ? @"yes" : @"no";
    [MIXPANEL track:@"opened app" properties:@{@"Is logged in":isLoggedIn}];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
