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

#import "TodayViewController.h"
#import "KPReorderTableView.h"
#import "FacebookCommunicator.h"
#import "YoureAllDoneView.h"
#import <Social/Social.h>
#import "UIView+Utilities.h"
#import "AnalyticsHandler.h"
@interface TodayViewController ()<ATSDragToReorderTableViewControllerDelegate,ATSDragToReorderTableViewControllerDraggableIndicators>
@property (nonatomic,weak) IBOutlet KPReorderTableView *tableView;
@property (nonatomic) YoureAllDoneView *youreAllDoneView;
@property (nonatomic,strong) NSIndexPath *dragRow;
@property (nonatomic) BOOL emptyBack;

@property (nonatomic) NSString *sharingService;
@property (nonatomic) UIButton *facebookButton;
@property (nonatomic) UIButton *twitterButton;
@property (nonatomic) NSString *shareText;
@end
@implementation TodayViewController
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
            [UIView animateWithDuration:1.5 animations:^{
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
    [self updateBackground];
    [self setEmptyBack:(itemNumber == 0) animated:YES];
    NSLog(@"updating number for today: %i from: %i",itemNumber,oldNumber);
    if(itemNumber == 0 && oldNumber > 0){
        NSInteger servicesAvailable = 0;
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) servicesAvailable++;
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) servicesAvailable++;
        NSDictionary *dict = @{@"Sharing Services Available":[NSNumber numberWithInteger:servicesAvailable]};
        [ANALYTICS tagEvent:@"Cleared Tasks" options:dict];
    }
}
-(NSArray *)itemsForItemHandler:(ItemHandler *)handler{
    NSDate *endDate = [NSDate date];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(state == %@ AND schedule < %@)",@"scheduled", endDate];
    NSArray *results = [KPToDo MR_findAllSortedBy:@"order" ascending:NO withPredicate:predicate];
    return results;
}
- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(KPReorderTableView *)dragTableViewController {
    ToDoCell *cell = [[ToDoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [self readyCell:cell];
    [self tableView:self.tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    [cell showTimeline:NO];
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
-(void)setIsShowingItem:(BOOL)isShowingItem{
    [super setIsShowingItem:isShowingItem];
    [self.tableView setReorderingEnabled:!isShowingItem];
}
#pragma mark - UIViewControllerClasses
-(void)updateBackground{
    BOOL isFacebookAvailable = ([[UIDevice currentDevice].systemVersion floatValue] >= 6 && [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]);
    BOOL isTwitterAvailable = [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
    CGFloat buttonsCenterY = self.view.frame.size.height - kBottomMargin - kShareButtonSize/2;
    CGRectSetCenter(self.facebookButton, self.view.frame.size.width/2-kButtonSpacing/2-kShareButtonSize/2, buttonsCenterY);
    CGRectSetCenter(self.twitterButton, self.view.frame.size.width/2+kButtonSpacing/2+kShareButtonSize/2, buttonsCenterY);
    if(!(isTwitterAvailable && isFacebookAvailable)) self.facebookButton.center = self.twitterButton.center = CGPointMake(self.view.frame.size.width/2, buttonsCenterY);
    self.youreAllDoneView.shareItLabel.hidden = (!isTwitterAvailable && !isFacebookAvailable);
    [self.youreAllDoneView.stampView setDate:[NSDate date]];
}
- (void)viewDidLoad
{
    self.state = @"today";
    [super viewDidLoad];
    
    self.youreAllDoneView = [[YoureAllDoneView alloc] initWithFrame:self.view.bounds];
    self.youreAllDoneView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
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
    
    self.facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kShareButtonSize, kShareButtonSize)];
    [self.facebookButton setImage:[UIImage imageNamed:@"share_facebook_button"] forState:UIControlStateNormal];
    [self.facebookButton addTarget:self action:@selector(pressedFacebook) forControlEvents:UIControlEventTouchUpInside];
    self.facebookButton.hidden = YES;
    [self.view addSubview:self.facebookButton];
    
    
    self.twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kShareButtonSize, kShareButtonSize)];
    [self.twitterButton setImage:[UIImage imageNamed:@"share_twitter_button"] forState:UIControlStateNormal];
    [self.twitterButton addTarget:self action:@selector(pressedTwitter) forControlEvents:UIControlEventTouchUpInside];
    self.twitterButton.hidden = YES;
    [self.view addSubview:self.twitterButton];
    self.twitterButton.autoresizingMask = self.facebookButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
}

-(UIImage*)screenshotForSharingService:(NSString*)sharingService{
    BOOL oldFaceHidden = self.facebookButton.hidden;
    BOOL oldTwitterHidden = self.twitterButton.hidden;
    BOOL oldShareHidden = self.youreAllDoneView.shareItLabel.hidden;
    CGPoint oldOffset = self.tableView.contentOffset;
    
    self.facebookButton.hidden = YES;
    self.twitterButton.hidden = YES;
    self.youreAllDoneView.shareItLabel.hidden = YES;
    if([sharingService isEqualToString:SLServiceTypeTwitter]) self.youreAllDoneView.signatureView.hidden = NO;
    if([sharingService isEqualToString:SLServiceTypeFacebook]) self.youreAllDoneView.swipesReferLabel.hidden = NO;
    self.tableView.contentOffset = CGPointMake(0, self.tableView.tableHeaderView.frame.size.height);
    
    UIImage *returnImage = [[self parent].view screenshot];
    
    self.tableView.contentOffset = oldOffset;
    self.youreAllDoneView.signatureView.hidden = YES;
    self.youreAllDoneView.swipesReferLabel.hidden = YES;
    self.facebookButton.hidden = oldFaceHidden;
    self.twitterButton.hidden = oldTwitterHidden;
    self.youreAllDoneView.shareItLabel.hidden = oldShareHidden;
    
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
                if([self.sharingService isEqualToString:SLServiceTypeFacebook]) realServiceType = @"Facebook";
                else if([self.sharingService isEqualToString:SLServiceTypeTwitter]) realServiceType = @"Twitter";
                if(realServiceType) [dict setObject:realServiceType forKey:@"Service"];
                [ANALYTICS tagEvent:@"Sharing Successful" options:dict];
                break;
            }
        }
        [self dismissModalViewControllerAnimated:YES];
    };
    [shareVC addImage:[self screenshotForSharingService:serviceType]];
    NSArray *tweets = @[@"All tasks done for Today #productiveday @swipesapp",
                        @"Having a great and #productiveday @swipesapp",
                        @"Today’s tasks are done. Feeling great! #productiveday @swipesapp",
                        @"Ha! All done for today #productiveday @swipesapp",
                        @"Hurrah! Tasks completed, time for relax! #productiveday @swipesapp",
                        @"Whee! No more things to do for now. #productiveday @swipesapp",
                        @"Ihu! I’m totally on top of things #productiveday @swipesapp",
                        @"The happy moment of getting-things-done #productiveday @swipesapp",
                        @"\"Well done for today\" said my boss ;) #productiveday @swipesapp",
                        @"Ta-dah! Success for today! #productiveday @swipesapp"];
    
    NSArray *facebooks = @[@"All tasks done for Today #productiveday",
                           @"Having a great and #productiveday",
                           @"Today’s tasks are done. Feeling great! #productiveday",
                           @"Ha! All done for today #productiveday",
                           @"Hurrah! Tasks completed, time for relax! #productiveday",
                           @"Whee! No more things to do for now. #productiveday",
                           @"Ihu! I’m totally on top of things #productiveday",
                           @"The happy moment of getting-things-done #productiveday",
                           @"\"Well done for today\" said my boss ;) #productiveday",
                           @"Ta-dah! Success for today! #productiveday"];
    
    NSArray *targetArray = [serviceType isEqualToString:SLServiceTypeFacebook] ? facebooks : tweets;
    NSUInteger randomIndex = arc4random() % [targetArray count];
    NSString *string = [targetArray objectAtIndex:randomIndex];
    self.shareText = string;
    [shareVC setInitialText:@"\"Well done for today\" said my boss ;) #productiveday"];
    [[self parent] presentModalViewController:shareVC animated:YES];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *realServiceType;
    
    [dict setObject:string forKey:@"Share string"];
    if([serviceType isEqualToString:SLServiceTypeFacebook]) realServiceType = @"Facebook";
    else if([serviceType isEqualToString:SLServiceTypeTwitter]) realServiceType = @"Twitter";
    if(realServiceType) [dict setObject:realServiceType forKey:@"Service"];
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
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
