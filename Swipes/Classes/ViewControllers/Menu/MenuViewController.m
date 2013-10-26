//
//  MenuViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 13/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "MenuViewController.h"
#import "RootViewController.h"
#import "KPToolbar.h"
#import "UtilityClass.h"
#import "KPAlert.h"
#import "RESideMenu.h"
#import "KPBlurry.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "MenuButton.h"
#import "SettingsHandler.h"
#import "SnoozesViewController.h"
#import "AnalyticsHandler.h"
#define kMenuButtonStartTag 4123
#define kLampOnColor tcolor(DoneColor)
#define kLampOffColor tbackground(MenuBackground)//tcolor(StrongLaterColor)

#define kSeperatorMargin 0
#define kGridMargin valForScreen(34,20)
#define kVerticalGridNumber 2
#define kGridButtonPadding 0
#define kToolbarHeight GLOBAL_TOOLBAR_HEIGHT
@interface MenuViewController () <MFMailComposeViewControllerDelegate,ToolbarDelegate>
@property (nonatomic) IBOutletCollection(UIView) NSArray *seperators;
@property (nonatomic) IBOutletCollection(UIButton) NSMutableArray *menuButtons;
@property (nonatomic) NSMutableArray *viewControllers;
@property (nonatomic) UIView *gridView;
@property (nonatomic) KPToolbar *toolbar;
@property (nonatomic) UIPanGestureRecognizer *menuPanning;
@end

@implementation MenuViewController
-(NSMutableArray *)viewControllers{
    if(!_viewControllers) _viewControllers = [NSMutableArray array];
    return _viewControllers;
}
-(NSMutableArray *)menuButtons{
    if(_menuButtons) _menuButtons = [NSMutableArray array];
    return _menuButtons;
    
}
-(KPMenuButtons)buttonForTag:(NSInteger)tag{
    return tag - kMenuButtonStartTag;
}
-(NSInteger)tagForButton:(KPMenuButtons)button{
    return kMenuButtonStartTag + button;
}
-(void)toolbar:(KPToolbar *)toolbar pressedItem:(NSInteger)item{
    if(item == 0){
        if(self.viewControllers.count > 0){
            [self popViewControllerAnimated:YES];
            return;
        }
        KPAlert *alert = [KPAlert alertWithFrame:self.view.bounds title:@"Log out" message:@"Warning: All your data will be lost. We will introduce backup soon." block:^(BOOL succeeded, NSError *error) {
            [BLURRY dismissAnimated:YES];
            if(succeeded){
                [ROOT_CONTROLLER logOut];
            }
        }];
        [BLURRY showView:alert inViewController:self];
    }
    if(item == 1) [kSideMenu hide];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSInteger numberOfButtons = 6;
    NSInteger numberOfRows = ceil(numberOfButtons/kVerticalGridNumber);
    self.view.backgroundColor = [UIColor clearColor];
	// Do any additional setup after loading the view.
    self.toolbar = [[KPToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-kToolbarHeight, self.view.bounds.size.width, kToolbarHeight) items:@[@"logout_icon_white",@"menu_back"]];
    //[self.toolbar setBackgroundColor:tbackground(BackgroundColor)];
    self.toolbar.delegate = self;
    [self.view addSubview:self.toolbar];
    
    self.gridView = [[UIView alloc] initWithFrame:CGRectMake(0,((OSVER >= 7)?20:0),self.view.bounds.size.width-2*kGridMargin,self.view.bounds.size.height-(2*kGridMargin)-kToolbarHeight)];
    
    
    CGFloat gridWidth = self.gridView.bounds.size.width;
    CGFloat gridItemWidth = self.gridView.bounds.size.width/kVerticalGridNumber;
    CGRectSetHeight(self.gridView, numberOfRows*gridItemWidth);
    
    CGFloat gridHeight = self.gridView.bounds.size.height;
    CGFloat numberOfGrids = gridHeight / gridItemWidth;
    
    NSMutableArray *seperatorArray = [NSMutableArray array];
    
    for(NSInteger i = 1 ; i < kVerticalGridNumber ; i++){
        UIView *verticalSeperatorView = [self seperatorWithSize:gridHeight-(kSeperatorMargin*2) vertical:YES];
        verticalSeperatorView.frame = CGRectSetPos(verticalSeperatorView.frame, self.gridView.bounds.size.width/kVerticalGridNumber*i,kSeperatorMargin);
        [self.gridView addSubview:verticalSeperatorView];
    }
    for(NSInteger i = 1 ; i < numberOfRows ; i++){
        UIView *horizontalSeperatorView = [self seperatorWithSize:gridWidth-(kSeperatorMargin*2) vertical:NO];
        horizontalSeperatorView.frame = CGRectSetPos(horizontalSeperatorView.frame,kSeperatorMargin, gridHeight/numberOfGrids*i);
        [self.gridView addSubview:horizontalSeperatorView];
    }
    self.seperators = [seperatorArray copy];
    UIButton *actualButton;
    for(NSInteger i = 1 ; i <= numberOfButtons ; i++){
        KPMenuButtons button = i;
        actualButton = [self buttonForMenuButton:button];
        [self.gridView addSubview:actualButton];
    }

    [self.view addSubview:self.gridView];
    self.gridView.center = CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height-kToolbarHeight)/2);
    self.menuPanning = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    
    UIView *panningView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-kGridMargin, 0, kGridMargin, self.view.bounds.size.height)];
    [panningView addGestureRecognizer:self.menuPanning];
    [self.view addSubview:panningView];

}
-(void)panGestureRecognized:(UIPanGestureRecognizer*)sender{
    [kSideMenu panGestureRecognized:sender];
}
-(UIView*)seperatorWithSize:(CGFloat)size vertical:(BOOL)vertical{
    CGFloat width = (vertical) ? SEPERATOR_WIDTH : size;
    CGFloat height = (vertical) ? size : SEPERATOR_WIDTH;
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    seperator.backgroundColor = [UIColor whiteColor];
    return seperator;
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    //handle any error
    [controller dismissViewControllerAnimated:YES completion:nil];
}
-(void)popViewControllerAnimated:(BOOL)animated{
    NSInteger level = self.viewControllers.count;
    UIViewController *poppingViewController = [self.viewControllers lastObject];
    
    [poppingViewController removeFromParentViewController];
    
    UIView *showingView = (level == 1) ? self.gridView : [(UIViewController*)[self.viewControllers objectAtIndex:level-1] view];
    [UIView animateWithDuration:0.1 animations:^{
        poppingViewController.view.alpha = 0;
        CGRectSetY(self.toolbar, self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        showingView.alpha = 0;
        if(level == 1) [self.toolbar setItems:@[@"logout_icon_white",@"menu_back"]];
        [UIView animateWithDuration:0.2 animations:^{
            CGRectSetY(self.toolbar, self.view.bounds.size.height-kToolbarHeight);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                showingView.alpha = 1;
                
            }];
        }];
    }];
    [self.viewControllers removeLastObject];
}

