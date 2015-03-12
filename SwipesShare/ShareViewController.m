//
//  ShareViewController.m
//  SwipesShare
//
//  Created by demosten on 3/12/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

@import MobileCoreServices;
#import "ShareViewController.h"

@interface ShareViewController ()

@property (nonatomic, weak) IBOutlet UITextField* textField;
@property (nonatomic, weak) IBOutlet UILabel* urlText;
@property (nonatomic, weak) IBOutlet UIButton* cancelButton;
@property (nonatomic, weak) IBOutlet UIButton* postButton;

@property (nonatomic, strong) NSURL* url;

@end

@implementation ShareViewController


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
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.urlText.text = [self.url absoluteString];
                });
            }
        }];
    }
}


- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (IBAction)didSelectPost:(id)sender {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    NSExtensionItem* item = self.extensionContext.inputItems.firstObject;
    //    NSLog(@"title: %@", item.attributedTitle.string);
    //    NSLog(@"content: %@", item.attributedContentText.string);
    
    
    NSLog(@"title: %@", (self.textField.text.length == 0) ? item.attributedContentText.string : self.textField.text);
    if (_url)
        NSLog(@"url: %@", [_url absoluteString]);
    
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (IBAction)didCancel:(id)sender
{
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
