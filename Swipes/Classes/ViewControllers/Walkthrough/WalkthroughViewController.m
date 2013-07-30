//
//  WalkthroughViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "WalkthroughViewController.h"
#import "WalkthroughCell.h"
#import "WalkthroughTitleView.h"
#import "WalkthroughOverlayBackground.h"
#import "ToDoHandler.h"
#import "UtilityClass.h"
#import <QuartzCore/QuartzCore.h>
#define TABLE_Y valForScreen(160,200)
#define kPhoneTopToStartOfCells 116
#define TABLE_FRAME CGRectMake(13,kPhoneTopToStartOfCells,TABLE_WIDTH,375)

#define TEXT_COLOR  gray(128,1)

#define LOGO_Y valForScreen(20,30)
#define TITLE_Y valForScreen(122,140)
#define ACTION_BUTTON_WIDTH 190
#define ACTION_BUTTON_HEIGHT 44

#define ACTIVE_ROW valForScreen(1,2)

#define ACTION_BUTTON_CORNER_RADIUS 3
#define kActionButtonBorderWidth 2
#define kActionButtonFont KP_BOLD(23)

#define kMenuButtonY valForScreen(220,260)
#define kMenuButtonSize 60
#define kMenuButtonTransform 0.8
#define kMenuButtonTransformedSize (kMenuButtonSize * kMenuButtonTransform)
#define kMenuButtonSideMargin 70
#define kMenuButtonTransformedSideMargin 90
#define kHelparrowPercentage 0.4
#define kCloseButtonSize 44
#define kDefTutAnimationTime 0.4f

#define kSchedulePopupSize valForScreen(180,220)
#define kSchedulePopupY kPhoneTopToStartOfCells-20
#define kSchedulePopupTransformSize 0.2
#define kColoredPopupHeight valForScreen(250,300)

#define kTableBottomSizeForFirst valForScreen(200,250)

#define kShadowBackExtraHeight 40
#define kShadowBounce 15
#define kSignatureX 160
#define kSignatureSpacing 5

typedef enum {
    Waiting = 0,
    IntroductionPrepare,
    FocusOnTheTasksAtHand,
    SendThePhoneToTop,
    SwipeRightToComplete,
    AnimateUpDonePopup,
    FadeInDonePopupTexts,
    PressedContinueFromCompleted,
    AnimatedPopupDownFromCompleted,
    SwipeLeftToSchedule,
    SwipedToTheLeft,
    PressedSchedulePopup,
    ScheduleTaskCompleted,
    ScheduleTaskCompleted2,
    PressedContinueFromSchedule,
    ClosedSchedulePopup,
    PushDownGreenBackground,
    BounceGreenBackground,
    ShowLastTexts,
    Finish
} WalkthroughState;
@interface WalkthroughViewController () <UITableViewDelegate,UITableViewDataSource,MCSwipeTableViewCellDelegate>
@property (nonatomic) WalkthroughState currentState;

/* First view */
@property (nonatomic,strong) UIImageView *swipesLogo;
@property (nonatomic,strong) UIImageView *menuExplainer;
@property (nonatomic,strong) UIButton *actionButton;
@property (nonatomic,strong) WalkthroughTitleView *titleView;

/* The three menubuttons */
@property (nonatomic,strong) UIButton *scheduleButton;
@property (nonatomic,strong) UIButton *tasksButton;
@property (nonatomic,strong) UIButton *doneButton;

/* Swiping views */
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIImageView *phoneBackground;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) WalkthroughOverlayBackground *backgroundOverlay;
@property (nonatomic,strong) UIButton *schedulePopupButton;

@property (nonatomic,strong) UIImageView *greenBackground;
@property (nonatomic,strong) UIImageView *shadowBackground;
@property (nonatomic,strong) UIImageView *signatureImage;

@end



