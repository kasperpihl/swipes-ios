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
#import "SwipingOverlayView.h"
#import "TodayTableViewCell.h"
#import "ThemeHandler.h"
#import "SavedChangeHandler.h"
#import "UIColor+Utilities.h"


#define kContentInsetsTableTop 0
#define kContentInsetsTableBottom 5
#define kRowHeight 38
#define kBottomHeight 75

#define kButtonHeight 30
#define kIconX 18
#define kDefaultShowNumber 3

@interface TodayViewController () <NCWidgetProviding, UITableViewDataSource, UITableViewDelegate, TodayCellDelegate, SwipingOverlayViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic) NSInteger numberToShow;
@property (nonatomic) NSArray *todos;
@property (nonatomic) BOOL swipingEnabled;
@property (nonatomic) IBOutlet UIButton* addButton;
@property (nonatomic) IBOutlet UIButton* allButton;
@property (nonatomic) IBOutlet UILabel *countLabel;
@property (nonatomic) IBOutlet UILabel *infoLabel;
@property (nonatomic) IBOutlet SwipingOverlayView *swipingOverlay;
@end

@implementation TodayViewController
-(void)setTodos:(NSArray *)todos{
    _todos = todos;
    //[self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.numberToShow = kDefaultShowNumber;
    UTILITY.rootViewController = self;
    
    
    //[Global initCoreData];
    [Global initCoreData];
    // Do any additional setup after loading the view from its nib.
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.contentInset = UIEdgeInsetsMake(kContentInsetsTableTop, 0, kContentInsetsTableBottom, 0);
    _tableView.scrollEnabled = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // Do any additional setup after loading the view from its nib.
    
    
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-kBottomHeight, self.view.frame.size.width, kBottomHeight)];
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    bottomView.backgroundColor = [UIColor clearColor];
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(kIconX, 0, self.view.frame.size.width-2*kIconX, 1)];
    seperator.backgroundColor = tcolorF(TextColor, ThemeDark);
    [bottomView addSubview:seperator];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(kIconX, 0, bottomView.frame.size.width-kIconX, bottomView.frame.size.height)];
    countLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:40];
    countLabel.numberOfLines = 1;
    countLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    countLabel.textColor = tcolorF(TextColor,ThemeDark);
    countLabel.text = @"10";
    [bottomView addSubview:countLabel];
    self.countLabel = countLabel;
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, bottomView.frame.size.width-100, 30)];
    CGRectSetCenterY(infoLabel, bottomView.frame.size.height/2);
    infoLabel.numberOfLines = 0;
    //infoLabel.backgroundColor = tcolor(LaterColor);
    infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    infoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    infoLabel.textColor = tcolorF(TextColor,ThemeDark);
    infoLabel.text = @"TASKS\r\nFOR NOW";
    /*NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:0];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"TASKS\r\nFOR TODAY" attributes:@{NSParagraphStyleAttributeName : paragrahStyle, NSForegroundColorAttributeName : tcolorF(TextColor,ThemeDark),NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:12]}];
    infoLabel.attributedText = attributedString ;*/
    [bottomView addSubview:infoLabel];
    self.infoLabel = infoLabel;
    
    
    SwipingOverlayView *swipingOverlayView = [[SwipingOverlayView alloc] initWithFrame:bottomView.bounds];
    swipingOverlayView.delegate = self;
    CGRectSetWidth(swipingOverlayView, bottomView.frame.size.width/2);
    [bottomView addSubview:swipingOverlayView];
    bottomView.userInteractionEnabled = YES;
    self.swipingOverlay = swipingOverlayView;
    
    /*
    UIButton *showAllButton = [[UIButton alloc] initWithFrame:CGRectMake(kIconX, 0, bottomView.frame.size.width-kIconX, bottomView.frame.size.height)];
    showAllButton.titleLabel.font = iconFont(50);
    [showAllButton setTitle:@"todaytoday" forState:UIControlStateNormal];
    [showAllButton setTitleColor:tcolorF(TextColor, ThemeLight) forState:UIControlStateNormal];
    showAllButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [showAllButton addTarget:self action:@selector(onShowAll:) forControlEvents:UIControlEventTouchUpInside];
    showAllButton.alpha = 0.01;
    [bottomView addSubview:showAllButton];*/
    CGFloat buttonSpacing = 25;
    
    UIButton *plusAllAroundButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-kButtonHeight-buttonSpacing, 0, kButtonHeight, bottomView.frame.size.height)];
    plusAllAroundButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:9];
    [plusAllAroundButton setTitle:@"ADD" forState:UIControlStateNormal];
    [plusAllAroundButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [plusAllAroundButton setTitleEdgeInsets:UIEdgeInsetsMake(47, 0, 0, 0)];
    [plusAllAroundButton addTarget:self action:@selector(onPlus:) forControlEvents:UIControlEventTouchUpInside];
    plusAllAroundButton.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
    
    UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    plusButton.frame = CGRectMake(0, 0, kButtonHeight, kButtonHeight); //CGRectMake(plusX, self.view.bounds.size.height-kButtonHeight, kButtonHeight, kButtonHeight);
    CGRectSetCenterY(plusButton, bottomView.frame.size.height/2);
    plusButton.layer.cornerRadius = kButtonHeight/2;
    plusButton.layer.borderWidth = 1;
    plusButton.layer.masksToBounds = YES;
    plusButton.layer.borderColor = tcolorF(TextColor, ThemeDark).CGColor;
    plusButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
    plusButton.titleLabel.font = iconFont(12);
    [plusButton setTitle:iconString(@"widgetAdd") forState:UIControlStateNormal];
    [plusButton setTitle:iconString(@"widgetAdd") forState:UIControlStateHighlighted];
    [plusButton setBackgroundImage:[alpha(tcolorF(TextColor,ThemeDark),0.0) image] forState:UIControlStateNormal];
    [plusButton setBackgroundImage:[alpha(tcolorF(TextColor, ThemeDark),1.0) image] forState:UIControlStateHighlighted];
    [plusButton setTitleColor:tcolorF(TextColor, ThemeDark) forState:UIControlStateNormal];
    [plusButton setTitleColor:tcolorF(TextColor, ThemeLight) forState:UIControlStateHighlighted];
    [plusButton addTarget:self action:@selector(onPlus:) forControlEvents:UIControlEventTouchUpInside];
    [plusAllAroundButton addSubview:plusButton];
    [bottomView addSubview:plusAllAroundButton];
    
    UIButton *allAroundButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(plusAllAroundButton.frame)-buttonSpacing-kButtonHeight, 0, kButtonHeight, bottomView.frame.size.height)];
    allAroundButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:9];
    [allAroundButton setTitle:@"SHOW" forState:UIControlStateNormal];
    [allAroundButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [allAroundButton setTitleEdgeInsets:UIEdgeInsetsMake(47, 0, 0, 0)];
    [allAroundButton addTarget:self action:@selector(onAll:) forControlEvents:UIControlEventTouchUpInside];
    allAroundButton.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
    
    UIButton *allButton = [UIButton buttonWithType:UIButtonTypeCustom];
    allButton.frame = CGRectMake(0, 0, kButtonHeight, kButtonHeight); //CGRectMake(plusX, self.view.bounds.size.height-kButtonHeight, kButtonHeight, kButtonHeight);
    CGRectSetCenterY(allButton, bottomView.frame.size.height/2);
    allButton.layer.cornerRadius = kButtonHeight/2;
    allButton.layer.borderWidth = 1;
    allButton.layer.masksToBounds = YES;
    allButton.layer.borderColor = tcolorF(TextColor, ThemeDark).CGColor;
    allButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    allButton.titleLabel.font = iconFont(9);
    [allButton setTitle:iconString(@"widgetAll") forState:UIControlStateNormal];
    [allButton setTitle:iconString(@"widgetAll") forState:UIControlStateHighlighted];
    [allButton setBackgroundImage:[alpha(tcolorF(TextColor,ThemeDark),0.0) image] forState:UIControlStateNormal];
    [allButton setBackgroundImage:[alpha(tcolorF(TextColor, ThemeDark),1.0) image] forState:UIControlStateHighlighted];
    [allButton setTitleColor:tcolorF(TextColor, ThemeDark) forState:UIControlStateNormal];
    [allButton setTitleColor:tcolorF(TextColor, ThemeLight) forState:UIControlStateHighlighted];
    [allButton addTarget:self action:@selector(onAll:) forControlEvents:UIControlEventTouchUpInside];
    [allAroundButton addSubview:allButton];
    [bottomView addSubview:allAroundButton];
    
    [self.view addSubview:bottomView];
    
    [self reloadDataSource];
}

