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
#import "KPTagList.h"
#import "ShareViewController.h"

@interface ShareViewController ()

@property (nonatomic, weak) IBOutlet UITextField* textField;
@property (nonatomic, weak) IBOutlet UILabel* urlText;
@property (nonatomic, weak) IBOutlet UIButton* cancelButton;
@property (nonatomic, weak) IBOutlet UIButton* postButton;
@property (nonatomic, weak) IBOutlet KPTagList* tagList;
@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;

@property (nonatomic, strong) NSURL* url;

@end

@implementation ShareViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [Parse setApplicationId:@"nf9lMphPOh3jZivxqQaMAg6YLtzlfvRjExUEKST3"
                  clientKey:@"SrkvKzFm51nbKZ3hzuwnFxPPz24I9erkjvkf0XzS"];
    [Global initCoreData];

    [self.textField becomeFirstResponder];
    
    self.tagList.sorted = YES;
    self.tagList.addTagButton = NO;
    self.tagList.emptyText = LOCALIZE_STRING(@"No tags");
    self.tagList.tagBackgroundColor = tcolorF(BackgroundColor, ThemeLight);
    self.tagList.tagTitleColor = tcolorF(TextColor, ThemeLight);
    self.tagList.tagBorderColor = tcolorF(TextColor, ThemeLight);
    self.tagList.selectedTagBackgroundColor = tcolorF(BackgroundColor, ThemeDark);
    self.tagList.selectedTagTitleColor = tcolorF(TextColor, ThemeDark);
    self.tagList.selectedTagBorderColor = tcolorF(TextColor, ThemeLight);
    self.tagList.spacing = 2;
    [self.tagList setTags:[KPTag allTagsAsStrings] andSelectedTags:@[]];
    self.scrollView.contentSize = CGSizeMake(self.tagList.frame.size.width, self.tagList.frame.size.height);
    
    NSExtensionItem* item = [self.extensionContext.inputItems.firstObject copy];
    self.textField.text = item.attributedContentText.string;
    NSItemProvider* attachment = [item.attachments.firstObject copy];
    if ([attachment hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
        [attachment loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
            NSObject* itm = (NSObject *)item;
            if ([itm isKindOfClass:NSURL.class]) {
                self.url = (NSURL *)itm;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.urlText.text = [self.url absoluteString];
                });
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

- (IBAction)didCancel:(id)sender
{
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (void)createTodoWithText:(NSString *)text
{
    KPToDo* todo = [KPToDo addItem:text priority:NO tags:[_tagList getSelectedTags] save:YES from:@"Share extension"];
    if (_url) {
        KPAttachment* attachment = [KPAttachment attachmentForService:URL_SERVICE title:[_url absoluteString] identifier:[_url absoluteString] sync:YES];
        [todo addAttachmentsObject:attachment];
    }
    [KPToDo saveToSync];
}

@end
