//
//  TodayViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define TABLEVIEW_TAG 501
#define kShareButtonSize 40
#define kBottomMargin 80
#define kButtonSpacing 14

#import "TodayListViewController.h"
#import "KPReorderTableView.h"
#import "FacebookCommunicator.h"
#import "YoureAllDoneView.h"
#import <Social/Social.h>
#import "UIView+Utilities.h"
#import "AnalyticsHandler.h"
#import "SlowHighlightIcon.h"
#import "RootViewController.h"
#import "StyleHandler.h"
#import "SectionHeaderView.h"
#import "CoreSyncHandler.h"
#import "UtilityClass.h"
@interface TodayListViewController ()<ATSDragToReorderTableViewControllerDelegate,ATSDragToReorderTableViewControllerDraggableIndicators>
@property (nonatomic, strong) IBOutlet KPReorderTableView *tableView;
@property (nonatomic) YoureAllDoneView *youreAllDoneView;
@property (nonatomic, strong) NSIndexPath *dragRow;
@property (nonatomic) BOOL emptyBack;

@property (nonatomic) NSString *sharingService;
@property (nonatomic) UIButton *facebookButton;
@property (nonatomic) UIButton *twitterButton;
@property (nonatomic) NSString *shareText;
@property (nonatomic) SectionHeaderView *sectionHeader;
@property BOOL allDoneForToday;

@end
@implementation TodayListViewController
#pragma mark - Dragable delegate

