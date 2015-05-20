//
//  ProfileViewController.m
//  Swipes
//
//  Created by demosten on 2/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "AnalyticsHandler.h"
#import "UtilityClass.h"
//#import "DejalActivityView.h"
#import "IntegrationTextFieldCell.h"
#import "ProfileViewController.h"

@interface ProfileViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ProfileViewController {
    BOOL _canTakePicture;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = LOCALIZE_STRING(@"PROFILE");
}

- (void)recreateCellInfo
{
    [super recreateCellInfo];
    self.cellInfo = @[
                      @{kKeyCellType: @(kIntegrationCellTypeProfilePicture),
                        kKeyTouchSelector: NSStringFromSelector(@selector(onSelectImageTouch)),
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeyIsOn: @(YES),
                        kKeyTitle: @"NAME",
                        kKeyText: @"My Name",
                        kKeyPlaceholder: @"Enter your name",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeyIsOn: @(YES),
                        kKeyTitle: @"EMAIL",
                        kKeyText: @"user@host.com",
                        kKeyTextType: @(IntegrationTextFieldStyleEmail),
                        kKeyPlaceholder: @"Your email is mandatory",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeyTitle: @"PHONE",
                        kKeyText: @"+359 88 7660834",
                        kKeyTextType: @(IntegrationTextFieldStylePhone),
                        kKeyPlaceholder: @"Your phone",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeyTitle: @"COMPANY",
                        kKeyText: @"Swipes Inc.",
                        kKeyPlaceholder: @"Your company",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeyTitle: @"POSITION",
                        kKeyText: @"Creative Creator",
                        kKeyPlaceholder: @"Your position in the company",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeButton),
                        kKeyTitle: @"Sign out",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        },
                      @{kKeyCellType: @(kIntegrationCellTypeButton),
                        kKeyTitle: @"Change password",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        },
                      @{kKeyCellType: @(kIntegrationCellTypeButton),
                        kKeyTitle: @"Delete account",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        },
                      ];
}

#pragma mark - selectors

- (void)onSelectImageTouch
{
    // TODO make it work for iPad too
    
    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:LOCALIZE_STRING(@"Select picture") delegate:self cancelButtonTitle:LOCALIZE_STRING(@"Cancel") destructiveButtonTitle:LOCALIZE_STRING(@"Remove current picture") otherButtonTitles:LOCALIZE_STRING(@"Take from Photos"), nil];
    
    _canTakePicture = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (_canTakePicture) {
        [action addButtonWithTitle:LOCALIZE_STRING(@"Take picture")];
    }

    if ([PFFacebookUtils isLinkedWithUser:kCurrent]) {
        [action addButtonWithTitle:LOCALIZE_STRING(@"Facebook profile picture")];
    }
    
    [action showFromRect:self.view.frame inView:self.view animated:YES];
}

- (void)downloadFacebookPicture
{
    FBSession* fbSession = [PFFacebookUtils session];
    NSString* accessToken = fbSession.accessTokenData.accessToken;
    //self.imageData = [[NSMutableData alloc] init];
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token=%@", accessToken]];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:pictureURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
            
        case 2:
            if (!_canTakePicture) {
                [self downloadFacebookPicture];
            }
            else {
                [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
            }
            break;
            
        case 3:
            [self downloadFacebookPicture];
            break;
            
        default:
            break;
    }
    
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.allowsEditing = YES;
    imagePickerController.delegate = self;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // TODO set image
    UIImage* result = info[UIImagePickerControllerEditedImage];
    if (result) {
        self.cellInfo[0][kKeyIcon] = result;
        [self reloadRow:0];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (void)onSyncWithEvernoteTouch
//{
//    kEnInt.enableSync = !kEnInt.enableSync;
//    self.cellInfo[0][kKeyIsOn] = @(kEnInt.enableSync);
//}
//
//- (void)onAutoImportTouch
//{
//    kEnInt.autoFindFromTag = !kEnInt.autoFindFromTag;
//    self.cellInfo[1][kKeyIsOn] = @(kEnInt.autoFindFromTag);
//}
//
//- (void)onFindPersonalTouch
//{
//    kEnInt.findInPersonalLinked = !kEnInt.findInPersonalLinked;
//    self.cellInfo[2][kKeyIsOn] = @(kEnInt.findInPersonalLinked);
//}
//
//- (void)onFindBusinessNotebooksTouch
//{
//    kEnInt.findInBusinessNotebooks = !kEnInt.findInBusinessNotebooks;
//    self.cellInfo[3][kKeyIsOn] = @(kEnInt.findInBusinessNotebooks);
//}
//
//- (void)onBusinessLearnMoreTouch
//{
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://evernote.com/business/"]];
//}
//
//- (void)onImportNotesTouch
//{
//    [ANALYTICS pushView:@"Evernote Importer"];
//    [self presentViewController:[[EvernoteImporterViewController alloc] init] animated:YES completion:nil];
//}
//
//- (void)onLearnMoreTouch
//{
//    [ANALYTICS pushView:@"Evernote Learn More"];
//    EvernoteHelperViewController *helper = [[EvernoteHelperViewController alloc] init];
//    helper.delegate = self;
//    [self presentViewController:helper animated:YES completion:nil];
//}
//
//- (void)onSignOutTouch
//{
//    if (kEnInt.isAuthenticated){
//        [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Unlink Evernote") andMessage:LOCALIZE_STRING(@"All tasks will be unlinked, are you sure?") block:^(BOOL succeeded, NSError *error) {
//            if (succeeded) {
//                [kEnInt logout];
//                NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
//                [KPToDo removeAllAttachmentsForAllToDosWithService:EVERNOTE_SERVICE inContext:context save:YES];
//                [self reload];
//            }
//        }];
//    }
//}
//
//- (void)onLinkEvernoteTouch
//{
//    [self evernoteAuthenticateUsingSelector:@selector(authenticatedEvernote) withObject:nil];
//}
//
#pragma mark - Helpers

- (void)reload
{
    [self recreateCellInfo];
    [self reloadData];
}

@end
