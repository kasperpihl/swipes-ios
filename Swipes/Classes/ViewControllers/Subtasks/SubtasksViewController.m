//
//  SubtasksViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 21/02/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "SubtasksViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SubtaskCell.h"
#import "StyleHandler.h"
#import "AKSegmentedControl.h"
#import "SlowHighlightIcon.h"
#define kExtraDragable 10
#
#define kNotificationHeight 18
#define kNotificationFont KP_REGULAR(13)

#define SEGMENT_BUTTON_WIDTH 52
#define INTERESTED_SEGMENT_RECT CGRectMake(0,0,(2*SEGMENT_BUTTON_WIDTH)+(8*SEPERATOR_WIDTH),kDragableHeight-kExtraDragable)

@interface SubtasksViewController () <UITableViewDataSource,UITableViewDelegate,SubtaskCellDelegate,MCSwipeTableViewCellDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *titles;
@property (nonatomic) BOOL isMenu;
@property (nonatomic) UIImageView *dragIcon;
@property (nonatomic) AKSegmentedControl *segmentedControl;
@end

@implementation SubtasksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}
-(id)init{
    self = [super init];
    if(self){
        self.titles = @[@"Do laundy for tonight",@"Test the newest version",@"Execute on the side"];
        self.view.backgroundColor = tcolor(BackgroundColor);
        self.dragableTop = [[UIView alloc] initWithFrame:CGRectMake(-1, 0, 322, kDragableHeight-kExtraDragable)];
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
        UIButton *buttonSchedule = [self buttonForSegment:KPSegmentButtonSchedule];
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
        CGRectSetCenterX(self.notification, CGRectGetMaxX(dragIcon.frame));
        CGRectSetCenterY(self.notification, CGRectGetMinY(dragIcon.frame));
        
        [self.view addSubview:self.dragableTop];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.dragableTop.frame), 320, self.view.frame.size.height-CGRectGetMaxY(self.dragableTop.frame)) style:UITableViewStylePlain];
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.delegate = self;
        UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        SubtaskCell *addCell = [[SubtaskCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SubtaskTitleHeader"];
        addCell.subtaskDelegate = self;
        CGRectSetSize(addCell,320,50);
        [addCell setAddMode:YES animated:NO];
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
    NSString *imageString;
    NSString *baseString;
    switch (controlButton) {
        case KPSegmentButtonSchedule:
            baseString = @"schedule";
            
            break;
        case KPSegmentButtonToday:
            baseString = @"today";
            break;
        case KPSegmentButtonDone:
            baseString = @"done";
            break;
    }
    imageString = timageString(baseString, @"-white", @"-black");
    UIImage *normalImage = [UIImage imageNamed:imageString];
    UIImage *selectedImage = [UIImage imageNamed:[imageString stringByAppendingString:@"-high"]];
    UIImage *highlightedImage = [UIImage imageNamed:[baseString stringByAppendingString:@"-highlighted"]];;
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateSelected];
    [button setImage:highlightedImage forState:UIControlStateSelected | UIControlStateHighlighted];
    [button setImage:selectedImage forState:UIControlStateHighlighted];
    button.imageView.animationImages = @[highlightedImage];
    button.imageView.animationDuration = 0.8;
    return button;
}
-(void)addedSubtask:(NSString *)subtask{
    self.titles = [@[subtask] arrayByAddingObjectsFromArray:self.titles];
    [self animateInAddTask];
}

-(void)switchToMenu:(BOOL)menu animated:(BOOL)animated{
    CGFloat duration = 0.25;
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
            self.notification.alpha = 0;
        }
    };
    voidBlock hideBlock = ^{
        if(menu){
            self.dragIcon.alpha = 0;
            self.notification.alpha = 0;
        }
        else self.segmentedControl.alpha = 0;
    };
    voidBlock showBlock = ^{
        self.notification.alpha = 1;
        if(!menu) self.dragIcon.alpha = 1;
        else self.segmentedControl.alpha = 1;
    };
    preBlock();
    [UIView animateWithDuration:duration animations:^{
        hideBlock();
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            showBlock();
        }];
    }];
}


-(void)startedSliding{
    [self switchToMenu:NO animated:YES];
}
-(void)willStartOpening:(BOOL)opening{
    if(opening){
        [self switchToMenu:YES animated:YES];
    }
}
-(void)finishedOpening:(BOOL)opened{
    if(opened){
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(animateInAddTask) userInfo:nil repeats:NO];
    }
    else{
        self.tableView.contentOffset = CGPointMake(0,self.tableView.tableHeaderView.frame.size.height);
    }
}
-(void)reload{
    [self.tableView reloadData];
    self.notification.text = [NSString stringWithFormat:@"%i",self.titles.count];
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
        NSMutableArray *mutCopy = [self.titles mutableCopy];
        [mutCopy removeObjectAtIndex:indexPath.row];
        self.titles = [mutCopy copy];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        self.notification.text = [NSString stringWithFormat:@"%i",self.titles.count];
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
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titles.count;
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
    [cell setTitle:[self.titles objectAtIndex:indexPath.row]];
    [cell setFirstColor:[StyleHandler colorForCellType:CellTypeDone]];
    [cell setThirdColor:[UIColor redColor]];
    [cell setFirstIconName:[StyleHandler iconNameForCellType:CellTypeDone]];
    [cell setThirdIconName:@"trashcan_icon_white-high"];
    //cell.activatedDirection = MCSwipeTableViewCellActivatedDirectionRight;
    cell.shouldRegret = YES;
    cell.mode = MCSwipeTableViewCellModeExit;
    cell.bounceAmplitude = 0;
    [cell setAddMode:NO animated:NO];
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
