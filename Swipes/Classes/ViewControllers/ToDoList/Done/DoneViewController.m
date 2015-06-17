//
//  DoneViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "DoneViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Utilities.h"
#import "UtilityClass.h"
#import "SlowHighlightIcon.h"
@interface DoneViewController ()
@property (nonatomic) BOOL hasAskedForMore;
@property (nonatomic) NSInteger remainingTasks;
@end

@implementation DoneViewController
-(NSArray *)itemsForItemHandler:(ItemHandler *)handler{
    NSPredicate *predicate;
    
    NSDate *startDate = [[NSDate date] dateAtStartOfDay];
    if(!self.hasAskedForMore && !kFilter.isActive){
        predicate = [NSPredicate predicateWithFormat:@"(completionDate != nil && completionDate >= %@ && parent = nil && isLocallyDeleted <> YES)",startDate];
        NSPredicate *remainingPred = [NSPredicate predicateWithFormat:@"(completionDate != nil && completionDate < %@ && parent = nil && isLocallyDeleted <> YES)",startDate];
        self.remainingTasks = [KPToDo MR_countOfEntitiesWithPredicate:remainingPred];
    }
    else{
        self.remainingTasks = 0;
        predicate = [NSPredicate predicateWithFormat:@"(completionDate != nil && parent = nil && isLocallyDeleted <> YES)"];
    }
    return [KPToDo MR_findAllSortedBy:@"completionDate" ascending:NO withPredicate:predicate];
}
-(NSString *)itemHandler:(ItemHandler *)handler titleForItem:(KPToDo *)item{
    return [item readableTitleForStatus];
}

-(void)didPressLoadMore:(id)sender{
    self.hasAskedForMore = YES;
    [self update];
}
-(void)didPressDeleteAll:(id)sender{
    [UTILITY confirmBoxWithTitle:NSLocalizedString(@"Are you sure?", nil) andMessage:NSLocalizedString(@"Deleting old completed tasks can't be undone", nil) cancel:[NSLocalizedString(@"cancel", nil) capitalizedString] confirm:NSLocalizedString(@"Delete them", nil) block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            NSDate *startDate = [[NSDate date] dateAtStartOfDay];
            NSPredicate *remainingPred = [NSPredicate predicateWithFormat:@"(completionDate != nil && completionDate < %@ && parent = nil && isLocallyDeleted <> YES)",startDate];
            NSArray *oldCompletedTasks = [KPToDo MR_findAllWithPredicate:remainingPred];
            [KPToDo deleteToDos:oldCompletedTasks save:YES force:NO];
            [self update];
        }
    }];
}
-(void)updateTableFooter{
    [super updateTableFooter];
    if(kFilter.isActive){
        if(self.remainingTasks != 0)
            [self update];
        return;
    }
    if(self.hasAskedForMore || self.remainingTasks == 0){
        [self.tableView setTableFooterView:nil];
    }
    else{
        CGFloat footerHeight = 60;
        CGFloat buttonY = 10;
        CGFloat buttonPaddingFromMiddle = 10;
        
        CGFloat buttonWidth = 130;
        CGFloat buttonHeight = 38;
        
        UIView *tableFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, footerHeight)];
        tableFooter.backgroundColor = CLEAR;
        
        
        UIButton *loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        loadMoreButton.frame = CGRectMake(tableFooter.frame.size.width/2-buttonPaddingFromMiddle-buttonWidth, buttonY, buttonWidth, buttonHeight);
        loadMoreButton.titleLabel.font = KP_REGULAR(12);
        loadMoreButton.layer.cornerRadius = 3;
        loadMoreButton.layer.borderWidth = 1;
        loadMoreButton.layer.masksToBounds = YES;
        loadMoreButton.layer.borderColor = tcolor(TextColor).CGColor;
        
        [loadMoreButton setTitle:NSLocalizedString(@"Show old tasks", nil) forState:UIControlStateNormal];
        [loadMoreButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [loadMoreButton setTitleColor:tcolor(BackgroundColor) forState:UIControlStateHighlighted];
        [loadMoreButton setBackgroundImage:[tcolor(TextColor) image] forState:UIControlStateHighlighted];
        [loadMoreButton addTarget:self action:@selector(didPressLoadMore:) forControlEvents:UIControlEventTouchUpInside];
        [tableFooter addSubview:loadMoreButton];
        
        UIButton *deleteAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        deleteAllButton.frame = CGRectMake(tableFooter.frame.size.width/2+buttonPaddingFromMiddle, buttonY, buttonWidth, buttonHeight);
        deleteAllButton.titleLabel.font = KP_REGULAR(12);
        deleteAllButton.layer.cornerRadius = 3;
        deleteAllButton.layer.borderWidth = 1;
        deleteAllButton.layer.masksToBounds = YES;
        deleteAllButton.layer.borderColor = tcolor(TextColor).CGColor;
        
        [deleteAllButton setTitle:NSLocalizedString(@"Clear old tasks", nil) forState:UIControlStateNormal];
        [deleteAllButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [deleteAllButton setTitleColor:tcolor(BackgroundColor) forState:UIControlStateHighlighted];
        [deleteAllButton setBackgroundImage:[tcolor(TextColor) image] forState:UIControlStateHighlighted];
        [deleteAllButton addTarget:self action:@selector(didPressDeleteAll:) forControlEvents:UIControlEventTouchUpInside];
        [tableFooter addSubview:deleteAllButton];
        [self.tableView setTableFooterView:tableFooter];
    }
}
#pragma mark - ViewController stuff
- (void)viewDidLoad
{
    self.state = @"done";
    [super viewDidLoad];
    self.tableView.reorderingEnabled = NO;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //self.hasAskedForMore = NO;
    //[self update];
}
-(void)update{
    [super update];
    [self updateTableFooter];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end