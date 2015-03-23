//
//  RootViewController2.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 25/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#define SIDE_MENU_WIDTH 250
#import <UIKit/UIKit.h>
#import "KPSegmentedViewController.h"
#import "MMDrawerController.h"
typedef enum {
    KPMenuLogin = 1,
    KPMenuHome
} KPMenu;


#define ROOT_CONTROLLER [RootViewController sharedInstance]
#define ERROR_MESSAGE [[error userInfo] objectForKey:@"error"]
#define FB_ERROR_CODE [error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"code"] integerValue]
#define FB_ERROR_MESSAGE error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"message"]

@interface RootViewController : UINavigationController
+(RootViewController*)sharedInstance;
-(void)changeToMenu:(KPMenu)menu animated:(BOOL)animated;
@property (nonatomic,strong) KPSegmentedViewController *menuViewController;
@property (nonatomic,strong) MMDrawerController *drawerViewController;
@property (nonatomic) BOOL lockSettings;
-(void)resetRoot;
-(void)walkthrough;
-(void)logOut;
-(void)closeApp;
-(void)willOpen;
-(void)openApp;
-(void)feedback;
-(void)upgrade;
-(void)accountAlertWithMessage:(NSString*)message;
-(void)accountAlertWithMessage:(NSString*)message inViewController:(UIViewController*)viewController;
-(void)proWithMessage:(NSString*)message;
-(void)playVideoWithIdentifier:(NSString*)identifier;

-(void)shareTasks:(NSArray*)tasks withFrame:(CGRect)frame;
-(void)tryoutapp;
@end