-(void)setEmptyBack:(BOOL)emptyBack{
    [self setEmptyBack:emptyBack animated:NO];
}
-(void)setEmptyBack:(BOOL)emptyBack animated:(BOOL)animated{
    if(emptyBack != self.emptyBack){
        BOOL isFacebookAvailable = ([[UIDevice currentDevice].systemVersion floatValue] >= 6 && [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]);
        BOOL isTwitterAvailable = [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
        if(!isTwitterAvailable) self.twitterButton.hidden = YES;
        if(!isFacebookAvailable) self.facebookButton.hidden = YES;
        _emptyBack = emptyBack;
        CGFloat alpha = emptyBack ? 1 : 0;
        if(!animated){
            self.youreAllDoneView.alpha = alpha;
            self.facebookButton.hidden = self.twitterButton.hidden = !emptyBack;
        }
        else{
            if(emptyBack){
                if(isFacebookAvailable) self.facebookButton.hidden = NO;
                if(isTwitterAvailable) self.twitterButton.hidden = NO;
                self.facebookButton.alpha = self.twitterButton.alpha = 0;
            }
            CGFloat animationTime = emptyBack ? 1.5f : 0.5f;
            [UIView animateWithDuration:animationTime animations:^{
                self.facebookButton.alpha = self.twitterButton.alpha = alpha;
                self.youreAllDoneView.alpha = alpha;
            } completion:^(BOOL finished) {
                if(!emptyBack){
                    if(isFacebookAvailable) self.facebookButton.hidden = YES;
                    if(isTwitterAvailable) self.twitterButton.hidden = YES;
                }
            }];
        }
    }
}
-(void)itemHandler:(ItemHandler *)handler changedItemNumber:(NSInteger)itemNumber oldNumber:(NSInteger)oldNumber{
    [super itemHandler:handler changedItemNumber:itemNumber oldNumber:oldNumber];
    [self.tableView setReorderingEnabled:(itemNumber > 1)];
    [self updateSectionHeader];
    if(itemNumber == 0 && oldNumber != 0)
        self.shareText = [self randomTextAllDoneForToday:self.allDoneForToday];
    [self updateBackground];
    
    self.parent.backgroundMode = (itemNumber == 0);
    [self setEmptyBack:(itemNumber == 0) animated:YES];
    self.sectionHeader.fillColor = (itemNumber == 0) ? CLEAR : tcolor(BackgroundColor);
    if(itemNumber == 0 && oldNumber > 0){
        NSInteger servicesAvailable = 0;
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) servicesAvailable++;
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) servicesAvailable++;
        NSInteger streak = [USER_DEFAULTS integerForKey:@"numberOfDaysOnStreak"];
        NSDictionary *dict = @{@"Sharing Services Available":[NSNumber numberWithInteger:servicesAvailable],@"All done for today":@(self.allDoneForToday),@"Streak":@(streak)};
        [ANALYTICS tagEvent:@"Cleared Tasks" options:dict];
    }
    
}
-(NSArray *)itemsForItemHandler:(ItemHandler *)handler{
    
    NSDate *endDate = [NSDate date];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(schedule < %@ AND completionDate = nil AND parent = nil)",endDate];
    NSArray *results = [KPToDo MR_findAllSortedBy:@"order" ascending:NO withPredicate:predicate];
    return [KPToDo sortOrderForItems:results newItemsOnTop:YES save:YES context:nil];
}
- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(KPReorderTableView *)dragTableViewController {
    ToDoCell *cell = [[ToDoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [UIView animateWithDuration:0.3 animations:^{
        cell.dotView.alpha = 0;
        cell.actionStepsButton.alpha = 0;

    }];
    [self readyCell:cell];
    [self tableView:self.tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    KPToDo *model = [self.itemHandler itemForIndexPath:indexPath];
    CGRectSetHeight(cell, [ToDoCell heightWithText:model.title hasSubtask:([model getSubtasks].count > 0)]*2);
	return cell;
}

- (void)dragTableViewController:(KPReorderTableView *)dragTableViewController didBeginDraggingAtRow:(NSIndexPath *)dragRow{
    [self parent].lock = YES;
    self.dragRow = dragRow;
    [self.itemHandler setDraggingIndexPath:dragRow];
    [self deselectAllRows:self];
}
-(void)dragTableViewController:(KPReorderTableView *)dragTableViewController didEndDraggingToRow:(NSIndexPath *)destinationIndexPath{
    
    [self.itemHandler moveItem:self.dragRow toIndexPath:destinationIndexPath];
    self.tableView.allowsMultipleSelection = YES;
    [self parent].lock = NO;
    [[self parent] setCurrentState:KPControlCurrentStateAdd];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIFont *font = SECTION_HEADER_FONT;
    self.sectionHeader = [[SectionHeaderView alloc] initWithColor:[StyleHandler colorForCellType:CellTypeToday]
                                                             font:font title:@"" width:tableView.frame.size.width];
    self.sectionHeader.fillColor = (self.itemHandler.itemCounterWithFilter == 0) ? CLEAR : tcolor(BackgroundColor);
    self.sectionHeader.progress = YES;
    
    [self updateSectionHeader];
    return self.sectionHeader;
}
-(void)updateSectionHeader{
    NSDate *endOfToday = [[NSDate dateTomorrow] dateAtStartOfDay];
    NSDate *startOfToday = [[NSDate date] dateAtStartOfDay];
    NSPredicate *inprogressPredicate = [NSPredicate predicateWithFormat:@"(schedule < %@ AND completionDate = nil AND parent = nil)",endOfToday];
    NSPredicate *completedPredicate = [NSPredicate predicateWithFormat:@"(completionDate > %@ AND parent = nil)",startOfToday];
    NSInteger numberInProgress = [KPToDo MR_countOfEntitiesWithPredicate:inprogressPredicate inContext:[KPCORE context]];
    NSInteger numberOfDone = [KPToDo MR_countOfEntitiesWithPredicate:completedPredicate inContext:[KPCORE context]];
    NSInteger total = numberInProgress+numberOfDone;
    //NSInteger percentage = ceilf((CGFloat)numberOfDone/total*100);
    
    self.allDoneForToday = (numberInProgress == 0);
    
    self.sectionHeader.title = [NSString stringWithFormat:LOCALIZE_STRING(@"%li / %li Today"), (long)numberOfDone,(long)total];
    //[NSString stringWithFormat:@"%i%%",percentage];//
    
    if(total > 0)
        self.sectionHeader.progressPercentage = (CGFloat)numberOfDone/total;
    else
        self.sectionHeader.progressPercentage = 0;
    
    if(self.itemHandler.itemCounter <= 0){
        
        if(self.allDoneForToday){
            self.youreAllDoneView.stampView.allDoneLabel.text = @"ALL DONE FOR TODAY";
            NSInteger currentNumber = [USER_DEFAULTS integerForKey:@"numberOfDaysOnStreak"];
            
            if(!currentNumber)
                currentNumber = 1;
            
            NSDate *lastStreak = (NSDate*)[USER_DEFAULTS objectForKey:@"lastStreakDate"];
            
            if(lastStreak){
                
                if([lastStreak isYesterday])
                    currentNumber++;
                else if(![lastStreak isToday])
                    currentNumber = 0;
                [USER_DEFAULTS setInteger:currentNumber forKey:@"numberOfDaysOnStreak"];
            }
            [USER_DEFAULTS setObject:[NSDate date] forKey:@"lastStreakDate"];
            
            NSString *startString = (currentNumber <= 1) ? @"First day" : [NSString stringWithFormat:@"%li days",(long)currentNumber];
            self.youreAllDoneView.stampView.monthLabel.text = [NSString stringWithFormat:@"%@ on a streak!",startString];
        }
        else{
            NSPredicate *nextScheduleTaskPredicate = [NSPredicate predicateWithFormat:@"(schedule > %@ AND completionDate = nil)",[NSDate date]];
            KPToDo *nextItem = [KPToDo MR_findFirstWithPredicate:nextScheduleTaskPredicate sortedBy:@"schedule" ascending:YES inContext:[KPCORE context]];
            self.youreAllDoneView.stampView.allDoneLabel.text = @"ALL DONE FOR NOW";
            self.youreAllDoneView.stampView.monthLabel.text = [NSString stringWithFormat:@"Next task  @  %@",[UtilityClass timeStringForDate:nextItem.schedule]];
        }
    }
    
}


#pragma mark - UIViewControllerClasses
-(void)updateBackground{
    BOOL isFacebookAvailable = ([[UIDevice currentDevice].systemVersion floatValue] >= 6 && [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]);
    BOOL isTwitterAvailable = [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
    if(!self.shareText) self.shareText = [self randomTextAllDoneForToday:self.allDoneForToday];
    
    [self.youreAllDoneView setText:self.shareText];
    CGFloat buttonsCenterY = CGRectGetMaxY(self.youreAllDoneView.shareItLabel.frame) + kButtonSpacing+ kShareButtonSize/2;
    CGRectSetCenter(self.facebookButton, self.view.frame.size.width/2-kButtonSpacing/2-kShareButtonSize/2, buttonsCenterY);
    CGRectSetCenter(self.twitterButton, self.view.frame.size.width/2+kButtonSpacing/2+kShareButtonSize/2, buttonsCenterY);
    if(!(isTwitterAvailable && isFacebookAvailable)) self.facebookButton.center = self.twitterButton.center = CGPointMake(self.view.frame.size.width/2, buttonsCenterY);
    //self.youreAllDoneView.shareItLabel.hidden = (!isTwitterAvailable && !isFacebookAvailable);
    [self.youreAllDoneView.stampView setDate:[NSDate date]];
}


-(NSString*)randomTextAllDoneForToday:(BOOL)doneForToday{
    NSArray *doneForTodays = @[@"Nothing beats going to bed with a complete to-do list! #ProductiveDay",
                           @"To-do list complete, gonna sleep well tonight! #ProductiveDay",
                           @"Bed just feels better after a #ProductiveDay",
                           @"To-do list complete - take that procrastination! #ProductiveDay",
                           @"To-do list: complete. Procrastination: owned. #ProductiveDay",
                           @"My phone just told me my tasks are done for the day! #ProductiveDay",
                           @"Today’s to-do list is complete, time to relax #ProductiveDay",
                           @"Hooray! All tasks swiped away, time to relax #ProductiveDay",
                           @"Beer just tastes better after a #ProductiveDay",
                           @"To-do list complete. Boom, done. #ProductiveDay",
                           @"To-do list: complete. Couch time: earned. #ProductiveDay",
                           @"To-do list complete. Feeling like a boss. #ProductiveDay",
                           @"Procrastination can’t touch me. To-do list, done. #ProductiveDay",
                           @"Finish to-do list: check. Night out: in progress. #ProductiveDay",
                           @"Finish to-do list: check. Needed couch time: in progress. #ProductiveDay",
                           @"Kickin’ my shoes off because today’s to-do list is complete! #ProductiveDay",
                           @"Procrastination? What’s that? #ProductiveDay",
                           @"Complete to-do list? Nailed it. #ProductiveDay",
                           @"Don’t hate me ‘cause you ain’t me. To-do list: owned. #ProductiveDay",
                           @"Long to-do list: stressful. Complete to-do list: priceless. #ProductiveDay"];
    
    NSArray *doneForNows = @[
        @"Awesome! I’m ahead of schedule #ProductiveDay",
        @"Time for a break! I’ve been swiping tasks like a boss. #ProductiveDay",
        @"Let’s grab a coffee! It’s already been a #ProductiveDay"
    ];
    NSArray *actualArray = doneForToday ? doneForTodays : doneForNows;
    NSUInteger randomIndex = arc4random() % [actualArray count];
    NSString *string = [actualArray objectAtIndex:randomIndex];
    return string;
}
- (void)viewDidLoad
{
    self.state = @"today";
    [super viewDidLoad];
    self.youreAllDoneView = [[YoureAllDoneView alloc] initWithFrame:self.view.bounds];
    self.youreAllDoneView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.youreAllDoneView];
    
    [self.tableView removeFromSuperview];
    KPReorderTableView *tableView = [[KPReorderTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self prepareTableView:tableView];
    tableView.tag = TABLEVIEW_TAG;
    [self.view addSubview:tableView];
    self.tableView = (KPReorderTableView*)[self.view viewWithTag:TABLEVIEW_TAG];
    self.tableView.dragDelegate = self;
    self.tableView.indicatorDelegate = self;
	// Do any additional setup after loading the view.
    
    self.facebookButton = [[SlowHighlightIcon alloc] initWithFrame:CGRectMake(0, 0, kShareButtonSize, kShareButtonSize)];
    self.facebookButton.titleLabel.font = iconFont(36);
    [self.facebookButton setTitle:@"facebook" forState:UIControlStateNormal];
    [self.facebookButton setTitle:@"facebookFull" forState:UIControlStateHighlighted];
    [self.facebookButton setTitleColor:tcolorF(TextColor,ThemeDark) forState:UIControlStateNormal];
    [self.facebookButton addTarget:self action:@selector(pressedFacebook) forControlEvents:UIControlEventTouchUpInside];
    self.facebookButton.hidden = YES;
    [self.view addSubview:self.facebookButton];
    
    
    self.twitterButton = [[SlowHighlightIcon alloc] initWithFrame:CGRectMake(0, 0, kShareButtonSize, kShareButtonSize)];
    self.twitterButton.titleLabel.font = iconFont(36);
    [self.twitterButton setTitle:@"twitter" forState:UIControlStateNormal];
    [self.twitterButton setTitle:@"twitterFull" forState:UIControlStateHighlighted];
    [self.twitterButton setTitleColor:tcolorF(TextColor,ThemeDark) forState:UIControlStateNormal];
    [self.twitterButton addTarget:self action:@selector(pressedTwitter) forControlEvents:UIControlEventTouchUpInside];
    self.twitterButton.hidden = YES;
    [self.view addSubview:self.twitterButton];
    self.twitterButton.autoresizingMask = self.facebookButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
}


-(UIImage*)screenshotForSharingService:(NSString*)sharingService{
    BOOL oldFaceHidden = self.facebookButton.hidden;
    BOOL oldTwitterHidden = self.twitterButton.hidden;
    CGPoint oldOffset = self.tableView.contentOffset;
    
    self.facebookButton.hidden = YES;
    self.twitterButton.hidden = YES;
    if([sharingService isEqualToString:SLServiceTypeTwitter]){ self.youreAllDoneView.signatureView.hidden = NO;
    }
    if([sharingService isEqualToString:SLServiceTypeFacebook]) self.youreAllDoneView.swipesReferLabel.hidden = NO;
    self.tableView.contentOffset = CGPointMake(0, self.tableView.tableHeaderView.frame.size.height);
    
    UIImage *returnImage = [[self parent].view screenshot];
    
    self.tableView.contentOffset = oldOffset;
    self.youreAllDoneView.signatureView.hidden = YES;
    self.youreAllDoneView.swipesReferLabel.hidden = YES;
    self.facebookButton.hidden = oldFaceHidden;
    self.twitterButton.hidden = oldTwitterHidden;
    //self.youreAllDoneView.shareItLabel.hidden = oldShareHidden;
    
    return returnImage;
}
-(void)shareForServiceType:(NSString*)serviceType{
    self.sharingService = serviceType;
    SLComposeViewController *shareVC = [SLComposeViewController composeViewControllerForServiceType:serviceType];
    shareVC.completionHandler = ^(SLComposeViewControllerResult result) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        switch(result) {
            case SLComposeViewControllerResultCancelled:
                break;
            case SLComposeViewControllerResultDone:{
                NSString *realServiceType;
                [dict setObject:self.shareText forKey:@"Share string"];
                [dict setObject:@(self.allDoneForToday) forKey:@"All done for today"];
                if ([self.sharingService isEqualToString:SLServiceTypeFacebook])
                    realServiceType = @"Facebook";
                else if([self.sharingService isEqualToString:SLServiceTypeTwitter])
                    realServiceType = @"Twitter";
                if (realServiceType)
                    [dict setObject:realServiceType forKey:@"Service"];
                [ANALYTICS tagEvent:@"Sharing Successful" options:dict];
                break;
            }
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    [shareVC addImage:[self screenshotForSharingService:serviceType]];
    if (!self.shareText) {
        self.shareText = [self randomTextAllDoneForToday:self.allDoneForToday];
    }
    NSString *string = self.shareText;
    
    if([serviceType isEqualToString:SLServiceTypeTwitter])
        string = [string stringByAppendingString:@" http://swipesapp.com/download"];
    else
        [shareVC addURL:[NSURL URLWithString:@"http://swipesapp.com/download"]];
    
    [shareVC setInitialText:string];
    [[self parent] presentViewController:shareVC animated:YES completion:nil];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *realServiceType;
    
    [dict setObject:self.shareText forKey:@"Share string"];
    [dict setObject:@(self.allDoneForToday) forKey:@"All done for today"];
    if ([serviceType isEqualToString:SLServiceTypeFacebook])
        realServiceType = @"Facebook";
    else if([serviceType isEqualToString:SLServiceTypeTwitter])
        realServiceType = @"Twitter";
    if (realServiceType)
        [dict setObject:realServiceType forKey:@"Service"];
    [ANALYTICS tagEvent:@"Sharing Opened" options:dict];
}
-(void)pressedFacebook{
    [self shareForServiceType:SLServiceTypeFacebook];
}
-(void)pressedTwitter{
    [self shareForServiceType:SLServiceTypeTwitter];
}
-(void)dealloc{
    self.youreAllDoneView = nil;
    self.twitterButton = nil;
    self.facebookButton = nil;
    clearNotify();
}

-(void)triggerEvernote{
    [ROOT_CONTROLLER triggerEvernoteEvent];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateSectionHeader];
    [self updateBackground];
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(triggerEvernote) userInfo:nil repeats:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
