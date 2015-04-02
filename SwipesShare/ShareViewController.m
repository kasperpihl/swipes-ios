//
//  ShareViewController.m
//  SwipesShare
//
//  Created by demosten on 3/12/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

@import MobileCoreServices;
#import "Includes.h"
#import "Global.h"
#import <Parse/Parse.h>
#import "KPToDo.h"
#import "KPAttachment.h"
#import "KPTag.h"
#import "UITextView+Placeholder.h"
#import "TagsViewController.h"
#import "ScheduleViewController.h"
#import "ShareViewController.h"

static const NSUInteger kTagsIndex = 0;
static const NSUInteger kScheduleIndex = 1;
static const CGFloat kMargin = 20.f;
static const CGFloat kTopMargin = 35.f;
static NSString* const kKeyUserSettingsName = @"ShareExtensionTags";
static NSString* const kKeyUserSettingsNameURL = @"ShareExtensionTagsURL";

@interface ShareViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIView* contentView;
@property (nonatomic, weak) IBOutlet UITextField* textField;
@property (nonatomic, weak) IBOutlet UIButton* cancelButton;
@property (nonatomic, weak) IBOutlet UIButton* backButton;
@property (nonatomic, weak) IBOutlet UIButton* postButton;
@property (nonatomic, weak) IBOutlet UITextView* notesTextView;
@property (nonatomic, weak) IBOutlet UITableView* optionsTable;
@property (nonatomic, weak) IBOutlet UIView* tagsContainer;
@property (nonatomic, weak) IBOutlet UIView* scheduleContainer;

@property (nonatomic, weak) TagsViewController* tagsVC;

@property (nonatomic, strong) NSURL* url;

@end

@implementation ShareViewController {
    BOOL _readTags;
    BOOL _readSchedule;
    NSArray* _selectedTags;
}

