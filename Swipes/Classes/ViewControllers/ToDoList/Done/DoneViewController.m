//
//  DoneViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "DoneViewController.h"
@interface DoneViewController ()
@property (nonatomic) BOOL hasAskedForMore;
@end

@implementation DoneViewController
-(NSArray *)itemsForItemHandler:(ItemHandler *)handler{
    NSPredicate *predicate;
    NSDate *startDate = [[NSDate date] dateAtStartOfDay];
    if(!self.hasAskedForMore) predicate = [NSPredicate predicateWithFormat:@"(state == %@) AND (completionDate >= %@)",@"done", startDate];
    else predicate = [NSPredicate predicateWithFormat:@"(state == %@)",@"done"];
    return [KPToDo MR_findAllSortedBy:@"completionDate" ascending:NO withPredicate:predicate];
}
-(NSString *)itemHandler:(ItemHandler *)handler titleForItem:(KPToDo *)item{
    return [item readableTitleForStatus];
}

-(void)didPressLoadMore:(id)sender{
    self.hasAskedForMore = YES;
    [self update];
}
#pragma mark - ViewController stuff
- (void)viewDidLoad
{
    self.state = @"done";
    [super viewDidLoad];
    UIView *askMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    UIButton *loadMoreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loadMoreButton setTitle:@"Load more" forState:UIControlStateNormal];
    [loadMoreButton addTarget:self action:@selector(didPressLoadMore:) forControlEvents:UIControlEventTouchUpInside];
    loadMoreButton.frame = CGRectMake(10, 10, 300, 40);
    [askMoreView addSubview:loadMoreButton];
    [self.tableView setTableFooterView:askMoreView];
    
	// Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(!self.hasAskedForMore){
        
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
