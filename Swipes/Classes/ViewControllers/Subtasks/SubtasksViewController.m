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

#define kExtraDragable 10
#define kNotificationHeight 18
#define kNotificationFont KP_REGULAR(13)
@interface SubtasksViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *titles;
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
        self.dragableTop.layer.borderColor = gray(217, 1).CGColor;
        self.dragableTop.layer.borderWidth = 1;
        [self.dragableTop addSubview:dragIcon];
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
        
        [self.view addSubview:self.tableView];
        
    }
    return self;
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
    }
	return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(SubtaskCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setTitle:[self.titles objectAtIndex:indexPath.row]];
    if(indexPath.row == 0) [cell setAddMode:YES animated:NO];
    else [cell setAddMode:NO animated:NO];
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
