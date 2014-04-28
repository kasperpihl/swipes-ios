//
//  SubtasksViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 21/02/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "KPToDo.h"
#import "SubtasksViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SubtaskCell.h"
#import "StyleHandler.h"
#import "AKSegmentedControl.h"
#import "SlowHighlightIcon.h"

#import "KPReorderTableView.h"

#define kExtraDragable 10
#
#define kNotificationHeight 18
#define kNotificationFont KP_REGULAR(13)

#define SEGMENT_BUTTON_WIDTH 52
#define INTERESTED_SEGMENT_RECT CGRectMake(0,0,(2*SEGMENT_BUTTON_WIDTH)+(8*SEPERATOR_WIDTH),kDragableHeight-kExtraDragable)

@interface SubtasksViewController () <UITableViewDataSource,UITableViewDelegate,SubtaskCellDelegate,MCSwipeTableViewCellDelegate,ATSDragToReorderTableViewControllerDelegate,ATSDragToReorderTableViewControllerDraggableIndicators>
@property (nonatomic) KPReorderTableView *tableView;
@property (nonatomic) NSArray *subtasks;
@property (nonatomic) BOOL isMenu;
@property (nonatomic) UIImageView *dragIcon;
@property (nonatomic) AKSegmentedControl *segmentedControl;
@property (nonatomic) NSIndexPath *draggingRow;

@end

