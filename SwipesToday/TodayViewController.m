//
//  TodayViewController.m
//  SwipesToday
//
//  Created by demosten on 9/18/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <NotificationCenter/NotificationCenter.h>
#import "KPToDo.h"
#import "TodayViewController.h"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    DLog(@"storeURL: %@", [Global coreDataUrl]);
    
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreAtURL:[Global coreDataUrl]];

    // Do any additional setup after loading the view from its nib.
    NSDate *endDate = [NSDate date];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(schedule < %@ AND completionDate = nil AND parent = nil)",endDate];
    NSArray *results = [KPToDo MR_findAllSortedBy:@"order" ascending:NO withPredicate:predicate];
    NSArray* result = [KPToDo sortOrderForItems:results newItemsOnTop:YES save:YES];
    DLog(@"result: %@", result);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
