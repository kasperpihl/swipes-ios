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

#define kRowHeight 45
#define kButtonHeight 44

@interface TodayViewController () <NCWidgetProviding, UITableViewDataSource, UITableViewDelegate, TodayCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UIView* tempView;
@property (nonatomic) NSArray *todos;
@property (nonatomic, weak) IBOutlet UIButton* showHideMore;
@end

@implementation TodayViewController
-(void)setTodos:(NSArray *)todos{
    _todos = todos;
    //[self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];


    UTILITY.rootViewController = self;
    
    DLog(@"storeURL: %@", [Global coreDataUrl]);
    
    [Global initCoreData];

    // Do any additional setup after loading the view from its nib.
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.scrollEnabled = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // Do any additional setup after loading the view from its nib.
    CGSize updatedSize = [self preferredContentSize];
    updatedSize.width = self.view.bounds.size.width;
    updatedSize.height = 3*kRowHeight + kButtonHeight + 200;
    UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    plusButton.frame = CGRectMake(0, self.view.bounds.size.height-kButtonHeight, kButtonHeight, kButtonHeight);
    plusButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    plusButton.titleLabel.font = iconFont(20);
    [plusButton setTitle:@"editActionRoundedPlus" forState:UIControlStateNormal];
    [plusButton setTitleColor:tcolorF(TextColor,ThemeDark) forState:UIControlStateNormal];
    [plusButton addTarget:self action:@selector(onPlus:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:plusButton];
    
    UIButton *showAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    showAllButton.frame = CGRectMake(0, self.view.bounds.size.height-kButtonHeight, 100, kButtonHeight);
    [showAllButton setTitle:@"Show all" forState:UIControlStateNormal];
    
    
    [self setPreferredContentSize:updatedSize];
    
    //self.view.bounds = CGRectMake(0, 0, updatedSize.width, updatedSize.height);
    [self reloadDataSource];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)reloadDataSource{
    NSDate *endDate = [NSDate date];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(schedule < %@ AND completionDate = nil AND parent = nil)",endDate];
    NSArray *results = [KPToDo MR_findAllSortedBy:@"order" ascending:NO withPredicate:predicate];
    self.todos = [KPToDo sortOrderForItems:results newItemsOnTop:YES save:YES];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    //[self reloadDataSource];
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
    return MIN(self.todos.count,3);
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    KPToDo* todo1 = self.todos[indexPath.row];
    NSString* tempId = todo1.getTempId;
    todo1 = nil;
    NSLog(@"tempId is: %@", tempId);
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"swipes://todo/view?id=%@", tempId]];
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        // put some code here if needed or pass nil for completion handler
    }];
    //  uncomment here for opening the first today todo or for going to add prompt
    
    /*    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"swipes://todo/addprompt"]];
     //    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"swipes://todo/view?id=%@", tempId]];
     [self.extensionContext openURL:url completionHandler:^(BOOL success) {
     // put some code here if needed or pass nil for completion handler
     }];*/
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
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"swipes://todo/addprompt"]];
     //    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"swipes://todo/view?id=%@", tempId]];
     [self.extensionContext openURL:url completionHandler:^(BOOL success) {
     // put some code here if needed or pass nil for completion handler
     }];
}


-(void)didCompleteCell:(TodayTableViewCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    KPToDo *model = [self.todos objectAtIndex:indexPath.row];
    [KPToDo completeToDos:@[model] save:YES];
    NSMutableArray *mutCopy = [self.todos mutableCopy];
    [mutCopy removeObjectAtIndex:indexPath.row];
    self.todos = [mutCopy copy];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    //[self reloadDataSource];
}

//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//
//}

@end
