//
//  ShareViewController.m
//  SwipesShare
//
//  Created by demosten on 3/12/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

@import MobileCoreServices;
#import <Parse/Parse.h>
#import "KPToDo.h"
#import "KPAttachment.h"
#import "KPTag.h"
#import "TagsViewController.h"
#import "ShareViewController.h"

const NSUInteger kTagsIndex = 0;
const NSUInteger kScheduleIndex = 1;

@interface ShareViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITextField* textField;
@property (nonatomic, weak) IBOutlet UIButton* cancelButton;
@property (nonatomic, weak) IBOutlet UIButton* backButton;
@property (nonatomic, weak) IBOutlet UIButton* postButton;
@property (nonatomic, weak) IBOutlet UITextView* notesTextView;
@property (nonatomic, weak) IBOutlet UITableView* optionsTable;
@property (nonatomic, weak) IBOutlet UIView* tagsContainer;

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
    
    [self.textField becomeFirstResponder];
    
    NSExtensionItem* item = [self.extensionContext.inputItems.firstObject copy];
    self.textField.text = item.attributedContentText.string;
    NSItemProvider* attachment = [item.attachments.firstObject copy];
    if ([attachment hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
        [attachment loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
            NSObject* itm = (NSObject *)item;
            if ([itm isKindOfClass:NSURL.class]) {
                self.url = (NSURL *)itm;
            }
        }];
    }
}

- (IBAction)didSelectPost:(id)sender
{
    NSString* text = self.textField.text;
    if (0 < text.length) {
        [self createTodoWithText:text];
        [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
    }
}

- (IBAction)onCancel:(id)sender
{
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (IBAction)onBack:(id)sender
{
    _tagsContainer.hidden = YES;
    _cancelButton.hidden = NO;
    _backButton.hidden = YES;
    
    if (_readTags) {
        if (_tagsVC) {
            _selectedTags = [_tagsVC.tagList getSelectedTags];
            [_optionsTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kTagsIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        _readTags = NO;
    }
}

- (void)createTodoWithText:(NSString *)text
{
    KPToDo* todo = [KPToDo addItem:text priority:NO tags:_selectedTags save:YES from:@"Share extension"];
    if (_url) {
        KPAttachment* attachment = [KPAttachment attachmentForService:URL_SERVICE title:[_url absoluteString] identifier:[_url absoluteString] sync:YES];
        [todo addAttachmentsObject:attachment];
    }
    [KPToDo saveToSync];
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

- (void)displayView:(UIView *)view
{
    view.hidden = NO;
    _cancelButton.hidden = YES;
    _backButton.hidden = NO;
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
            [self displayView:_tagsContainer];
            break;
            
        case kScheduleIndex:
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
