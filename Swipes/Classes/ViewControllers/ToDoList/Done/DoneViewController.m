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
        predicate = [NSPredicate predicateWithFormat:@"(completionDate != nil && completionDate >= %@ && parent = nil)",startDate];
        NSPredicate *remainingPred = [NSPredicate predicateWithFormat:@"(completionDate != nil && completionDate < %@ && parent = nil)",startDate];
        self.remainingTasks = [KPToDo MR_countOfEntitiesWithPredicate:remainingPred];
    }
    else{
        self.remainingTasks = 0;
        predicate = [NSPredicate predicateWithFormat:@"(completionDate != nil && parent = nil)"];
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
    [UTILITY confirmBoxWithTitle:@"Are you sure?" andMessage:@"Deleting old completed tasks can't be undone" cancel:@"Cancel" confirm:@"Delete them" block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            NSDate *startDate = [[NSDate date] dateAtStartOfDay];
            NSPredicate *remainingPred = [NSPredicate predicateWithFormat:@"(completionDate != nil && completionDate < %@ && parent = nil)",startDate];
            NSArray *oldCompletedTasks = [KPToDo MR_findAllWithPredicate:remainingPred];
            [KPToDo deleteToDos:oldCompletedTasks save:YES force:NO];
            [self update];
        }
    }];
}
-(void)updateTableFooter{
    if(kFilter.isActive)
        return;
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
        loadMoreButton.titleLabel.font = KP_REGULAR(14);
        loadMoreButton.layer.cornerRadius = 3;
        loadMoreButton.layer.borderWidth = 1;
        loadMoreButton.layer.masksToBounds = YES;
        loadMoreButton.layer.borderColor = tcolor(TextColor).CGColor;
        
        [loadMoreButton setTitle:@"Show old tasks" forState:UIControlStateNormal];
        [loadMoreButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [loadMoreButton setTitleColor:tcolor(BackgroundColor) forState:UIControlStateHighlighted];
        [loadMoreButton setBackgroundImage:[tcolor(TextColor) image] forState:UIControlStateHighlighted];
        [loadMoreButton addTarget:self action:@selector(didPressLoadMore:) forControlEvents:UIControlEventTouchUpInside];
        [tableFooter addSubview:loadMoreButton];
        
        UIButton *deleteAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        deleteAllButton.frame = CGRectMake(tableFooter.frame.size.width/2+buttonPaddingFromMiddle, buttonY, buttonWidth, buttonHeight);
        deleteAllButton.titleLabel.font = KP_REGULAR(14);
        deleteAllButton.layer.cornerRadius = 3;
        deleteAllButton.layer.borderWidth = 1;
        deleteAllButton.layer.masksToBounds = YES;
        deleteAllButton.layer.borderColor = tcolor(TextColor).CGColor;
        
        [deleteAllButton setTitle:@"Clear old tasks" forState:UIControlStateNormal];
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
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.hasAskedForMore = NO;
    [self update];
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