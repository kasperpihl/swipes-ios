//
//  RootViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 25/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "RootViewController.h"
#import "FacebookCommunicator.h"
#import "URLHandler.h"

#import "ScheduleViewController.h"
#import "TodayListViewController.h"
#import "DoneViewController.h"

#import "LoginViewController.h"
#import "AnalyticsHandler.h"

#import "MenuViewController.h"
#import "KPBlurry.h"
#import "WalkthroughViewController.h"
#import "UIColor+Utilities.h"
#import "PlusAlertView.h"
#import "CoreSyncHandler.h"
#import "YTPlayerView.h"


#import "SettingsHandler.h"
#import "KPOverlay.h"

#import "KPToDo.h"
#import <MessageUI/MessageUI.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

#import "PaymentHandler.h"
#import "KPTopClock.h"

#import "KPAlert.h"
#import "UtilityClass.h"
#import "HintHandler.h"
#import "MMDrawerVisualState.h"
#import "KPAccountAlert.h"
#import "UserHandler.h"
#import "ShareViewController.h"
#import "AwesomeMenu.h"
#import <EventKit/EventKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface RootViewController () <UINavigationControllerDelegate,WalkthroughDelegate,KPBlurryDelegate,MFMailComposeViewControllerDelegate,LoginViewControllerDelegate, HintHandlerDelegate,YTPlayerViewDelegate>

@property (nonatomic,strong) MenuViewController *settingsViewController;

@property (nonatomic) NSDate *lastClose;
@property (nonatomic) KPMenu currentMenu;
@property (nonatomic) BOOL didReset;
@property MFMailComposeViewController *mailCont;

@end

@implementation RootViewController
#pragma mark - Properties

-(KPSegmentedViewController *)menuViewController{
    if(!_menuViewController){
        ScheduleViewController *vc1 = [[ScheduleViewController alloc] init];
        TodayListViewController *vc2 = [[TodayListViewController alloc] init];
        DoneViewController *vc3 = [[DoneViewController alloc] init];
        vc1.view.autoresizingMask = vc2.view.autoresizingMask = vc3.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        KPSegmentedViewController *menuViewController = [[KPSegmentedViewController alloc] initWithViewControllers:@[vc1,vc2,vc3]];
        _menuViewController = menuViewController;
    }
    return _menuViewController;
}

-(void)blurryWillShow:(KPBlurry *)blurry{
    self.lockSettings = YES;
}
-(void)blurryDidHide:(KPBlurry *)blurry{
    if(self.currentMenu != KPMenuLogin) self.lockSettings = NO;
}


-(void)fetchDataFromFacebook{
    __block NSString *requestPath = @"me?fields=email,gender";
    FBRequest *request = [FBRequest requestForGraphPath:requestPath];
    [FBC addRequest:request write:NO permissions:nil block:^BOOL(FBReturnType status, id result, NSError *error) {
        NSLog(@"fetched");
        PFUser *user = kCurrent;
        if(error) {
            return NO;
        }
        else{
            NSDictionary *userData = (NSDictionary *)result; // The result is a dictionary
            NSString *email = [userData objectForKey:@"email"];
            
            if(email){
                [user setObject:email forKey:@"email"];
            }
            NSString *gender = [userData objectForKey:@"gender"];
            if(gender)
                [user setObject:gender forKey:@"gender"];
            [user saveEventually];
            if(email)
                [user setObject:email forKey:@"username"];
            [user saveEventually];
            [ANALYTICS updateIdentity];
        }
        return NO;
    }];
}
-(void)didLoginUser:(PFUser*)user{
    [self.settingsViewController renderSubviews];
    voidBlock block = ^{
        NSDictionary* attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:[[NSBundle mainBundle] bundlePath] error:nil];
        NSDictionary *options = @{@"Days Since Install" : @([[NSDate date] daysAfterDate:[attrs fileCreationDate]]), @"Did Try App" : @([[USER_DEFAULTS objectForKey:isTryingString] boolValue])};
        if(user.isNew) {
            [ANALYTICS trackEvent:@"Signed Up" options:options];
        }
        else{
            [ANALYTICS trackEvent:@"Logged In" options:options];
        }
        if ([PFFacebookUtils isLinkedWithUser:user]){
            if (!user.email){
                [self fetchDataFromFacebook];
            }
        }
        else{
            
        }
        [ANALYTICS updateIdentity];
        [self changeToMenu:KPMenuHome animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"logged in" object:self];
    };
    if([USER_DEFAULTS boolForKey:isTryingString]){
        [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Keep data") andMessage:LOCALIZE_STRING(@"Do you want to keep the data from the test period?") block:^(BOOL succeeded, NSError *error) {
            if(!succeeded) [KPCORE clearAndDeleteData];
            block();
        }];
    }
    else{
        if(user.isNew) [[CoreSyncHandler sharedInstance] seedObjectsSave:YES];
        block();
    }
    
}

