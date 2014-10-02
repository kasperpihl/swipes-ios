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
#import "TodayTableViewCell.h"
#import "ThemeHandler.h"

@interface TodayViewController () <NCWidgetProviding, UITableViewDataSource, UITableViewDelegate, TodayCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UIView* tempView;
@property (nonatomic) NSArray *todos;
@property (nonatomic, weak) IBOutlet UIButton* showHideMore;
@end

@implementation TodayViewController
-(void)setTodos:(NSArray *)todos{
    _todos = todos;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];


    UTILITY.rootViewController = self;
    
    DLog(@"storeURL: %@", [Global coreDataUrl]);
    
    [Global initCoreData];

    // Do any additional setup after loading the view from its nib.
    
    _tableView.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view from its nib.
    CGSize updatedSize = [self preferredContentSize];
    updatedSize.width = self.view.bounds.size.width;
    updatedSize.height = 100;
    [self setPreferredContentSize:updatedSize];
    //self.view.bounds = CGRectMake(0, 0, updatedSize.width, updatedSize.height);
    [self reloadDataSource];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self reloadDataSource];
}

-(void)reloadDataSource{
    NSDate *endDate = [NSDate date];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(schedule < %@ AND completionDate = nil AND parent = nil)",endDate];
    NSArray *results = [KPToDo MR_findAllSortedBy:@"order" ascending:NO withPredicate:predicate];
    self.todos = [KPToDo sortOrderForItems:results newItemsOnTop:YES save:YES];
    
    KPToDo* todo1 = self.todos[0];
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
    [self reloadDataSource];
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    completionHandler(NCUpdateResultNewData);
}



- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGSize contentSize = self.preferredContentSize;
    CGRect rect = _tempView.frame;
    rect.size.height = contentSize.height - 30;
    rect.size.width = contentSize.width;
    _tempView.frame = rect;
    _tableView.frame = rect;
}
-(UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.todos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@cell",@"TodayWidget"];
    TodayTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[TodayTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.colorIndicatorView.backgroundColor =  tcolor(DoneColor);
        cell.delegate = self;
        //cell.textLabel.text = @"Title";
        //[cell setMode:MCSwipeTableViewCellModeExit];
        //cell.delegate = self;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(TodayTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    KPToDo *model = [self.todos objectAtIndex:indexPath.row];
    [cell resetAndSetTaskTitle:model.title];
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


-(void)didCompleteCell:(TodayTableViewCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    KPToDo *model = [self.todos objectAtIndex:indexPath.row];
    [KPToDo completeToDos:@[model] save:YES];

    [self reloadDataSource];
}

//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//
//}

@end
