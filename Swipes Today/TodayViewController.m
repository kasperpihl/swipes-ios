//
//  TodayViewController.m
//  Swipes Today
//
//  Created by demosten on 8/28/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UIView* tempView;
@property (nonatomic, weak) IBOutlet UIButton* showHideMore;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGSize updatedSize = [self preferredContentSize];
    updatedSize.width = self.view.bounds.size.width;
    updatedSize.height = 100;
    [self setPreferredContentSize:updatedSize];
    //self.view.bounds = CGRectMake(0, 0, updatedSize.width, updatedSize.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGSize contentSize = self.preferredContentSize;
    CGRect rect = _tempView.frame;
    rect.size.height = contentSize.height - 30;
    rect.size.width = contentSize.width;
    _tempView.frame = rect;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encoutered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (IBAction)onShowHideMore:(id)sender
{
    CGSize updatedSize = [self preferredContentSize];
    if (101 < updatedSize.height) {
        updatedSize.height = 100;
        [_showHideMore setTitle:@"Show more >" forState:UIControlStateNormal];
    }
    else {
        updatedSize.height = 200;
        [_showHideMore setTitle:@"Show less <" forState:UIControlStateNormal];
    }
    //self.view.bounds = CGRectMake(0, 0, updatedSize.width, updatedSize.height);
    [self setPreferredContentSize:updatedSize];
}

- (IBAction)onPlus:(id)sender
{
    
}

//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//    
//}

@end
