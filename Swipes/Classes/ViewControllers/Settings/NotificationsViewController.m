//
//  NotificationsViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 31/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#define kLocalCellHeight 55
#define kSwitchTag 13

#import "UIView+Utilities.h"
#import "UtilityClass.h"
#import "SettingsHandler.h"
#import "NotificationsViewController.h"

@interface NotificationsViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation NotificationsViewController

-(KPSettings)settingForIndexPath:(NSIndexPath*)indexPath{
    KPSettings setting = SettingNotifications;
    switch (indexPath.row) {
        case 0:
            setting = SettingNotifications;
            break;
        case 1:
            setting = SettingDailyReminders;
            break;
        case 2:
            setting = SettingWeeklyReminders;
            break;
        default:
            break;
    }
    return setting;
}
-(NSString*)titleForIndexPath:(NSIndexPath *)indexPath{
    NSString *title;
    switch (indexPath.row) {
        case 0:
            title = @"Tasks snoozed for later";
            break;
        case 1:
            title = @"Daily reminder to plan the day";
            break;
        case 2:
            title = @"Weekly reminder to plan the week";
            break;
        default:
            break;
    }
    return title;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"SwitchCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if ( cell == nil ){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.contentView.backgroundColor = CLEAR;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = CLEAR;
        cell.textLabel.font = KP_REGULAR(14);
            
        UISwitch *aSwitch = [[UISwitch alloc] init];
        aSwitch.tag = kSwitchTag;
        aSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        CGRectSetCenter(aSwitch, cell.frame.size.width-aSwitch.frame.size.width + 5, kLocalCellHeight/2);
        [aSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        
        [cell.contentView addSubview:aSwitch];
    }
	return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    KPSettings setting = [self settingForIndexPath:indexPath];
    BOOL settingIsOn = [[kSettings valueForSetting:setting] boolValue];
    NSString *title = [self titleForIndexPath:indexPath];
    cell.textLabel.textColor = tcolor(TextColor);
    
    UISwitch *aSwitch = (UISwitch*)[cell viewWithTag:kSwitchTag];
    cell.textLabel.text = title;
    aSwitch.on = settingIsOn;
}

-(void)switchChanged:(UISwitch*)sender{
    UITableViewCell *cell = (UITableViewCell*)[sender firstSuperviewOfClass:[UITableViewCell class]];
    NSIndexPath *switchHandled = [self.tableView indexPathForCell:cell];
    KPSettings setting = [self settingForIndexPath:switchHandled];
    if(sender.on){
        [kSettings setValue:@YES forSetting:setting];
    }
    else{
        [UTILITY confirmBoxWithTitle:[self titleForIndexPath:switchHandled] andMessage:@"Are you sure you no longer want to receive these alarms and reminders?" block:^(BOOL succeeded, NSError *error) {
            if(succeeded)
                [kSettings setValue:@NO forSetting:setting];
            else
                sender.on = YES;
        }];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = CLEAR;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.rowHeight = kLocalCellHeight;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //[self.tableView setSeparatorColor:tcolor(TextColor)];
    [self.tableView setTableFooterView:[UIView new]];
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    [self.tableView removeFromSuperview];
    self.tableView = nil;
}

@end
