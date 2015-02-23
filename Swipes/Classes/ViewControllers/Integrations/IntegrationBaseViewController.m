//
//  IntegrationBaseViewController.m
//  Swipes
//
//  Created by demosten on 2/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "IntegrationSettingCell.h"
#import "IntegrationSeparatorCell.h"
#import "IntegrationBaseViewController.h"

NSString* const kKeyTitle = @"title";
NSString* const kKeySubtitle = @"subtitle";
NSString* const kKeyIcon = @"icon";
NSString* const kKeyIsOn = @"isOn";
NSString* const kKeyCellType = @"cellType";
NSString* const kKeyTouchSelector = @"touchSelector";

static CGFloat const kTopMargin = 50;
static CGFloat const kBottomMargin = 50;
static CGFloat const kCellHeight = 60;
static CGFloat const kSeparatorHeight = 40;

@interface IntegrationBaseViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) BOOL hasLeadingIcons;

@end

@implementation IntegrationBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = tcolor(BackgroundColor);
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += kTopMargin;
    viewFrame.size.height -= kTopMargin + kBottomMargin;
    self.table = [[UITableView alloc] initWithFrame:viewFrame];
    self.table.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.table.backgroundColor = [UIColor clearColor];
    self.table.rowHeight = kCellHeight;
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
    
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - kBottomMargin, kBottomMargin, kBottomMargin)];
    self.backButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.backButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
    self.backButton.titleLabel.font = iconFont(23);
    [self.backButton setTitle:iconString(@"back") forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(pressedBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pressedBack:(id)sender {
    [self removeFromParentViewController];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    _hasLeadingIcons = NO;
    return _cellInfo.count;
}

- (IntegrationSettingsStyle)styleForData:(NSDictionary *)data
{
    IntegrationSettingsStyle result = IntegrationSettingsStyleDefaultMask;
    if (_hasLeadingIcons || [data objectForKey:kKeyIcon]) {
        result |= IntegrationSettingsStyleIcon;
        _hasLeadingIcons = YES; // we have at least one with icon
    }
    if ([data objectForKey:kKeySubtitle]) {
        result |= IntegrationSettingsStyleSubtitle;
    }
    if ([data objectForKey:kKeyCellType]) {
        result |= IntegrationSettingsStyleState;
    }
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* data = _cellInfo[indexPath.row];

    static NSString *kCellSettingsID =@"settings_cell";
    static NSString *kCellSeparatorID =@"separator_cell";
    
    NSNumber* cellType = data[kKeyCellType];
    if (cellType && [cellType unsignedIntegerValue] == kIntegrationCellTypeSeparator) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellSeparatorID];
        if (nil == cell) {
            cell = [[IntegrationSeparatorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellSeparatorID];
        }
        return cell;
    }
    
    IntegrationSettingCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellSettingsID];
    if (nil == cell) {
        cell = [[IntegrationSettingCell alloc] initWithCustomStyle:[self styleForData:data] reuseIdentifier:kCellSettingsID];
    }
    
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:IntegrationSeparatorCell.class]) {
        return kSeparatorHeight;
    }
    return kCellHeight;
}

@end