@implementation WalkthroughViewController
-(NSMutableArray *)items{
    if(!_items){
        _items = [@[@"Clean laundry",
                  @"Wash the dishes",
                  @"Make the accounting",
                  @"Take out trash",
                  @"Hit someone in the face",
                  @"Now play with the global team",
                  @"You are what you achieve",
                  @"This was all the tasks"
                  ] mutableCopy];
    }
    return _items;
}
-(void)next{
    self.currentState++;
}
-(void)removeActiveItem{
    NSIndexPath *activeIndexPath = [self.tableView indexPathForCell:[self activeCell]];
    [self.items removeObjectAtIndex:activeIndexPath.row];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[activeIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}
#pragma mark - Getters and setters
-(WalkthroughCell*)activeCell{
    return (WalkthroughCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:ACTIVE_ROW inSection:0]];
}
-(void)setCurrentState:(WalkthroughState)currentState{
    if(_currentState != currentState){
        if(currentState == Finish) return [self.delegate walkthrough:self didFinishSuccesfully:YES];
        else{
            [self changeToState:currentState];
        }
        _currentState = currentState;
        
    }
}
-(void)changeToState:(WalkthroughState)state{
    voidBlock preBlock = [self preBlockForState:state];
    voidBlock showBlock = [self showBlockForState:state];
    voidBlock completionBlock = [self completionBlockForState:state];
    if(state == PressedSchedulePopup) NSLog(@"loaded schedule blocks");
    CGFloat delay = [self delayForState:state];
    CGFloat duration = [self durationForState:state];
    UIViewAnimationOptions options = [self optionsForState:state];
    if(preBlock) preBlock();
    [UIView animateWithDuration:duration delay:delay options:options animations:showBlock completion:^(BOOL finished) { if(completionBlock) completionBlock(); }];
}
-(UIViewAnimationOptions)optionsForState:(WalkthroughState)state{
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut;
    switch (state) {
        case SwipeRightToComplete:
            options = UIViewAnimationOptionCurveEaseOut;
            break;
        default:
            break;
    }
    return options;
}
-(voidBlock)preBlockForState:(WalkthroughState)state{
    voidBlock block;
    switch (state) {
        case IntroductionPrepare:{
            block = ^{
                for(WalkthroughCell *cell in self.tableView.visibleCells)
                    [cell setActivated:YES animated:NO];
            };
            break;
        }
        case FocusOnTheTasksAtHand:{
            block = ^{
                [self.actionButton setTitle:@"CONTINUE" forState:UIControlStateNormal];
                [self.titleView setTitle:@"Your main focus area" subtitle:@"Add your tasks and take an action on them."];
                CGRectSetY(self.titleView, 2*LOGO_Y+kMenuButtonTransformedSize);
                CGFloat span = self.view.bounds.size.height - kTableBottomSizeForFirst - CGRectGetMaxY(self.titleView.frame);
                CGRectSetY(self.actionButton, CGRectGetMaxY(self.titleView.frame) + (span-self.actionButton.frame.size.height)/2);
            };
            break;
        }
        case SwipeRightToComplete:{ block = ^{
            [self.titleView setTitle:@"Swipe right to complete" subtitle:@"Mark your tasks as done with one simple gesture."];
            }; }
            break;
        case AnimateUpDonePopup:{
            block = ^{
                [self activeCell].helpingImage.alpha = 0;
                WalkthroughOverlayBackground *background = [[WalkthroughOverlayBackground alloc] initWithFrame:CGRectMake(0, 0, TABLE_WIDTH + 2*kBottomExtraSide, kColoredPopupHeight) block:^(BOOL succeeded, NSError *error) {
                    [self next];
                }];
                CGRectSetCenterX(background, self.phoneBackground.frame.size.width/2);
                CGRectSetY(background, (kPhoneTopToStartOfCells + (ACTIVE_ROW * roundf(TABLE_WIDTH * CELL_HEIGHT))) - background.frame.size.height);
                background.circleBottomLength = kCircleBottomOfBarToCenter + (ACTIVE_ROW * roundf(TABLE_WIDTH * CELL_HEIGHT));
                [background setLeft:NO title:@"Well done!" subtitle:@"You have completed a task. See a full history of your achievements in the “Done” area."];
                
                self.backgroundOverlay = background;
                [self.phoneBackground addSubview:self.backgroundOverlay];
                [self.backgroundOverlay show:NO];
            };
            break;
        }
        case ClosedSchedulePopup:
        case AnimatedPopupDownFromCompleted:{
            block = ^{
                [self removeActiveItem];
            };
            break;
        }
        case SwipeLeftToSchedule:{
            block = ^{
                WalkthroughCell *activeCell = [self activeCell];
                [activeCell setActivatedDirection:MCSwipeTableViewCellActivatedDirectionLeft];
                CGRectSetX(activeCell.helpingImage, activeCell.frame.size.width - activeCell.helpingImage.frame.size.width);
                [self activeCell].helpingImage.image = [UIImage imageNamed:@"walkthrough_swipe_schedule"];
                [self.titleView setTitle:@"Swipe left to snooze." subtitle:@"Keep focus on the important tasks, schedule the rest for later."];
            };
            break;
        }
        case SwipedToTheLeft:{
            block = ^{
                self.schedulePopupButton = [UIButton buttonWithType:UIButtonTypeCustom];
                self.schedulePopupButton.frame = CGRectMake((self.phoneBackground.frame.size.width - kSchedulePopupSize)/2, kSchedulePopupY, kSchedulePopupSize, kSchedulePopupSize);
                [self.schedulePopupButton addTarget:self action:@selector(pressedSchedule:) forControlEvents:UIControlEventTouchUpInside];
                UIImage *image = [UtilityClass imageWithName:@"wt_schedule_popup" scaledToSize:CGSizeMake(kSchedulePopupSize, kSchedulePopupSize)];
                [self.schedulePopupButton setImage:image forState:UIControlStateNormal];
                [self.schedulePopupButton setImage:image forState:UIControlStateHighlighted];
                [self activeCell].helpingImage.alpha = 0;
                self.schedulePopupButton.transform = CGAffineTransformMakeScale(kSchedulePopupTransformSize, kSchedulePopupTransformSize);
                [self.phoneBackground addSubview:self.schedulePopupButton];
            };
            break;
        }
        case ScheduleTaskCompleted:{
            block = ^{
                WalkthroughOverlayBackground *background = [[WalkthroughOverlayBackground alloc] initWithFrame:CGRectMake(0, 0, TABLE_WIDTH + 2*kBottomExtraSide, kColoredPopupHeight) block:^(BOOL succeeded, NSError *error) {
                    [self next];
                }];
                CGRectSetCenterX(background, self.phoneBackground.frame.size.width/2);
                CGRectSetY(background, (kPhoneTopToStartOfCells + (ACTIVE_ROW * roundf(TABLE_WIDTH * CELL_HEIGHT))) - background.frame.size.height);
                background.circleBottomLength = kCircleBottomOfBarToCenter + (ACTIVE_ROW * roundf(TABLE_WIDTH * CELL_HEIGHT));
                [background setLeft:YES title:@"Well done!" subtitle:@"You have snoozed a task. See your upcoming tasks in the “Later” area."];
                self.backgroundOverlay = background;
                [self.phoneBackground addSubview:self.backgroundOverlay];
                [self.backgroundOverlay show:NO];
            };
            break;
        }
        case PushDownGreenBackground:{
            block = ^{
                self.greenBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wt_green_background"]];
                self.shadowBackground = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"wt_background_shadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 0, 0, 0)]];
                self.shadowBackground.contentMode = UIViewContentModeScaleToFill;
                CGRectSetHeight(self.shadowBackground, self.greenBackground.frame.size.height+kShadowBackExtraHeight);
                CGRectSetY(self.shadowBackground, -kShadowBackExtraHeight);
                [self.view addSubview:self.greenBackground];
                [self.view addSubview:self.shadowBackground];
            };
            break;
        }
        case ShowLastTexts:{
            block = ^{
                self.signatureImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wt_signature"]];
                self.signatureImage.alpha = 0;
                CGRectSetY(self.actionButton, self.view.bounds.size.height-LOGO_Y - self.actionButton.frame.size.height);
                [self.titleView setTitle:@"Log in and start swiping" subtitle:@"P.S. The best features are yet to\ncome!\n\n     Love,"];
                CGFloat span = self.actionButton.frame.origin.y - CGRectGetMaxY(self.shadowBackground.frame);
                CGFloat actualHeight = self.titleView.frame.size.height + self.signatureImage.frame.size.height + kSignatureSpacing;
                CGFloat titleY = CGRectGetMaxY(self.shadowBackground.frame) + (span-actualHeight)/2;
                CGRectSetY(self.titleView, titleY);
                CGRectSetX(self.signatureImage, kSignatureX);
                CGRectSetY(self.signatureImage, CGRectGetMaxY(self.titleView.frame) + kSignatureSpacing);
                [self.view addSubview:self.signatureImage];
                
                
                [self.actionButton setTitle:@"GOT IT" forState:UIControlStateNormal];
            };
            break;
        }
        default:
            break;
    }
    return block;
}
-(voidBlock)showBlockForState:(WalkthroughState)state{
    voidBlock block;
    switch (state) {
        case IntroductionPrepare:{
            block = ^{
                self.actionButton.alpha = 0;
                self.swipesLogo.alpha = 0;
                self.titleView.alpha = 0;
                self.menuExplainer.alpha = 0;
                self.doneButton.backgroundColor = gray(179,1);
                self.scheduleButton.backgroundColor = gray(179,1);
                NSLog(@"%f",CGRectGetMaxY(self.actionButton.frame));
                CGRectSetY(self.phoneBackground, self.view.bounds.size.height - kTableBottomSizeForFirst);
                CGFloat newButtonSize = roundf(kMenuButtonTransform * kMenuButtonSize);
                
                self.scheduleButton.center = CGPointMake(kMenuButtonTransformedSideMargin, LOGO_Y + newButtonSize/2);
                self.tasksButton.center = CGPointMake(self.view.center.x, LOGO_Y + newButtonSize/2);
                self.doneButton.center = CGPointMake(self.view.bounds.size.width - kMenuButtonTransformedSideMargin, LOGO_Y + newButtonSize/2);
                self.scheduleButton.transform = self.tasksButton.transform = self.doneButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
            };
            break;
        }
        case FocusOnTheTasksAtHand:{
            block = ^{
                //[self activeCell].helpingImage.alpha = 1;
                self.titleView.alpha = 1;
                self.actionButton.alpha = 1;
                
                
            };
            break;
        }
        case SendThePhoneToTop:{
            block = ^{
                for(WalkthroughCell *cell in self.tableView.visibleCells)
                    if(![cell isEqual:[self activeCell]]) [cell setActivated:NO animated:NO];
                CGRectSetY(self.phoneBackground, CGRectGetMaxY(self.titleView.frame) + LOGO_Y);
                self.tasksButton.backgroundColor = gray(179,1);
                self.doneButton.backgroundColor = tcolor(DoneColor);
                self.actionButton.alpha = 0;
                self.titleView.alpha = 0;
            };
            break;
        }
        case SwipeRightToComplete:{
            block = ^{
                [self activeCell].helpingImage.alpha = 1;
                self.titleView.alpha = 1;
                [[self activeCell] setActivated:YES animated:NO];
                
            };
            break;
        }
        case AnimateUpDonePopup:{
            block = ^{
                self.titleView.alpha = 0;
                [self.backgroundOverlay show:YES];
            };
            break;
        }
        case ScheduleTaskCompleted2:
        case FadeInDonePopupTexts:{
            if(state == ScheduleTaskCompleted2) NSLog(@"got this block");
            block = ^{
                self.backgroundOverlay.popupView.alpha = 1;
            };
            break;
        }
        case PressedContinueFromSchedule:
        case PressedContinueFromCompleted:{
            block = ^{
                self.backgroundOverlay.popupView.alpha = 0;
                [self.backgroundOverlay show:NO];
            };
            break;
        }
        case AnimatedPopupDownFromCompleted:{
            block = ^{
                self.doneButton.backgroundColor = gray(179, 1);
                self.scheduleButton.backgroundColor = tcolor(LaterColor);
            };
            break;
        }
        case SwipeLeftToSchedule:{
            block = ^{
                
                self.titleView.alpha = 1;
                [[self activeCell] setActivated:YES animated:NO];
                [self activeCell].helpingImage.alpha = 1;
                
            };
            break;
        }
        case SwipedToTheLeft:{
            block = ^{
                self.schedulePopupButton.transform = CGAffineTransformIdentity;
                [self.titleView setTitle:@"... Then choose a time" subtitle:@"Pick the ”coffee cup” and the task will come back to you later."];
            };
            break;
        }
        case PressedSchedulePopup:{
            block = ^{
                self.schedulePopupButton.transform = CGAffineTransformMakeScale(kSchedulePopupTransformSize, kSchedulePopupTransformSize);
            };
            break;
        }
        case ScheduleTaskCompleted:{
            block = ^{
                self.titleView.alpha = 0;
                [self.backgroundOverlay show:YES];
            };
            break;
        }
        case ClosedSchedulePopup:{
            block = ^{
                CGRectSetY(self.phoneBackground, self.view.bounds.size.height);
                CGRectSetX(self.scheduleButton, 0 - self.scheduleButton.bounds.size.width);
                CGRectSetX(self.doneButton, self.view.bounds.size.width);
                CGRectSetY(self.tasksButton, 0 - self.tasksButton.frame.size.height);
            };
            break;
        }
        case PushDownGreenBackground:{
            block = ^{
                self.shadowBackground.frame = CGRectMake(0, self.greenBackground.frame.size.height-kShadowBackExtraHeight+kShadowBounce, self.shadowBackground.frame.size.width, kShadowBackExtraHeight);
                
            };
            break;
        }
        case BounceGreenBackground:{
            block = ^{
                CGRectSetY(self.shadowBackground, self.greenBackground.frame.size.height-kShadowBackExtraHeight);
            };
            break;
        }
        case ShowLastTexts:{
            block = ^{
                self.actionButton.alpha = 1;
                self.titleView.alpha = 1;
                self.signatureImage.alpha = 1;
            };
            break;
        }
        default:
            break;
    }
    return block;
}
-(voidBlock)completionBlockForState:(WalkthroughState)state{
    voidBlock block;
    switch (state) {
        case IntroductionPrepare:
        case SendThePhoneToTop:
        case AnimateUpDonePopup:
        case AnimatedPopupDownFromCompleted:
        case PushDownGreenBackground:
        case BounceGreenBackground:
        case ScheduleTaskCompleted:
        {
            block = ^{ 
                [self next];
            };
            break;
        }
        case PressedContinueFromSchedule:
        case PressedContinueFromCompleted:{
            block = ^{
                [self.backgroundOverlay removeFromSuperview];
                self.backgroundOverlay = nil;
                [self next];
            };
            break;
        }
        case PressedSchedulePopup:{
            block = ^{
                [self.schedulePopupButton removeFromSuperview];
                self.schedulePopupButton = nil;
                [self next];
            };
            break;
        }
        case ClosedSchedulePopup:{
            block = ^{
                [self.tasksButton removeFromSuperview];
                self.tasksButton = nil;
                [self.doneButton removeFromSuperview];
                self.doneButton = nil;
                [self.scheduleButton removeFromSuperview];
                self.scheduleButton = nil;
                [self next];
            };
            break;
        }
        default:
            break;
    }
    return block;
}
-(CGFloat)durationForState:(WalkthroughState)state{
    CGFloat duration = kDefTutAnimationTime;
    switch (state) {
        case SwipedToTheLeft:
        case FadeInDonePopupTexts:
        case PressedSchedulePopup:
        case BounceGreenBackground:
        case ScheduleTaskCompleted2:
            duration = 0.18f;
            break;
        default:
            break;
    }
    return duration;
}
-(CGFloat)delayForState:(WalkthroughState)state{
    CGFloat delay = 0.f;
    switch (state) {
        default:
            break;
    }
    return delay;
}
-(void)pressedSchedule:(UIButton*)sender{
    if(self.currentState == SwipedToTheLeft){
        [self next];
    }
    
}
-(void)pressedActionButton:(UIButton*)sender{
    if(self.currentState == Waiting || self.currentState == FocusOnTheTasksAtHand || self.currentState == ShowLastTexts) [self next];
}
-(void)pressedCloseButton:(UIButton*)sender{
    [self.delegate walkthrough:self didFinishSuccesfully:NO];
}
#pragma mark UITableViewDataSource
-(void)tableView:(UITableView *)tableView willDisplayCell:(WalkthroughCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //BOOL activated = (indexPath.row == ACTIVE_ROW) ? YES : NO;
    [cell setActivated:NO animated:NO];
    [cell setTitle:[self.items objectAtIndex:indexPath.row]];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"WalkthroughCell";
    WalkthroughCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[WalkthroughCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.firstColor = [TODOHANDLER colorForCellType:CellTypeDone];
        cell.firstIconName = [TODOHANDLER iconNameForCellType:CellTypeDone];
        cell.thirdColor = [TODOHANDLER colorForCellType:CellTypeSchedule];
        cell.thirdIconName = [TODOHANDLER iconNameForCellType:CellTypeSchedule];
        cell.mode = MCSwipeTableViewCellModeExit;
        cell.activatedDirection = MCSwipeTableViewCellDirectionRight;
        cell.bounceAmplitude = 0;
        cell.delegate = self;
    }
	return cell;
}
-(UIButton*)menuButtonWithImage:(UIImage *)image color:(UIColor*)color{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, kMenuButtonY, kMenuButtonSize, kMenuButtonSize);
    button.layer.cornerRadius = kMenuButtonSize/2;
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateHighlighted];
    [button setBackgroundColor:color];
    button.showsTouchWhenHighlighted = NO;
    return button;
}
#pragma mark ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = W_TIMELINE;
    
    self.swipesLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wt_swipes_logo"]];
    self.swipesLogo.center = CGPointMake(self.view.center.x, self.swipesLogo.center.y+LOGO_Y);
    [self.view addSubview:self.swipesLogo];
    
    self.titleView = [[WalkthroughTitleView alloc] initWithFrame:CGRectMake(0, TITLE_Y, self.view.bounds.size.width, 0)];
    [self.titleView setTitle:@"Welcome to Swipes" subtitle:@"With these 3 menus, you always keep your tasks perfectly organized."];
    
    [self.view addSubview:self.titleView];
    
    self.scheduleButton = [self menuButtonWithImage:[UtilityClass imageWithName:@"schedule-white" scaledToSize:CGSizeMake(25, 25)] color:tcolor(LaterColor)];
    CGRectSetCenterX(self.scheduleButton, kMenuButtonSideMargin);
    [self.view addSubview:self.scheduleButton];
    self.tasksButton = [self menuButtonWithImage:[UtilityClass imageWithName:@"tasks-white" scaledToSize:CGSizeMake(25, 25)] color:tcolor(TasksColor)];
    CGRectSetCenterX(self.tasksButton, self.view.center.x);
    [self.view addSubview:self.tasksButton];
    self.doneButton = [self menuButtonWithImage:[UtilityClass imageWithName:@"done-white" scaledToSize:CGSizeMake(25, 25)] color:tcolor(DoneColor)];
    CGRectSetCenterX(self.doneButton, self.view.bounds.size.width-kMenuButtonSideMargin);
    [self.view addSubview:self.doneButton];
    
    self.menuExplainer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wt_menu_expain"]];
    CGRectSetCenter(self.menuExplainer, self.view.center.x, self.doneButton.center.y + 78);
    [self.view addSubview:self.menuExplainer];
    
    self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.actionButton.frame = CGRectMake((self.view.bounds.size.width-ACTION_BUTTON_WIDTH)/2, self.view.bounds.size.height-ACTION_BUTTON_HEIGHT-30, ACTION_BUTTON_WIDTH, ACTION_BUTTON_HEIGHT);
    self.actionButton.layer.cornerRadius = ACTION_BUTTON_CORNER_RADIUS;
    self.actionButton.layer.borderColor = TEXT_COLOR.CGColor;
    self.actionButton.layer.borderWidth = kActionButtonBorderWidth;
    self.actionButton.titleLabel.font = kActionButtonFont;
    [self.actionButton setTitleColor:TEXT_COLOR forState:UIControlStateNormal];
    [self.actionButton setTitle:@"GET STARTED" forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.actionButton addTarget:self action:@selector(pressedActionButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.actionButton];
    
    self.phoneBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"walkthrough_phone_background"]];
    self.phoneBackground.frame = CGRectSetPos(self.phoneBackground.frame, self.view.center.x-self.phoneBackground.center.x , self.view.bounds.size.height);
    self.phoneBackground.userInteractionEnabled = YES;
    //self.phoneBackground.userInteractionEnabled = YES;
    self.tableView = [[UITableView alloc] initWithFrame:TABLE_FRAME];
    self.tableView.rowHeight = (NSInteger)(CELL_HEIGHT * TABLE_WIDTH);
    self.tableView.layer.masksToBounds = YES;
    self.tableView.userInteractionEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = CLEAR;
    self.tableView.scrollEnabled = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.phoneBackground addSubview:self.tableView];
    [self.view addSubview:self.phoneBackground];
    
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UtilityClass imageNamed:@"cross_button" withColor:gray(128, 1)] forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(self.view.bounds.size.width-kCloseButtonSize, 0, kCloseButtonSize, kCloseButtonSize);
    [closeButton addTarget:self action:@selector(pressedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panning:)];
    [self.view addGestureRecognizer:panRecognizer];
    
}
-(void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode{
    if(state == MCSwipeTableViewCellState1 && self.currentState == SwipeRightToComplete) [self next];
    if(state == MCSwipeTableViewCellState3 && self.currentState == SwipeLeftToSchedule) [self next];
}
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell slidedIntoState:(MCSwipeTableViewCellState)state{
    WalkthroughCell *activeCell = [self activeCell];
    UIColor *color;
    if(state == MCSwipeTableViewCellState1) color = cell.firstColor;
    else if(state == MCSwipeTableViewCellState3) color = cell.thirdColor;
    else if(state == MCSwipeTableViewCellStateNone) color = tcolor(TasksColor);
    if(color) [activeCell setDotColor:color];
}
-(void)panning:(UIPanGestureRecognizer*)recognizer{
    if(!(self.currentState == SwipeRightToComplete || self.currentState == SwipeLeftToSchedule)) return;
    WalkthroughCell *activeCell = [self activeCell];
    CGPoint translation = [recognizer translationInView:self.view];
    [activeCell publicHandlePanGestureRecognizer:recognizer withTranslation:translation];
    CGFloat percOfHelping = fabsf(activeCell.readPercentage)/kHelparrowPercentage;
    if(percOfHelping > 1.0f) percOfHelping = 1.0f;
    CGFloat newOpacity = 1.0f - percOfHelping;
    activeCell.helpingImage.alpha = newOpacity;
}
-(void)viewDidUnload{
    [super viewDidUnload];
    self.scrollView = nil;
    self.phoneBackground = nil;
    self.tableView = nil;
    self.titleView = nil;
    self.swipesLogo = nil;
    self.actionButton = nil;
    self.greenBackground = nil;
    self.shadowBackground = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
