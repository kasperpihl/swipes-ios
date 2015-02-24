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

static CGFloat const kTopMargin = 60;
static CGFloat const kBottomMargin = 45;
static CGFloat const kCellHeight = 50;
static CGFloat const kSeparatorHeight = 22;
static CGFloat const kLineMarginX = 26;
static CGFloat const kLineMarginY = kTopMargin - 10;

@interface IntegrationBaseViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView* lineView;

@end

@implementation IntegrationBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = tcolor(BackgroundColor);
    
    // setup top view
    _lightColor = [UIColor greenColor]; // TODO fix the color

    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLineMarginX, 20, self.view.frame.size.width - kLineMarginX * 2, 25)];
    //_titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_titleLabel];
    [self updateTitle];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(kLineMarginX, kLineMarginY, self.view.frame.size.width - kLineMarginX * 2, 1.5)];
    _lineView.backgroundColor = tcolor(TextColor);
    _lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_lineView];
    
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
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - kBottomMargin, kBottomMargin, kBottomMargin)];
    self.backButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.backButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
    self.backButton.titleLabel.font = iconFont(15);
    [self.backButton setTitle:iconString(@"back") forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(pressedBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    if (_titleLabel) {
        [self updateTitle];
    }
}

- (void)setLightColor:(UIColor *)lightColor
{
    _lightColor = lightColor;
    if (_titleLabel) {
        [self updateTitle];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pressedBack:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)updateTitle
{
    // Create the attributed string
    NSMutableAttributedString *myString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"\ue613 %@ \ue613", self.title]];
    
    // Declare the fonts
    UIFont *fontIcon = iconFont(10);
    UIFont *fontTitle = KP_SEMIBOLD(10);
    
    NSRange rangeFirst = NSMakeRange(0,1);
    NSRange rangeLast = NSMakeRange(myString.length - 1, 1);
    NSRange rangeTitle = NSMakeRange(1, myString.length - 2);
    
    // Declare the paragraph styles
    NSMutableParagraphStyle *myStringParaStyle1 = [[NSMutableParagraphStyle alloc] init];
    myStringParaStyle1.alignment = 1;
    
    // Create the attributes and add them to the string
    [myString addAttribute:NSForegroundColorAttributeName value:_lightColor range:rangeFirst];
    [myString addAttribute:NSParagraphStyleAttributeName value:myStringParaStyle1 range:rangeFirst];
    [myString addAttribute:NSFontAttributeName value:fontIcon range:rangeFirst];
    
    [myString addAttribute:NSFontAttributeName value:fontTitle range:rangeTitle];
    [myString addAttribute:NSParagraphStyleAttributeName value:myStringParaStyle1 range:rangeTitle];
    [myString addAttribute:NSForegroundColorAttributeName value:tcolor(TextColor) range:rangeTitle];
    
    [myString addAttribute:NSForegroundColorAttributeName value:_lightColor range:rangeLast];
    [myString addAttribute:NSParagraphStyleAttributeName value:myStringParaStyle1 range:rangeLast];
    [myString addAttribute:NSFontAttributeName value:fontIcon range:rangeLast];
    
    self.titleLabel.attributedText = [[NSAttributedString alloc]initWithAttributedString: myString];
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

- (NSString *)stringForCellType:(NSUInteger)cellType
{
    switch (cellType) {
        case kIntegrationCellTypeViewMore:
            return iconString(@"arrowThick");
            
        case kIntegrationCellTypeCheck:
            return iconString(@"arrowThick");
    }
    return nil;
}

- (void)reloadData
{
    [_table reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* data = _cellInfo[indexPath.row];

    static NSString *kCellSettingsID = @"settings_cell";
    static NSString *kCellSeparatorID = @"separator_cell";
    
    NSNumber* cellType = data[kKeyCellType];
    if (cellType && [cellType unsignedIntegerValue] == kIntegrationCellTypeSeparator) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellSeparatorID];
        if (nil == cell) {
            cell = [[IntegrationSeparatorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellSeparatorID];
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
                cell.statusLabel.text = iconString(@"arrowThick");
                break;
                
            case kIntegrationCellTypeCheck: {
                    BOOL isOn = data[kKeyIsOn] ? [data[kKeyIsOn] boolValue] : NO;
                    if (isOn) {
                        cell.statusLabel.text = iconString(@"roundAdd");
                        cell.statusLabel.textColor = [UIColor greenColor]; // TODO fix color
                    }
                    else {
                        cell.statusLabel.text = iconString(@"roundClose");
                        cell.statusLabel.textColor = tcolor(TextColor); // TODO fix color
                    }
                }
                break;
        }
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