@implementation SubtasksViewController
-(void)setContentInset:(UIEdgeInsets)insets{
    self.tableView.contentInset = insets;
}
-(void)setModel:(KPToDo *)model{
    if(_model != model){
        _model = model;
    }
    [self loadData];
    [self reload];
    self.tableView.contentOffset = CGPointMake(0,self.tableView.tableHeaderView.frame.size.height);
}
-(void)loadData{
    BOOL isCompletedMenu = ([[self.segmentedControl selectedIndexes] firstIndex] == 1);
    NSString *predString = isCompletedMenu ? @"completionDate != nil" : @"completionDate = nil";
    NSSet *filteredSet = [self.model.subtasks filteredSetUsingPredicate:[NSPredicate predicateWithFormat:predString]];
    
    NSString *sortKey = isCompletedMenu ? @"completionDate" : @"order";
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:NO];
    
    NSArray *sortedObjects = [filteredSet sortedArrayUsingDescriptors:@[descriptor]];
    
    if(!isCompletedMenu){
        sortedObjects = [KPToDo sortOrderForItems:sortedObjects save:YES];
    }
    
    self.subtasks = sortedObjects;
    /* 
     Filter down to completed or undone
     If undone - sort for order and make new numbers if needed
     reload tableview
     
     */
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}
-(id)init{
    self = [super init];
    if(self){
        self.view.backgroundColor = tcolor(BackgroundColor);
        self.dragableTop = [[UIButton alloc] initWithFrame:CGRectMake(-1, 0, 322, kDragableHeight-kExtraDragable)];
        self.dragableTop.backgroundColor = tcolor(BackgroundColor);
        UIImageView *dragIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dragable_icon"]];
        self.dragIcon = dragIcon;
        self.dragableTop.layer.borderColor = gray(217, 1).CGColor;
        self.dragableTop.layer.borderWidth = 1;
        [self.dragableTop addSubview:dragIcon];
        
        AKSegmentedControl *segmentedControl = [[AKSegmentedControl alloc] initWithFrame:INTERESTED_SEGMENT_RECT];
        CGRectSetCenterX(segmentedControl, self.dragableTop.frame.size.width/2);
        [segmentedControl setSelectedIndex: 0];
        self.segmentedControl = segmentedControl;
        [segmentedControl addTarget:self action:@selector(changeViewController:) forControlEvents:UIControlEventValueChanged];
        segmentedControl.hidden = YES;
        [segmentedControl setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [segmentedControl setSegmentedControlMode:AKSegmentedControlModeSticky];
        //UIButton *buttonSchedule = [self buttonForSegment:KPSegmentButtonSchedule];
        UIButton *buttonToday = [self buttonForSegment:KPSegmentButtonToday];
        
        UIButton *buttonDone = [self buttonForSegment:KPSegmentButtonDone];
        [segmentedControl setButtonsArray:@[buttonToday, buttonDone]];
        
        [self.dragableTop addSubview:self.segmentedControl];
        
        CGRectSetCenter(dragIcon, 160, (kDragableHeight-kExtraDragable)/2);
        
        self.notification = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kNotificationHeight, kNotificationHeight)];
        self.notification.text = @"3";
        self.notification.font = kNotificationFont;
        self.notification.textAlignment = NSTextAlignmentCenter;
        self.notification.textColor = tcolorF(TextColor,ThemeDark);
        self.notification.layer.cornerRadius = kNotificationHeight/2;
        self.notification.backgroundColor = tcolor(LaterColor);
        self.notification.layer.masksToBounds = YES;
        [self.dragableTop addSubview:self.notification];
        CGRectSetCenterX(self.notification, CGRectGetMaxX(self.dragIcon.frame));
        CGRectSetCenterY(self.notification, CGRectGetMinY(self.dragIcon.frame));
        
        [self.view addSubview:self.dragableTop];
        
        self.tableView = [[KPReorderTableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.dragableTop.frame), 320, self.view.frame.size.height-CGRectGetMaxY(self.dragableTop.frame)) style:UITableViewStylePlain];
        self.tableView.dataSource = self;
        self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        self.tableView.dragDelegate = self;
        self.tableView.indicatorDelegate = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.delegate = self;
        UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        SubtaskCell *addCell = [[SubtaskCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SubtaskTitleHeader"];
        addCell.subtaskDelegate = self;
        CGRectSetSize(addCell,320,50);
        [addCell setAddMode:YES];
        [tableHeader addSubview:addCell];
        [self.tableView setTableHeaderView:tableHeader];
        self.tableView.contentOffset = CGPointMake(0,self.tableView.tableHeaderView.frame.size.height);
        
        [self.view addSubview:self.tableView];
    }
    return self;
}
-(UIButton*)buttonForSegment:(KPSegmentButtons)controlButton{
    UIButton *button = [[SlowHighlightIcon alloc] init];
    CGRectSetSize(button, SEGMENT_BUTTON_WIDTH, self.segmentedControl.frame.size.height);
    button.adjustsImageWhenHighlighted = NO;
    NSString *textString;
    UIColor *highlightColor;
    switch (controlButton) {
        case KPSegmentButtonSchedule:
            textString = iconString(@"later");
            highlightColor = tcolor(LaterColor);
            break;
        case KPSegmentButtonToday:
            textString = iconString(@"today");
            highlightColor = tcolor(TasksColor);
            break;
        case KPSegmentButtonDone:
            textString = iconString(@"done");
            highlightColor = tcolor(DoneColor);
            break;
    }
    
    button.titleLabel.font = iconFont(23);
    [button setTitle:textString forState:UIControlStateNormal];
    [button setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
    [button setTitleColor:highlightColor forState:UIControlStateHighlighted];
    [button setTitleColor:highlightColor forState:UIControlStateSelected];
    [button setTitleColor:highlightColor forState:UIControlStateSelected | UIControlStateHighlighted];
    return button;
}

-(void)subtaskCell:(SubtaskCell *)cell editedSubtask:(NSString *)subtask{
    NSString *editedText = [subtask stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if(editedText.length > 0)
        [cell.model setTitle:subtask];
    
    [KPToDo saveToSync];
}
-(void)addedSubtask:(NSString *)subtask{
    [self.model addSubtask:subtask save:YES];
    [self loadData];
    //self.titles = [@[subtask] arrayByAddingObjectsFromArray:self.titles];
    [self animateInAddTask];
}

- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(KPReorderTableView *)dragTableViewController {
    SubtaskCell *cell = [[SubtaskCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [self tableView:self.tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
	return cell;
}
- (void)dragTableViewController:(KPReorderTableView *)dragTableViewController didBeginDraggingAtRow:(NSIndexPath *)dragRow{
    self.draggingRow = dragRow;
}
-(void)dragTableViewController:(KPReorderTableView *)dragTableViewController didEndDraggingToRow:(NSIndexPath *)destinationIndexPath{
    if(destinationIndexPath.row == self.draggingRow.row){
        self.draggingRow = nil;
        return;
    }
    /*NSMutableArray *titles = [self.subtasks mutableCopy];
    NSString *title = [self.subtasks objectAtIndex:self.draggingRow.row];
    [titles removeObjectAtIndex:self.draggingRow.row];
    NSInteger newIndex = (destinationIndexPath.row > self.draggingRow.row) ? destinationIndexPath.row : destinationIndexPath.row;
    [titles insertObject:title atIndex:newIndex];
    self. = [titles copy];*/
    [self reload];
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    NSLog(@"move from %i to %i",sourceIndexPath.row,destinationIndexPath.row);
}

-(void)switchToMenu:(BOOL)menu animated:(BOOL)animated{
    CGFloat duration = 0.4;
    if(menu == self.isMenu) return;
    self.isMenu = menu;
    voidBlock preBlock = ^{
        if(menu){
            self.segmentedControl.hidden = NO;
            self.segmentedControl.alpha = 0;
        }
        else {
            self.dragIcon.hidden = NO;
            self.dragIcon.alpha = 0;
        }
    };
    voidBlock showBlock = ^{
        NSInteger iconHeight = 22;
        if(menu){
            CGRectSetCenterX(self.notification, self.dragableTop.frame.size.width/2 - self.segmentedControl.frame.size.width/4 + iconHeight/2);
            CGRectSetCenterY(self.notification, self.dragableTop.frame.size.height/2-iconHeight/2);
        }
        else{
            CGRectSetCenterX(self.notification, CGRectGetMaxX(self.dragIcon.frame));
            CGRectSetCenterY(self.notification, CGRectGetMinY(self.dragIcon.frame));
        }
        self.dragIcon.alpha = menu ? 0 : 1;
        self.segmentedControl.alpha = menu ? 1 : 0;
    };
    preBlock();
    [UIView animateWithDuration:duration animations:^{
        showBlock();
    } completion:^(BOOL finished) {
       
        [UIView animateWithDuration:duration animations:^{
            //showBlock();
        }];
    }];
}


-(void)startedSliding{
    //[self switchToMenu:NO animated:YES];
    
}
-(void)willStartOpening:(BOOL)opening{
    [self switchToMenu:opening animated:YES];
}
-(void)finishedOpening:(BOOL)opened{
    
    if(opened){
        if(!self.opened) [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(animateInAddTask) userInfo:nil repeats:NO];
    }
    else{
        self.tableView.contentOffset = CGPointMake(0,self.tableView.tableHeaderView.frame.size.height);
    }
    self.opened = opened;
}
-(void)reload{
    [self.tableView reloadData];
    self.notification.text = [NSString stringWithFormat:@"%i",self.subtasks.count];
}
-(void)animateInAddTask{
    [self reload];
    self.tableView.contentOffset = CGPointMake(0,self.tableView.tableHeaderView.frame.size.height);
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}



-(void)swipeTableViewCell:(SubtaskCell *)cell didStartPanningWithMode:(MCSwipeTableViewCellMode)mode{
}

-(void)swipeTableViewCell:(SubtaskCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode{
    if(state == MCSwipeTableViewCellStateNone) return;
   
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"triggered:%i",indexPath.row);
    if(indexPath){
        /*NSMutableArray *mutCopy = [self.titles mutableCopy];
        [mutCopy removeObjectAtIndex:indexPath.row];
        self.titles = [mutCopy copy];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        self.notification.text = [NSString stringWithFormat:@"%i",self.titles.count];*/
    }
}
-(void)swipeTableViewCell:(SubtaskCell *)cell slidedIntoState:(MCSwipeTableViewCellState)state{
    if(state == MCSwipeTableViewCellModeNone){
        [cell setDotColor:tcolor(TasksColor)];
    }
    if(state == MCSwipeTableViewCellState1){
        [cell setDotColor:tcolor(DoneColor)];
    }
    if(state == MCSwipeTableViewCellState3){
        [cell setDotColor:[UIColor redColor]];
    }
    
}


- (void)changeViewController:(AKSegmentedControl *)segmentedControl{
#warning TODO: fix data to be loaded proper
    [self loadData];
    [self reload];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.subtasks.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"SubtaskCell";
    SubtaskCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[SubtaskCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
    }
	return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(SubtaskCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    KPToDo *subtask = (KPToDo*)[self.subtasks objectAtIndex:indexPath.row];
    [cell setTitle:subtask.title];
    cell.model = subtask;
    [cell setFirstColor:[StyleHandler colorForCellType:CellTypeDone]];
    [cell setThirdColor:[UIColor redColor]];
    [cell setFirstIconName:[StyleHandler iconNameForCellType:CellTypeDone]];
    [cell setThirdIconName:iconString(@"actionDelete")];
    //cell.activatedDirection = MCSwipeTableViewCellActivatedDirectionRight;
    cell.shouldRegret = YES;
    cell.mode = MCSwipeTableViewCellModeExit;
    cell.bounceAmplitude = 0;
    [cell setAddMode:NO];
    /*if(indexPath.row == 0) [cell setAddMode:YES animated:NO];
    else*/
}





-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    self.dragableTop = nil;
    self.tableView = nil;
}
@end