-(void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated{
    NSInteger level = self.viewControllers.count;
    
    [self addChildViewController:viewController];
    UIView *hidingView = (level == 0) ? self.gridView : [(UIViewController*)[self.viewControllers lastObject] view];
    [UIView animateWithDuration:0.1 animations:^{
        hidingView.alpha = 0;
        CGRectSetY(self.toolbar, self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        viewController.view.alpha = 0;
        viewController.view.frame = self.view.bounds;
        if(level == 0)[self.toolbar setItems:@[@"backarrow_icon_white",@""]];
        CGRectSetHeight(viewController.view,viewController.view.bounds.size.height-kToolbarHeight);
        [self.view addSubview:viewController.view];
        [UIView animateWithDuration:0.2 animations:^{
            CGRectSetY(self.toolbar, self.view.bounds.size.height-kToolbarHeight);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                viewController.view.alpha = 1;
            }];
        }];
    }];
    [self.viewControllers addObject:viewController];
}
-(void)pressedMenuButton:(MenuButton*)sender{
    
    KPMenuButtons button = [self buttonForTag:sender.tag];
    switch (button) {
        case KPMenuButtonNotifications:{
            
            BOOL hasNotificationsOn = [(NSNumber*)[kSettings valueForSetting:SettingNotifications] boolValue];
            UIColor *lampColor = hasNotificationsOn ? kLampOffColor : kLampOnColor;
            NSNumber *newSettingValue = hasNotificationsOn ? @NO : @YES;
            if(hasNotificationsOn){
                KPAlert *alert = [KPAlert alertWithFrame:self.view.bounds title:@"Turn off notification" message:@"Warning: You will no longer receive alarms or reminders." block:^(BOOL succeeded, NSError *error) {
                    [BLURRY dismissAnimated:YES];
                    if(succeeded){
                        [kSettings setValue:newSettingValue forSetting:SettingNotifications];
                        [sender setLampColor:lampColor];
                    }
                }];
                [BLURRY showView:alert inViewController:self];
            }
            else{
                [kSettings setValue:newSettingValue forSetting:SettingNotifications];
                [sender setLampColor:lampColor];
            }
            
            break;
        }
        case KPMenuButtonSnoozes:{
            SnoozesViewController *snoozeVC = [[SnoozesViewController alloc] init];
            [self pushViewController:snoozeVC animated:YES];
            break;
        }
        case KPMenuButtonWalkthrough:
            [ROOT_CONTROLLER walkthrough];
            break;
        case KPMenuButtonFeedback:{
            if([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
                mailCont.mailComposeDelegate = self;
                [mailCont setToRecipients:@[@"support@swipesapp.com"]];
                [mailCont setSubject:@"Feedback for Swipes"];
                [mailCont setMessageBody:@"" isHTML:NO];
                [self presentViewController:mailCont animated:YES completion:nil];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail was not setup" message:@"You can send us feedback to support@swipesapp.com. Thanks" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                [alert show];
            }
            break;
        }
        case KPMenuButtonUpgrade:
            [ANALYTICS tagEvent:@"Teaser Shown" options:@{@"Reference From":@"Settings"}];
            [ROOT_CONTROLLER upgrade];
            break;
        case KPMenuButtonPolicy:{
            
            KPAlert *alert = [KPAlert alertWithFrame:self.view.bounds title:@"Privacy Policy" message:@"Do you want to open our privacy policy?" block:^(BOOL succeeded, NSError *error) {
                [BLURRY dismissAnimated:YES];
                if(succeeded){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://swipesapp.com/privacypolicy.pdf"]];
                }
            }];
            BLURRY.blurryTopColor = alpha(tcolor(LaterColor),0.1);
            BLURRY.blurLevel = 0.1;
            [BLURRY showView:alert inViewController:self];
            break;
        }
        default:
            break;
    }
}
-(NSString *)titleForMenuButton:(KPMenuButtons)button{
    NSString *title;
    switch (button) {
        case KPMenuButtonNotifications:
            title = @"Notifications";
            break;
        case KPMenuButtonWalkthrough:
            title = @"Walkthrough";
            break;
        case KPMenuButtonFeedback:
            title = @"Feedback";
            break;
        case KPMenuButtonSnoozes:
            title = @"Snoozes";
            break;
        case KPMenuButtonUpgrade:
            title = @"Upgrade";
            break;
        case KPMenuButtonPolicy:
            title= @"Policy";
            break;
    }
    return title;
}
-(UIImage *)imageForMenuButton:(KPMenuButtons)button highlighted:(BOOL)highlighted{
    NSString *imageString;
    switch (button) {
        case KPMenuButtonNotifications:
            imageString = @"menu_notifications";
            break;
        case KPMenuButtonWalkthrough:
            imageString = @"menu_walkthrough";
            break;
        case KPMenuButtonFeedback:
            imageString = @"menu_support";
            break;
        case KPMenuButtonSnoozes:
            imageString = @"menu_snoozes";
            break;
        case KPMenuButtonUpgrade:
            imageString = @"menu_pro";
            break;
        case KPMenuButtonPolicy:
            imageString = @"menu_policy";
            break;
    }
    if(highlighted) imageString = [imageString stringByAppendingString:@"-high"];
    return [UIImage imageNamed:imageString];
}
-(CGRect)frameForButton:(KPMenuButtons)button{
    CGFloat width = self.gridView.frame.size.width/kVerticalGridNumber-(2*kGridButtonPadding);
    CGFloat x = ((button-1) % kVerticalGridNumber) * self.gridView.frame.size.width/kVerticalGridNumber + kGridButtonPadding;
    
    CGFloat y = floor((button-1) / kVerticalGridNumber) * self.gridView.frame.size.width/kVerticalGridNumber + kGridButtonPadding;
    return CGRectMake(x, y, width, width);
}

-(UIButton*)buttonForMenuButton:(KPMenuButtons)menuButton{
    MenuButton *button = [[MenuButton alloc] initWithFrame:[self frameForButton:menuButton] title:[self titleForMenuButton:menuButton] image:[self imageForMenuButton:menuButton highlighted:NO] highlightedImage:[self imageForMenuButton:menuButton highlighted:YES]];
    if(menuButton == KPMenuButtonNotifications){
        BOOL hasNotificationsOn = [(NSNumber*)[kSettings valueForSetting:SettingNotifications] boolValue];
        UIColor *lampColor = hasNotificationsOn ? kLampOnColor : kLampOffColor;
        [button setLampColor:lampColor];
    }
    button.tag = [self tagForButton:menuButton];
    [button addTarget:self action:@selector(pressedMenuButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButtons addObject:button];
    return button;
}


-(void)pressedTut{
    [ROOT_CONTROLLER walkthrough];
    //[THEMER changeTheme];
    //[ROOT_CONTROLLER resetRoot];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