-(void)swipingOverlay:(SwipingOverlayView *)overlay didTapInPoint:(CGPoint)point{
    if(point.x < CGRectGetMaxX(self.infoLabel.frame))
        [self onShowAll:nil];
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
    updatedSize.height = MIN(1,(self.todos.count == 0 ? 0 : 1))*(kContentInsetsTableBottom+kContentInsetsTableTop) + MIN(self.numberToShow,self.todos.count)*kRowHeight + kBottomHeight;
    [self setPreferredContentSize:updatedSize];
    NSInteger numberOfCurrentTasks = self.todos.count;
    NSString *infoTitle = @"TASKS\r\nFOR NOW";
    if(numberOfCurrentTasks > 0){
        self.countLabel.text = [NSString stringWithFormat:@"%lu",(long)numberOfCurrentTasks];
        if(numberOfCurrentTasks == 1){
            infoTitle = @"TASK\r\nFOR NOW";
        }
    }
    else{
        self.countLabel.text = @"NO";
    }
    
    
    [self.countLabel sizeToFit];
    CGRectSetCenterY(self.countLabel, [self.countLabel superview].frame.size.height/2);
    CGRectSetX(self.infoLabel, CGRectGetMaxX(self.countLabel.frame) + 10);
    [self.infoLabel setText:infoTitle];
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
    CGRect rect = _tableView.frame;
    rect.size.height = contentSize.height - kBottomHeight;
    rect.size.width = contentSize.width;
    _tableView.frame = rect;
}
-(UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MIN(self.numberToShow,self.todos.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@cell",@"TodayWidget"];
    TodayTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[TodayTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.colorIndicatorView.backgroundColor =  tcolor(DoneColor);
        cell.delegate = self;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(TodayTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    KPToDo *model = [self.todos objectAtIndex:indexPath.row];
    [cell.dotView setPriority:model.priority.boolValue];
    [cell resetAndSetTaskTitle:model.title];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kRowHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    KPToDo* todo1 = self.todos[indexPath.row];
    NSString* tempId = todo1.getTempId;
    todo1 = nil;
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"swipes://todo/view?id=%@", tempId]];
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        // put some code here if needed or pass nil for completion handler
    }];
}

- (IBAction)onShowAll:(id)sender{
    if(self.todos.count > self.numberToShow){
        self.numberToShow = self.todos.count;
        [self.tableView reloadData];
        [self updateContentSize];
    }
}


- (IBAction)onAll:(id)sender
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
