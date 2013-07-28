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
#define TABLE_Y 200
#define kPhoneTopToStartOfCells 116
#define TABLE_FRAME CGRectMake(13,kPhoneTopToStartOfCells,TABLE_WIDTH,375)

#define TEXT_COLOR  gray(128,1)

#define LOGO_Y 30
#define TITLE_Y 140
#define ACTION_BUTTON_WIDTH 190
#define ACTION_BUTTON_HEIGHT 58

#define ACTIVE_ROW 2

#define ACTION_BUTTON_CORNER_RADIUS 3
#define kActionButtonBorderWidth 2
#define kActionButtonFont KP_BOLD(23)

#define kMenuButtonY 260
#define kMenuButtonSize 60
#define kMenuButtonTransform 0.8
#define kMenuButtonSideMargin 70
#define kMenuButtonTransformedSideMargin 90
#define kHelparrowPercentage 0.4
#define kCloseButtonSize 44
#define kDefTutAnimationTime 0.5f



typedef enum {
    Waiting = 0,
    IntroductionPrepare,
    SwipeRightToComplete,
    SwipedToTheRight,
    Complete,
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

@end

@implementation WalkthroughViewController
-(void)next{
    self.currentState++;
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
        case SwipeRightToComplete:{ block = ^{
            [self.titleView setTitle:@"Swipe right to complete" subtitle:@"There is no voodoo magic, it's all gestures"];
            CGRectSetY(self.titleView, TITLE_Y-40); }; }
            break;
        case SwipedToTheRight:{
            block = ^{
                WalkthroughOverlayBackground *background = [[WalkthroughOverlayBackground alloc] initWithFrame:CGRectMake(0, 0, TABLE_WIDTH + 2*kBottomExtraSide, 300)];
                CGRectSetCenterX(background, self.phoneBackground.frame.size.width/2);
                CGRectSetY(background, (kPhoneTopToStartOfCells + (ACTIVE_ROW * roundf(TABLE_WIDTH * CELL_HEIGHT))) - background.frame.size.height);
                background.circleBottomLength = kCircleBottomOfBarToCenter + (ACTIVE_ROW * roundf(TABLE_WIDTH * CELL_HEIGHT));
                [background setLeft:NO];
                background.bottomColor = tcolor(StrongDoneColor);
                background.topColor = tcolor(DoneColor);
                self.backgroundOverlay = background;
                [self.phoneBackground addSubview:self.backgroundOverlay];
                [self.backgroundOverlay show:NO];
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
                self.tasksButton.backgroundColor = gray(179,1);
                self.scheduleButton.backgroundColor = gray(179,1);
                CGRectSetY(self.phoneBackground, TABLE_Y);
                CGFloat newButtonSize = roundf(kMenuButtonTransform * kMenuButtonSize);
                
                self.scheduleButton.center = CGPointMake(kMenuButtonTransformedSideMargin, LOGO_Y + newButtonSize/2);
                self.tasksButton.center = CGPointMake(self.view.center.x, LOGO_Y + newButtonSize/2);
                self.doneButton.center = CGPointMake(self.view.bounds.size.width - kMenuButtonTransformedSideMargin, LOGO_Y + newButtonSize/2);
                self.scheduleButton.transform = self.tasksButton.transform = self.doneButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
            };
            break;
        }
        case SwipeRightToComplete:{
            block = ^{
                [self activeCell].helpingImage.alpha = 1;
                self.titleView.alpha = 1;
            };
            break;
        }
        case SwipedToTheRight:{
            block = ^{
                [self.backgroundOverlay show:YES];
            };
        }
        
        default:
            break;
    }
    return block;
}
-(voidBlock)completionBlockForState:(WalkthroughState)state{
    voidBlock block;
    switch (state) {
        case IntroductionPrepare:{
            block = ^{
                [self next];
            };
        }
        default:
            break;
    }
    return block;
}
-(CGFloat)durationForState:(WalkthroughState)state{
    CGFloat duration = kDefTutAnimationTime;
    switch (state) {
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

-(void)pressedActionButton:(UIButton*)sender{
    if(self.currentState == Waiting) [self next];
}
-(void)pressedCloseButton:(UIButton*)sender{
    [self.delegate walkthrough:self didFinishSuccesfully:NO];
}
#pragma mark UITableViewDataSource
-(void)tableView:(UITableView *)tableView willDisplayCell:(WalkthroughCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    BOOL activated = (indexPath.row == ACTIVE_ROW) ? YES : NO;
    [cell setActivated:activated animated:NO];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"del");
    return 10;
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
    [self.titleView setTitle:@"Welcome to Swipes" subtitle:@"This is your menu bar. Here everything has its place."];
    
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
    self.actionButton.frame = CGRectMake((self.view.bounds.size.width-ACTION_BUTTON_WIDTH)/2, self.view.bounds.size.height-ACTION_BUTTON_HEIGHT-30, 190, 58);
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
    //self.phoneBackground.userInteractionEnabled = YES;
    self.tableView = [[UITableView alloc] initWithFrame:TABLE_FRAME];
    self.tableView.rowHeight = (NSInteger)(CELL_HEIGHT * TABLE_WIDTH);
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
    if(self.currentState != SwipeRightToComplete) return;
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
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