+ (void)initialize
{
    [Parse setApplicationId:@"nf9lMphPOh3jZivxqQaMAg6YLtzlfvRjExUEKST3"
                  clientKey:@"SrkvKzFm51nbKZ3hzuwnFxPPz24I9erkjvkf0XzS"];
    [Global initCoreData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString* keyTags = kKeyUserSettingsName;
    
    NSExtensionItem* item = [self.extensionContext.inputItems.firstObject copy];
    NSString* fullText = item.attributedContentText.string;
    NSRange firstNewLine = [fullText rangeOfString:@"\n"];
    if (firstNewLine.location != NSNotFound) {
        _notesTextView.text = fullText;
        fullText = [self firstNonEmptyLine:fullText];
    }
    
    self.textField.text = fullText;
    NSItemProvider* attachment = [item.attachments.firstObject copy];
    if ([attachment hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
        [attachment loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
            NSObject* itm = (NSObject *)item;
            if ([itm isKindOfClass:NSURL.class]) {
                self.url = (NSURL *)itm;
            }
        }];
        keyTags = kKeyUserSettingsNameURL;
    }
    
    NSArray* selectedTags = [USER_DEFAULTS objectForKey:keyTags];
    if (selectedTags && [selectedTags isKindOfClass:NSArray.class] && (0 < selectedTags.count)) {
        // clear non existing tags
        NSMutableArray* selectedMutable = [selectedTags mutableCopy];
        NSArray* tags = [KPTag allTagsAsStrings];
        for (NSString* tag in selectedTags) {
            if (![tags containsObject:tag]) {
                [selectedMutable removeObject:tag];
            }
        }
        _selectedTags = [selectedMutable copy];
    }
    
    _notesTextView.placeholderColor = [UIColor lightGrayColor];
    _notesTextView.placeholder = LOCALIZE_STRING(@"Enter task's notes");
    
    notify(UIKeyboardWillShowNotification, keyboardWillShow:);
    notify(UIKeyboardWillHideNotification, keyboardWillHide:);
    
    [self.textField becomeFirstResponder];
}

- (void)dealloc
{
    clearNotify();
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (UIUserInterfaceIdiomPhone == [UIDevice currentDevice].userInterfaceIdiom) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (IBAction)didSelectPost:(id)sender
{
    NSString* text = self.textField.text;
    if (0 < text.length) {
        [self createTodo];
        [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
    }
}

- (IBAction)onCancel:(id)sender
{
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (IBAction)onBack:(id)sender
{
    [self hideView];
    
    if (_readTags) {
        if (_tagsVC) {
            _selectedTags = [_tagsVC.tagList getSelectedTags];
            [_optionsTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kTagsIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        _readTags = NO;
    }
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
    newFrame.origin.x = kMargin;
    newFrame.origin.y = kTopMargin;
    newFrame.size.width -= kMargin * 2;
    if (up)
        newFrame.size.height = keyboardEndFrame.origin.y - kMargin - kTopMargin;
    else
        newFrame.size.height -= kMargin + kTopMargin;
    
    _contentView.frame = newFrame;
    
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
    [self didSelectPost:nil];
    return NO;
}

- (void)createTodo
{
    KPToDo* todo = [KPToDo addItem:_textField.text priority:NO tags:_selectedTags save:YES from:@"Share Extension"];
    if (_notesTextView.text.length) {
        [todo setNotes:_notesTextView.text];
    }
    NSString* keyTags = kKeyUserSettingsName;
    if (_url) {
        KPAttachment* attachment = [KPAttachment attachmentForService:URL_SERVICE title:[_url absoluteString] identifier:[_url absoluteString] sync:YES];
        [todo addAttachmentsObject:attachment];
        keyTags = kKeyUserSettingsNameURL;
    }
    [KPToDo saveToSync];
    
    [USER_DEFAULTS setObject:_selectedTags ? _selectedTags : @[] forKey:keyTags];
    [USER_DEFAULTS synchronize];
}

- (void)setupTagsLabel:(UILabel *)label
{
    if (!_selectedTags || (0 == _selectedTags.count)) {
        label.text = @"Tags";
    }
    else {
        NSMutableString* tags = [NSMutableString string];
        for (NSUInteger i = 0; i < _selectedTags.count; i++) {
            if (0 < i) {
                [tags appendString:@", "];
            }
            [tags appendString:_selectedTags[i]];
        }
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"editTags %@", tags]];
        [attrString addAttribute:NSFontAttributeName value:iconFont(10) range:NSMakeRange(0, 8)];
        
        label.attributedText = attrString;
    }
}

- (void)setupScheduleLabel:(UILabel *)label
{
    label.text = @"Schedule";
}

- (void)hideView
{
    _tagsContainer.hidden = YES;
    _scheduleContainer.hidden = YES;
    _cancelButton.hidden = NO;
    _backButton.hidden = YES;
}

- (void)displayView:(UIView *)view
{
    view.hidden = NO;
    _cancelButton.hidden = YES;
    _backButton.hidden = NO;
}

- (NSString *)firstNonEmptyLine:(NSString *)string
{
    NSArray* lines = [string componentsSeparatedByString:@"\n"];
    for (NSString* line in lines) {
        NSString* finalLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (0 < finalLine.length) {
            return [finalLine copy];
        }
    }
    return @"";
}

- (void)addCellDisclosure:(UITableViewCell *)cell
{
    UILabel* disclosureLabel = [[UILabel alloc] init];
    disclosureLabel.backgroundColor = [UIColor clearColor];
    disclosureLabel.textColor = tcolorF(TextColor, ThemeLight);
    disclosureLabel.font = iconFont(6);
    disclosureLabel.text = @"arrowRightThick";
    [disclosureLabel sizeToFit];
    cell.accessoryView = disclosureLabel;
}

#pragma mark - table view fills

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellID = @"shareCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
    }
    
    // Remove seperator inset
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setPreservesSuperviewLayoutMargins:NO];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    
    [self addCellDisclosure:cell];
    switch (indexPath.row) {
        case kTagsIndex:
            [self setupTagsLabel:cell.textLabel];
            break;
            
        case kScheduleIndex:
            [self setupScheduleLabel:cell.textLabel];
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_textField resignFirstResponder];
    [_notesTextView resignFirstResponder];
    
    switch (indexPath.row) {
        case kTagsIndex:
            _readTags = YES;
            if (_tagsVC)
                _tagsVC.selectedTags = _selectedTags;
            [self displayView:_tagsContainer];
            break;
            
        case kScheduleIndex:
            [self displayView:_scheduleContainer];
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"tags"]) {
        _tagsVC = segue.destinationViewController;
    }
}

@end
