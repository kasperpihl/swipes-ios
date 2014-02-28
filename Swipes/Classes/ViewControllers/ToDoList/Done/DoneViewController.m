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
    predicate = [NSPredicate predicateWithFormat:@"(completionDate != nil) AND parent = nil"];
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
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(!self.hasAskedForMore){
        
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end