// Sent to the delegate when a PFUser is logged in.
- (void)loginViewController:(LoginViewController *)logInController didLoginUser:(PFUser *)user
{
    [self didLoginUser:user];
}

-(void)walkthrough:(WalkthroughViewController *)walkthrough didFinishSuccesfully:(BOOL)successfully
{
    [ANALYTICS popView];
    [walkthrough removeFromParentViewController];
    [OVERLAY popViewAnimated:YES];
}

#pragma mark - Public API
-(void)changeToMenu:(KPMenu)menu animated:(BOOL)animated
{
    UIViewController *viewController;
    switch(menu) {
        case KPMenuLogin:{
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            loginVC.delegate = self;
            self.lockSettings = YES;
            viewController = loginVC;
            break;
        }
        case KPMenuHome:
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(triggerWelcome) userInfo:nil repeats:NO];
            self.lockSettings = NO;
            viewController = self.menuViewController;
            break;
    }
    self.viewControllers = @[self.drawerViewController];
    self.currentMenu = menu;
    if(self.drawerViewController.openSide == MMDrawerSideLeft)
        [self.drawerViewController closeDrawerAnimated:YES completion:nil];
    
    //CGRectSetHeight(viewController.view,viewController.view.frame.size.height-100);
    //CGRectSetHeight(self.drawerViewController.view,viewController.view.frame.size.height-100);
    [self.drawerViewController setCenterViewController:viewController];
}

static RootViewController *sharedObject;
+(RootViewController *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[RootViewController allocWithZone:NULL] init];
        
    }
    return sharedObject;
}

-(void)logOut
{
    [PFUser logOut];
    [[CoreSyncHandler sharedInstance] clearAndDeleteData];
    [kUserHandler didLogout];
    [kHints reset];
    [kFilter clearAll];
    [self resetRoot];

}

-(void)resetRoot
{
    
    self.menuViewController = nil;
    [ANALYTICS clearViews];
    [self setupAppearance];
    [self.settingsViewController reset];
    //[self.sideMenu hide];
    
}

-(void)proWithMessage:(NSString*)message
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [PlusAlertView alertInView:window message:message block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [self upgrade];
        }
    }];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    //handle any error
    if (result == MFMailComposeResultSent){
        NSArray *tasks = [[self.menuViewController currentViewController] selectedItems];
        [ANALYTICS trackEvent:@"Share Tasks Sent" options:@{@"Number of Tasks":@(tasks.count)}];
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}
-(void)shareTasks:(NSArray*)tasks{
    if([MFMailComposeViewController canSendMail]) {
        
        self.mailCont.mailComposeDelegate = self;
        [self.mailCont setSubject:LOCALIZE_STRING(@"Tasks to complete")];
        
        NSString *message = LOCALIZE_STRING(@"Tasks: \r\n");
        for(KPToDo *toDo in tasks){
            message = [message stringByAppendingFormat:@"◯ %@\r\n",toDo.title];
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
            NSArray *subtasks = [[toDo getSubtasks] sortedArrayUsingDescriptors:@[sortDescriptor]];
            BOOL addedSubtasks = NO;
            for( KPToDo *subtask in subtasks){
                if(!subtask.completionDate){
                    message = [message stringByAppendingFormat:@"   ◯ %@\r\n",subtask.title];
                    addedSubtasks = YES;
                }
            }
            if(addedSubtasks)
                message = [message stringByAppendingString:@"\r\n"];
        }
        message = [message stringByAppendingString:LOCALIZE_STRING(@"\r\nSent with my Swipes – Task list made for High Achievers\r\nFree iPhone app - http://swipesapp.com")];
        [self.mailCont setMessageBody:message isHTML:NO];
        [self presentViewController:self.mailCont animated:YES completion:nil];
        [ANALYTICS trackEvent:@"Share Tasks Opened" options:@{@"Number of Tasks":@(tasks.count)}];
    }
    else{
        [UTILITY alertWithTitle:LOCALIZE_STRING(@"Mail was not setup") andMessage:LOCALIZE_STRING(@"You can send us feedback to support@swipesapp.com. Thanks")];
    }
}

