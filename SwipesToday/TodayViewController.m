//
//  TodayViewController.m
//  SwipesToday
//
//  Created by demosten on 9/18/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <NotificationCenter/NotificationCenter.h>
#import "KPToDo.h"
#import "UtilityClass.h"
#import "TodayViewController.h"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UTILITY.rootViewController = self;
    
    DLog(@"storeURL: %@", [Global coreDataUrl]);
    
    [Global initCoreData];

    // Do any additional setup after loading the view from its nib.
    NSDate *endDate = [NSDate date];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(schedule < %@ AND completionDate = nil AND parent = nil)",endDate];
    NSArray *results = [KPToDo MR_findAllSortedBy:@"order" ascending:NO withPredicate:predicate];
    NSArray* result = [KPToDo sortOrderForItems:results newItemsOnTop:YES save:YES];
    DLog(@"result: %@", result);
    
    KPToDo* todo1 = result[0];
    NSString* tempId = todo1.getTempId;
    todo1 = nil;
    NSLog(@"tempId is: %@", tempId);
//  uncomment here for opening the first today todo or for going to add prompt

/*    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"swipes://todo/addprompt"]];
//    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"swipes://todo/view?id=%@", tempId]];
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        // put some code here if needed or pass nil for completion handler
    }];*/
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
