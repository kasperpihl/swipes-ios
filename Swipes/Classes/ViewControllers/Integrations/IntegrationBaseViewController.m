//
//  IntegrationBaseViewController.m
//  Swipes
//
//  Created by demosten on 2/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "KPTopClock.h"
#import "IntegrationSettingCell.h"
#import "IntegrationSeparatorCell.h"
#import "IntegrationSectionCell.h"
#import "IntegrationTextFieldCell.h"
#import "IntegrationTitleView.h"
#import "IntegrationBaseViewController.h"

NSString* const kKeyTitle = @"title";
NSString* const kKeySubtitle = @"subtitle";
NSString* const kKeyIcon = @"icon";
NSString* const kKeyIsOn = @"isOn";
NSString* const kKeyCellType = @"cellType";
NSString* const kKeyTextType = @"textType";
NSString* const kKeyText = @"text";
NSString* const kKeyTouchSelector = @"touchSelector";

UIColor* kIntegrationGreenColor;

static CGFloat const kTopMargin = 60;
static CGFloat const kBottomMargin = 45;
static CGFloat const kCellHeight = 55;
static CGFloat const kSeparatorHeight = 22;
static CGFloat const kSectionHeight = 34;
static CGFloat const kTextFieldHeight = 72;

@interface IntegrationBaseViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IntegrationTitleView* titleView;

@end

@implementation IntegrationBaseViewController

+ (void)initialize
{
    kIntegrationGreenColor = color(139, 195, 74, 1);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = tcolor(BackgroundColor);
    
    // setup top view
    _titleView = [[IntegrationTitleView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kTopMargin)];
    _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_titleView];

    // setup table view
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
    
    // setup back button
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - kBottomMargin, kBottomMargin, kBottomMargin - 15)];
    self.backButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.backButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
    self.backButton.titleLabel.font = iconFont(23);
    [self.backButton setTitle:iconString(@"back") forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(pressedBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    
    [self tableView:_table numberOfRowsInSection:10];
}

- (void)recreateCellInfo
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self recreateCellInfo];
    [self reloadData];
    [kTopClock pushClockToView:self.view];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [kTopClock popClock];
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    _titleView.title = title;
}

- (void)setLightColor:(UIColor *)lightColor
{
    _lightColor = lightColor;
    _titleView.lightColor = lightColor;
}

-(void)addModalTransition
{
    CATransition* transition = [CATransition animation];
    
    transition.duration = 0.15;
    transition.type = kCATransitionFade;
    
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack
{
    [self addModalTransition];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)pressedBack:(id)sender
{
    [self goBack];
}

- (IntegrationSettingsStyle)styleForData:(NSDictionary *)data
{
    IntegrationSettingsStyle result = IntegrationSettingsStyleDefaultMask;
    if ([data objectForKey:kKeyIcon]) {
        result |= IntegrationSettingsStyleIcon;
    }
    if ([data objectForKey:kKeySubtitle]) {
        result |= IntegrationSettingsStyleSubtitle;
    }
    if ([data objectForKey:kKeyCellType]) {
        result |= IntegrationSettingsStyleState;
    }
    return result;
}

- (void)reloadData
{
    [_table reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cellInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellSettingsID = @"settings_cell";
    static NSString *kCellSeparatorID = @"separator_cell";
    static NSString *kCellSectionID = @"section_cell";
    static NSString *kCellTextFieldID = @"textfield_cell";
    
    NSDictionary* data = _cellInfo[indexPath.row];
    NSNumber* cellType = data[kKeyCellType];
    if (cellType && [cellType unsignedIntegerValue] == kIntegrationCellTypeSeparator) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellSeparatorID];
        if (nil == cell) {
            cell = [[IntegrationSeparatorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellSeparatorID];
        }
        return cell;
    }
    else if (cellType && [cellType unsignedIntegerValue] == kIntegrationCellTypeSection) {
        IntegrationSectionCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellSectionID];
        if (nil == cell) {
            cell = [[IntegrationSectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellSectionID];
            cell.title = data[kKeyTitle];
        }
        return cell;
    }
    else if (cellType && [cellType unsignedIntegerValue] == kIntegrationCellTypeTextField) {
        IntegrationTextFieldCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellTextFieldID];
        if (nil == cell) {
            cell = [[IntegrationTextFieldCell alloc] initWithCustomStyle:[data[kKeyTextType] unsignedIntegerValue] reuseIdentifier:kCellTextFieldID mandatory:[data[kKeyIsOn] boolValue]];
            cell.title = data[kKeyTitle];
            cell.textField.text = data[kKeyText];
        }
        return cell;
    }
    
    IntegrationSettingCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellSettingsID];
    IntegrationSettingsStyle style = [self styleForData:data];
    if (nil == cell) {
        cell = [[IntegrationSettingCell alloc] initWithCustomStyle:style reuseIdentifier:kCellSettingsID];
    }
    else {
        cell.customStyle = style;
    }
    
    cell.titleLabel.text = data[kKeyTitle];
    cell.subtitleLabel.text = data[kKeySubtitle];
    cell.iconLabel.text = data[kKeyIcon];
    cell.statusLabel.text = nil;
    
    if (cellType) {
        switch ([cellType unsignedIntegerValue]) {
            case kIntegrationCellTypeViewMore:
                cell.statusLabel.text = iconString(@"arrowRightThick");
                break;
                
            case kIntegrationCellTypeCheck: {
                    BOOL isOn = data[kKeyIsOn] ? [data[kKeyIsOn] boolValue] : NO;
                    if (isOn) {
                        cell.statusLabel.text = iconString(@"actionIndicatorOn");
                        cell.statusLabel.textColor = kIntegrationGreenColor;
                    }
                    else {
                        cell.statusLabel.text = iconString(@"actionIndicatorOff");
                        cell.statusLabel.textColor = tcolor(TextColor);
                    }
                }
                break;
                
            case kIntegrationCellTypeStatus: {
                    BOOL isOn = data[kKeyIsOn] ? [data[kKeyIsOn] boolValue] : NO;
                    cell.statusLabel.text = iconString(@"indicator");
                    if (isOn) {
                        cell.statusLabel.textColor = kIntegrationGreenColor;
                    }
                    else {
                        cell.statusLabel.textColor = tcolor(SubTextColor);
                    }
                }
                break;

        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* data = _cellInfo[indexPath.row];
    NSNumber* cellType = data[kKeyCellType];
    if (cellType && [cellType unsignedIntegerValue] == kIntegrationCellTypeSeparator) {
        return kSeparatorHeight;
    }
    else if (cellType && [cellType unsignedIntegerValue] == kIntegrationCellTypeSection) {
        return kSectionHeight;
    }
    else if (cellType && [cellType unsignedIntegerValue] == kIntegrationCellTypeTextField) {
        return kTextFieldHeight;
    }
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* data = _cellInfo[indexPath.row];
    NSString* strSel = data[kKeyTouchSelector];
    if (strSel) {
        SEL sel = NSSelectorFromString(strSel);
        ((void (*)(id, SEL))[self methodForSelector:sel])(self, sel); // [self performSelector:sel];
        if (_cellInfo.count > indexPath.row)
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
    }
}

@end