-(void)accountAlertWithMessage:(NSString *)message{
    if( !message )
        message = LOCALIZE_STRING(@"Register for Swipes to safely back up your data and get Swipes Plus");
    KPAccountAlert *alert = [KPAccountAlert alertWithFrame:self.view.bounds message:message block:^(BOOL succeeded, NSError *error) {
        [BLURRY dismissAnimated:YES];
        if(succeeded){
            [ROOT_CONTROLLER changeToMenu:KPMenuLogin animated:YES];
        }
        
    }];
    BLURRY.blurryTopColor = kSettingsBlurColor;
    [BLURRY showView:alert inViewController:self];
}
-(void)feedback{
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        [mailCont setToRecipients:@[@"support@swipesapp.com"]];
        [mailCont setSubject:@"Feedback for Swipes"];
        [mailCont setMessageBody:@"" isHTML:NO];
        [self presentViewController:mailCont animated:YES completion:nil];
    }
    else{
        [UTILITY alertWithTitle:LOCALIZE_STRING(@"Mail was not setup") andMessage:LOCALIZE_STRING(@"You can send us feedback to support@swipesapp.com. Thanks")];
    }
}
-(void)upgrade{
    if(!kUserHandler.isLoggedIn){
        [self accountAlertWithMessage:nil];
        return;
    }
    
    [UTILITY alertWithTitle:LOCALIZE_STRING(@"Can't upgrade to Swipes Plus") andMessage:LOCALIZE_STRING(@"We're remaking our Plus version. Please send us your suggestions while waiting.") buttonTitles:@[[LOCALIZE_STRING(@"cancel") capitalizedString],LOCALIZE_STRING(@"Send suggestions"),LOCALIZE_STRING(@"Restore Purchases")] block:^(NSInteger number, NSError *error) {
        if( number == 1){
            [ROOT_CONTROLLER feedback];
        }
        else if(number == 2){
            [[PaymentHandler sharedInstance] restoreWithBlock:^(NSError *error) {
                if(!error){
                    [UTILITY alertWithTitle:LOCALIZE_STRING(@"Your purchase has been restored") andMessage:LOCALIZE_STRING(@"Your purchase has been restored. Welcome back!")];
                }
                else {
                    [UTILITY alertWithTitle:LOCALIZE_STRING(@"An error occured") andMessage:LOCALIZE_STRING(@"No purchases could be restored. Contact support@swipesapp.com for help.")];
                }
            }];
        }
    }];
    return;
}
-(void)pressedCloseForVideo:(UIButton*)sender{
    [[sender superview] removeFromSuperview];
}
-(void)moviePlayerDidFinish:(NSNotification*)notification{
    NSLog(@"noti %@",notification);
}
-(void)playVideoWithIdentifier:(NSString *)identifier{
  //  NSString *url = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@&hd=1",identifier];
//)[[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
    UIView *overlay = [[UIView alloc] initWithFrame:self.view.bounds];
    overlay.backgroundColor = CLEAR;
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:overlay.bounds];
    [closeButton addTarget:self action:@selector(pressedCloseForVideo:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.backgroundColor = tcolor(TextColor);
    closeButton.alpha = 0.7;
    [overlay addSubview:closeButton];
    
    CGFloat backgroundHeight = overlay.frame.size.height;
    CGFloat backgroundWidth = overlay.frame.size.width;
    CGFloat calculatedWidth = MIN(backgroundWidth,300);
    CGFloat calculatedHeight = MIN(backgroundWidth/16*8,150);
    
    
    YTPlayerView *playerView = [[YTPlayerView alloc] initWithFrame:CGRectMake((backgroundWidth-calculatedWidth)/2, (backgroundHeight-calculatedHeight)/2, calculatedWidth, calculatedHeight)];
    playerView.delegate = self;
    playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    playerView.backgroundColor = CLEAR;
    NSDictionary *playerVars = @{
                                 @"playsinline" : @1,
                                 @"autoplay": @1,
                                 @"controls": @2,
                                 @"modestbranding":@1
                                 };
    [playerView loadWithVideoId:identifier playerVars:playerVars];
    
    [overlay addSubview:playerView];
    [self.view addSubview:overlay];
    
}
-(void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state{
    NSLog(@"state:%i",state);
    if(state == kYTPlayerStateEnded)
        [[playerView superview] removeFromSuperview];
}
- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView{
    [playerView setPlaybackQuality:kYTPlaybackQualityHD1080];
    [playerView playVideo];
}

-(void)walkthrough
{
    WalkthroughViewController *viewController = [[WalkthroughViewController alloc]init];
    viewController.delegate = self;
    [self addChildViewController:viewController];
    [OVERLAY pushView:viewController.view animated:YES];
    [ANALYTICS pushView:@"Walkthrough"];
}

-(void)willOpen{
    if(self.lastClose && [[NSDate date] isLaterThanDate:[self.lastClose dateByAddingMinutes:15]]){
        [OVERLAY popAllViewsAnimated:NO];
        [self resetRoot];
        self.didReset = YES;
    }
    else if(self.lastClose) {
        [[[self menuViewController] currentViewController] update];
        [[[self menuViewController] currentViewController] deselectAllRows:self];
    }
}
-(void)handledURL{
    KPToDo* todo = [URLHandler sharedInstance].viewTodo;
    if(!self.didReset){
        if([URLHandler sharedInstance].addTodo || todo || [URLHandler sharedInstance].reset){
            [URLHandler sharedInstance].reset = NO;
            [OVERLAY popAllViewsAnimated:NO];
            [self resetRoot];
        }
    }
    if ([URLHandler sharedInstance].addTodo) {
        [self.menuViewController pressedAdd:self];
        [URLHandler sharedInstance].addTodo = NO;
    }else if (todo) {
        [URLHandler sharedInstance].viewTodo = nil;
        [[self.menuViewController currentViewController] editToDo:todo];
    }
    
    
}

-(void)changedTimeZone:(NSNotification*)notification{
    
    NSInteger from = [[notification.userInfo objectForKey:@"from"] integerValue];
    NSInteger to = [[notification.userInfo objectForKey:@"to"] integerValue];
    //NSLog(@"notif:%@",notification);
    [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Time Zone Change") andMessage:LOCALIZE_STRING(@"Do you want to move all your recurring tasks to match the change? A task @ 8:00 will be 8:00 in new time zone (Recommended)") block:^(BOOL succeeded, NSError *error) {
        
        if ( succeeded )
            [KPToDo changeTimeZoneFrom:from to:to];
        [kSettings setValue:@(to) forSetting:SettingTimeZone];
    }];
}

-(void)openApp
{
    [kSettings refreshGlobalSettingsForce:NO];
    if(self.didReset)
        self.didReset = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"opened app" object:self];
}

