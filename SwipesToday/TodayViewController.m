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
#import "SavedChangeHandler.h"
#import "UIColor+Utilities.h"

#define kRowHeight 45
#define kButtonHeight 44
#define kToolbarHeight 60

@interface TodayViewController () <NCWidgetProviding, UITableViewDataSource, UITableViewDelegate, TodayCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UIView* tempView;
@property (nonatomic) NSArray *todos;
@property (nonatomic, weak) IBOutlet UIButton* showAll;
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
    
    //[Global initCoreData];
    [Global initCoreData];
    // Do any additional setup after loading the view from its nib.
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.scrollEnabled = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // Do any additional setup after loading the view from its nib.
    
    
    CGFloat plusX = 20;
    CGFloat plusY = 10;
    CGFloat titleXInset = 16;
    UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    plusButton.frame = CGRectMake(self.view.bounds.size.width-kButtonHeight-plusX, self.view.bounds.size.height-kButtonHeight-plusY, kButtonHeight, kButtonHeight); //CGRectMake(plusX, self.view.bounds.size.height-kButtonHeight, kButtonHeight, kButtonHeight);
    plusButton.layer.cornerRadius = kButtonHeight/2;
    plusButton.layer.borderWidth = 1;
    plusButton.layer.masksToBounds = YES;
    plusButton.layer.borderColor = alpha(tcolor(TasksColor),0.4).CGColor;
    plusButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    plusButton.titleLabel.font = iconFont(18);
    [plusButton setTitle:iconString(@"plusThick") forState:UIControlStateNormal];
    [plusButton setTitle:iconString(@"plusThick") forState:UIControlStateHighlighted];
    [plusButton setBackgroundImage:[alpha(tcolorF(TextColor,ThemeLight),0.2) image] forState:UIControlStateNormal];
    [plusButton setBackgroundImage:[alpha(tcolorF(TextColor, ThemeLight),0.6) image] forState:UIControlStateHighlighted];
    [plusButton setTitleColor:alpha(tcolor(TasksColor),1.0) forState:UIControlStateNormal];
    [plusButton addTarget:self action:@selector(onPlus:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:plusButton];
    
    
    UIButton *showAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    showAllButton.frame = CGRectMake(0, self.view.bounds.size.height-kButtonHeight-plusY, self.view.bounds.size.width-kButtonHeight-plusX, kButtonHeight);
    showAllButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    showAllButton.titleEdgeInsets = UIEdgeInsetsMake(0, titleXInset, 0, 0);
    showAllButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [showAllButton setTitle:@"" forState:UIControlStateNormal];
    [showAllButton setTitleColor:tcolorF(TextColor,ThemeDark) forState:UIControlStateNormal];
    [showAllButton setTitleColor:alpha(tcolorF(TextColor,ThemeDark),0.7) forState:UIControlStateHighlighted];
    showAllButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    showAllButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [showAllButton addTarget:self action:@selector(onShowAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showAllButton];
    self.showAll = showAllButton;
    
    
    
    //self.view.bounds = CGRectMake(0, 0, updatedSize.width, updatedSize.height);
    [self reloadDataSource];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self reloadDataSource];
}

-(void)reloadDataSource{
    NSDate *endDate = [NSDate date];
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(schedule < %@ AND completionDate = nil AND parent = nil)",endDate];
    NSArray *results = [KPToDo MR_findAllSortedBy:@"order" ascending:NO withPredicate:predicate inContext:localContext];
    self.todos = [KPToDo sortOrderForItems:results newItemsOnTop:YES save:NO context:localContext];
    SavedChangeHandler *changeHandler = [[SavedChangeHandler alloc] init];
    if([localContext hasChanges])
        [changeHandler saveContextForSynchronization:localContext];
    [self.tableView reloadData];
    [self updateContentSize];

}

-(void)updateContentSize{
    CGSize updatedSize = [self preferredContentSize];
    updatedSize.width = self.view.bounds.size.width;
    updatedSize.height = MIN(3,self.todos.count)*kRowHeight + kToolbarHeight;
    [self setPreferredContentSize:updatedSize];
    NSInteger numberOfCurrentTasks = self.todos.count;
    NSString *showAllTitle = @"No current tasks.  Add one";
    if(numberOfCurrentTasks > 0){
        if(numberOfCurrentTasks > 3)
            showAllTitle = [NSString stringWithFormat:@"%lu more tasks.",(long)numberOfCurrentTasks-3];
    }
    [self.showAll setTitle:showAllTitle forState:UIControlStateNormal];
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
    return MIN(3,self.todos.count);
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

- (IBAction)onShowAll:(id)sender
{
    if(self.todos.count == 0){
        return [self onPlus:sender];
    }
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"swipes://todo/view?menu=today"]];
    //    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"swipes://todo/view?id=%@", tempId]];
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        // put some code here if needed or pass nil for completion handler
    }];
    return;
    /*CGSize updatedSize = [self preferredContentSize];
    if (101 < updatedSize.height) {
        updatedSize.height = 100;
        [_showHideMore setTitle:@"Show more >" forState:UIControlStateNormal];
    }
    else {
        updatedSize.height = 200;
        [_showHideMore setTitle:@"Show less <" forState:UIControlStateNormal];
    }
    //self.view.bounds = CGRectMake(0, 0, updatedSize.width, updatedSize.height);
    [self setPreferredContentSize:updatedSize];*/
}

- (IBAction)onPlus:(id)sender
{
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"swipes://todo/addprompt"]];
     //    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"swipes://todo/view?id=%@", tempId]];
     [self.extensionContext openURL:url completionHandler:^(BOOL success) {
     // put some code here if needed or pass nil for completion handler
     }];
}

-(void)saveContext:(NSManagedObjectContext*)context{
    
}
-(void)didTapCell:(TodayTableViewCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    KPToDo* todo1 = self.todos[indexPath.row];
    NSString* tempId = todo1.getTempId;
    todo1 = nil;
    NSLog(@"tempId is: %@", tempId);
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"swipes://todo/view?id=%@", tempId]];
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        // put some code here if needed or pass nil for completion handler
    }];
}
-(void)didCompleteCell:(TodayTableViewCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    KPToDo *model = [self.todos objectAtIndex:indexPath.row];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_context];
        KPToDo *localModel = [model MR_inContext:localContext];
        [KPToDo completeToDos:@[localModel] save:NO context:localContext analytics:NO];
        SavedChangeHandler *changeHandler = [[SavedChangeHandler alloc] init];
        [changeHandler saveContextForSynchronization:localContext];
    });
    //[KPToDo completeToDos:@[model] save:NO];
    NSMutableArray *mutCopy = [self.todos mutableCopy];
    [mutCopy removeObjectAtIndex:indexPath.row];
    BOOL insert = mutCopy.count >= 3;
    NSIndexPath *insertPath = [NSIndexPath indexPathForItem:2 inSection:0];
    self.todos = [mutCopy copy];
    [self.tableView beginUpdates];
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    if(insert)
        [self.tableView insertRowsAtIndexPaths:@[insertPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self updateContentSize];
    //[self reloadDataSource];
}

//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//
//}

@end
