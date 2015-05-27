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
#import "IntegrationButtonCell.h"
#import "ProfileImageCell.h"
#import "IntegrationBaseViewController.h"

NSString* const kKeyTitle = @"title";
NSString* const kKeySubtitle = @"subtitle";
NSString* const kKeyIcon = @"icon";
NSString* const kKeyIsOn = @"isOn";
NSString* const kKeyCellType = @"cellType";
NSString* const kKeyTextType = @"textType";
NSString* const kKeyText = @"text";
NSString* const kKeyPlaceholder = @"placeholder";
NSString* const kKeyTouchSelector = @"touchSelector";

UIColor* kIntegrationGreenColor;

static CGFloat const kTopMargin = 60;
static CGFloat const kBottomMargin = 45;
static CGFloat const kCellHeight = 55;
static CGFloat const kSeparatorHeight = 22;
static CGFloat const kSectionHeight = 34;
static CGFloat const kTextFieldHeight = 72;
static CGFloat const kProfilePictureHeight = 130;

@interface IntegrationBaseViewController () <UITableViewDelegate, UITableViewDataSource, IntegrationTextFieldCellDelegate>

@property (nonatomic, strong) IntegrationTitleView* titleView;
@property (nonatomic, assign) NSInteger focusedItem;

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
    self.table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
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
    
    if (UIUserInterfaceIdiomPhone == [UIDevice currentDevice].userInterfaceIdiom) {
        notify(UIKeyboardWillShowNotification, keyboardWillShow:);
        notify(UIKeyboardWillHideNotification, keyboardWillHide:);
    }
}

- (void)dealloc
{
    clearNotify();
}

- (void)recreateCellInfo
{
    _focusedItem = -1;
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

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up
{
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = self.view.frame;
    newFrame.origin.y = kTopMargin;
    if (up)
        newFrame.size.height = keyboardEndFrame.origin.y - kTopMargin;
    else
        newFrame.size.height -= kTopMargin + kBottomMargin;
    
    _table.frame = newFrame;
    
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self moveTextViewForKeyboard:notification up:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self moveTextViewForKeyboard:notification up:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return NO;
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

- (void)reloadRow:(NSUInteger)row
{
    [_table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cellInfo.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _focusedItem) {
        NSDictionary* data = _cellInfo[indexPath.row];
        NSNumber* cellType = data[kKeyCellType];
        if (cellType && [cellType unsignedIntegerValue] == kIntegrationCellTypeTextField) {
            IntegrationTextFieldCell* inputCell = (IntegrationTextFieldCell *)cell;
            if (![inputCell.textField isFirstResponder]) {
                [inputCell.textField becomeFirstResponder];
                [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellSettingsID = @"settings_cell";
    static NSString *kCellSeparatorID = @"separator_cell";
    static NSString *kCellSectionID = @"section_cell";
    static NSString *kCellTextFieldID = @"textfield_cell";
    static NSString *kCellButtonID = @"button_cell";
    static NSString *kCellProfilePictureID = @"profile_picture_cell";
    
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
        }
        cell.title = data[kKeyTitle];
        return cell;
    }
    else if (cellType && [cellType unsignedIntegerValue] == kIntegrationCellTypeTextField) {
        IntegrationTextFieldCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellTextFieldID];
        if (nil == cell) {
            cell = [[IntegrationTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellTextFieldID];
        }
        cell.mandatory = [data[kKeyIsOn] boolValue];
        cell.customStyle = [data[kKeyTextType] unsignedIntegerValue];
        cell.title = data[kKeyTitle];
        cell.textField.text = data[kKeyText];
        cell.textField.placeholder = data[kKeyPlaceholder];
        cell.delegate = self;
        return cell;
    }
    else if (cellType && [cellType unsignedIntegerValue] == kIntegrationCellTypeButton) {
        IntegrationButtonCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellButtonID];
        if (nil == cell) {
            cell = [[IntegrationButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellButtonID];
        }
        cell.title = data[kKeyTitle];
        return cell;
    }
    else if (cellType && [cellType unsignedIntegerValue] == kIntegrationCellTypeProfilePicture) {
        ProfileImageCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellProfilePictureID];
        if (nil == cell) {
            cell = [[ProfileImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellProfilePictureID];
        }
        cell.image = data[kKeyIcon];
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
    else if (cellType && [cellType unsignedIntegerValue] == kIntegrationCellTypeProfilePicture) {
        return kProfilePictureHeight;
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

- (BOOL)textFieldCellShouldReturn:(IntegrationTextFieldCell *)cell
{
    NSIndexPath* indexPath = [_table indexPathForCell:cell];
    if (indexPath) {
        // find if there is a next focusable cell
        BOOL hasNext = NO;
        for (NSUInteger i = indexPath.row + 1; i < _cellInfo.count; i++) {
            NSDictionary* data = _cellInfo[i];
            NSNumber* cellType = data[kKeyCellType];
            if (cellType && [cellType unsignedIntegerValue] == kIntegrationCellTypeTextField) {
                IntegrationTextFieldCell* newCell = (IntegrationTextFieldCell *)[_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                if (newCell) {
                    [newCell.textField becomeFirstResponder];
                }
                hasNext = YES;
                [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                _focusedItem = i;
                break;
            }
        }
        if (!hasNext) {
            [cell.textField resignFirstResponder];
            _focusedItem = -1;
        }
    }
    return NO;
}

- (void)textFieldCellDidBeginEditing:(IntegrationTextFieldCell *)cell
{
    NSIndexPath* indexPath = [_table indexPathForCell:cell];
    if (indexPath) {
        [_table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        _focusedItem = indexPath.row;
    }
}

- (void)textFieldCellDidEndEditing:(IntegrationTextFieldCell *)cell
{
    [self textFieldCellDidChange:cell];
}

- (void)textFieldCellDidChange:(IntegrationTextFieldCell *)cell
{
    NSIndexPath* indexPath = [_table indexPathForCell:cell];
    if (indexPath) {
        _cellInfo[indexPath.row][kKeyText] = cell.textField.text;
    }
}

@end