-(void)closeApp
{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"closing app" object:self];
    self.lastClose = [NSDate date];
}

#pragma mark - Helping methods
#pragma mark - ViewController methods

-(void)setupAppearance{
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if(!sharedObject)
        sharedObject = self;
    
    self.viewControllers = @[self.drawerViewController];
    
    if(!kCurrent){
        if([USER_DEFAULTS objectForKey:isTryingString]){
            [self changeToMenu:KPMenuHome animated:NO];
        }
        else{
            [kHints turnHintsOn:YES];
            [self changeToMenu:KPMenuLogin animated:NO];
        }
    }
    else
        [self changeToMenu:KPMenuHome animated:NO];
}

-(void)openIntegrationsWithHelper{
    [self.settingsViewController resetAndOpenIntegrations];
    if(self.drawerViewController.openSide != MMDrawerSideLeft){
        [self.drawerViewController openDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
            
        }];
    }
    
}

-(void)triggerEvernoteEvent{
    if(self.currentMenu == KPMenuHome){
        [kHints triggerHint:HintEvernoteIntegration];
    }
}

-(void)hintHandler:(HintHandler *)hintHandler triggeredHint:(Hints)hint{
    if(hint == HintEvernoteIntegration){
        [UTILITY alertWithTitle:LOCALIZE_STRING(@"New feature") andMessage:LOCALIZE_STRING(@"We've made a powerful integration with Evernote!") buttonTitles:@[LOCALIZE_STRING(@"Not now"), LOCALIZE_STRING(@"Learn more")] block:^(NSInteger number, NSError *error) {
            if( number == 1){
                [self openIntegrationsWithHelper];
            }
        }];
        
    }
}

-(void)tryoutapp{
    if(![USER_DEFAULTS objectForKey:isTryingString]){
        [USER_DEFAULTS setBool:YES forKey:isTryingString];
        [USER_DEFAULTS synchronize];
        [KPCORE seedObjectsSave:YES];
        NSDictionary* attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:[[NSBundle mainBundle] bundlePath] error:nil];
        NSDictionary *options = @{@"Days Since Install" : @([[NSDate date] daysAfterDate:[attrs fileCreationDate]])};
        [ANALYTICS trackEvent:@"Trying Out" options:options];
    }
    
    [self changeToMenu:KPMenuHome animated:YES];
    
}


-(void)triggerWelcome{
    [kHints triggerHint:HintWelcome];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([MFMailComposeViewController canSendMail]) {
        self.mailCont = [[MFMailComposeViewController alloc] init];
    }
    UTILITY.rootViewController = self;

    [self setNavigationBarHidden:YES];
    notify(@"changed theme", changedTheme);
    notify(@"handled URL", handledURL);
    notify(@"updated time zone", changedTimeZone:);
    notify(MPMoviePlayerPlaybackDidFinishNotification, moviePlayerDidFinish:);
    kHints.delegate = self;
    
    BLURRY.delegate = self;
    self.settingsViewController = [[MenuViewController alloc] init];
    self.drawerViewController = [[MMDrawerController alloc] initWithCenterViewController:self.menuViewController leftDrawerViewController:self.settingsViewController];
    self.drawerViewController.maximumLeftDrawerWidth = self.view.bounds.size.width;

    [self.drawerViewController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
        UIViewController * sideDrawerViewController;
        if(drawerSide == MMDrawerSideLeft){
            sideDrawerViewController = drawerController.leftDrawerViewController;
        }
        else if(drawerSide == MMDrawerSideRight){
            sideDrawerViewController = drawerController.rightDrawerViewController;
        }
        [sideDrawerViewController.view setAlpha:percentVisible];
    }];
    
    [self.drawerViewController setShowsShadow:NO];
    [self.drawerViewController setShouldStretchDrawer:YES];
    [self.drawerViewController setAnimationVelocity:self.drawerViewController.maximumLeftDrawerWidth * 3];
    [self pushViewController:self.drawerViewController animated:NO];
    
    KPCORE.rootController = self;
    
    [self setupAppearance];
    
    
    
    
}
-(void)changedTheme{
    UIStatusBarStyle statusBarStyle = (THEMER.currentTheme == ThemeDark) ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
    [[UIApplication sharedApplication] setStatusBarStyle: statusBarStyle];
    [kTopClock setTextColor:alpha(tcolor(TextColor),0.8)];
    NSString *newTheme = ([THEMER currentTheme] == ThemeDark) ? @"Dark" : @"Light";
    [ANALYTICS trackEvent:@"Changed Theme" options:@{@"Theme":newTheme}];
   // [self setNeedsStatusBarAppearanceUpdate];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    kTopClock.font = KP_SEMIBOLD(12);
    [self changedTheme];
    /*EKEventStore *store = [[EKEventStore alloc] init];
    
    [store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        if(!error){
            NSPredicate *predicate = [store predicateForRemindersInCalendars:nil];
            
            [store fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
                for (EKReminder *reminder in reminders) {
                    NSLog(@"%@",reminder.calendarItemIdentifier);
                    
                    // do something for each reminder
                    [KPToDo addItem:reminder.title priority:NO tags:nil save:NO from:@"Reminders"];
                }
                [KPToDo saveToSync];
            }];
        }
        else NSLog(@"%@",error);
    }];*/
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    clearNotify();
}

@end
