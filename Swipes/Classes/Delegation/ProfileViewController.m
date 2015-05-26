//
//  ProfileViewController.m
//  Swipes
//
//  Created by demosten on 2/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <DZNPhotoPickerController/UIImagePickerController+Edit.h>
#import "KPImageCache.h"
#import "AnalyticsHandler.h"
#import "UtilityClass.h"
#import "UserHandler.h"
#import "RootViewController.h"
#import "SettingsHandler.h"
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
    
    NSString* email = kCurrent.email;
    if (![UtilityClass validateEmail:email]) {
        email = @"";
    }
    
    self.cellInfo = @[
                      @{kKeyCellType: @(kIntegrationCellTypeProfilePicture),
                        kKeyTouchSelector: NSStringFromSelector(@selector(onSelectImageTouch)),
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeyIsOn: @(YES),
                        kKeyTitle: @"NAME",
                        kKeyText: [kSettings valueForSetting:ProfileName],
                        kKeyPlaceholder: @"Enter your name",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeyIsOn: @(YES),
                        kKeyTitle: @"EMAIL",
                        kKeyText: email,
                        kKeyTextType: @(IntegrationTextFieldStyleEmail),
                        kKeyPlaceholder: @"Your email is mandatory",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeyTitle: @"PHONE",
                        kKeyText: [kSettings valueForSetting:ProfilePhone],
                        kKeyTextType: @(IntegrationTextFieldStylePhone),
                        kKeyPlaceholder: @"Your phone",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeyTitle: @"COMPANY",
                        kKeyText: [kSettings valueForSetting:ProfileCompany],
                        kKeyPlaceholder: @"Your company",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeyTitle: @"POSITION",
                        kKeyText: [kSettings valueForSetting:ProfilePosition],
                        kKeyPlaceholder: @"Your position in the company",
                        //                        kKeyTouchSelector: NSStringFromSelector(@selector(onSyncWithEvernoteTouch))
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeButton),
                        kKeyTitle: @"Sign out",
                        kKeyTouchSelector: NSStringFromSelector(@selector(onSignOut))
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
    
    // load profile picture
    NSString* profileURLString = [kSettings valueForSetting:ProfilePictureURL];
    if (profileURLString && (10 < profileURLString.length)) {
        // we have profile picture
        NSURL* profileURL = [NSURL URLWithString:profileURLString];
        UIImage* profilePicture = [[KPImageCache sharedCache] cachedImageForURL:profileURL];
        if (profilePicture) {
            // we have it cached
            self.cellInfo[0][kKeyIcon] = profilePicture;
        }
        else {
            // we try to download it
            [[KPImageCache sharedCache] imageForURL:profileURL completionBlock:^(UIImage *image) {
                if (image) {
                    self.cellInfo[0][kKeyIcon] = image;
                    [self reloadRow:0];
                }
            }];
        }
    }
}

#pragma mark - selectors

- (void)onSelectImageTouch
{
    // TODO make it work for iPad too
    
    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:LOCALIZE_STRING(@"Select picture") delegate:self cancelButtonTitle:LOCALIZE_STRING(@"Cancel") destructiveButtonTitle:[self hasProfilePicture]  ? LOCALIZE_STRING(@"Remove current picture") : nil otherButtonTitles:LOCALIZE_STRING(@"Take from Photos"), nil];
    
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
    NSInteger buttonOffset = 1;
    if ([self hasProfilePicture]) {
        buttonOffset--;
    }
    switch (buttonIndex + buttonOffset) {
        case 0: {
                NSURL* url = [NSURL URLWithString:(NSString *)[kSettings valueForSetting:ProfilePictureURL]];
                [[KPImageCache sharedCache] removeImageForURL:(NSString *)url]; // strange warning for sending URLs?
                [kSettings setValue:@"" forSetting:ProfilePictureURL];
                [kSettings setValue:@NO forSetting:ProfilePictureUploaded];
                [self.cellInfo[0] removeObjectForKey:kKeyIcon];
                [self reloadRow:0];
            }
            break;
            
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
    imagePickerController.cropMode = DZNPhotoEditorViewControllerCropModeCircular;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // TODO set image
    UIImage* result = info[UIImagePickerControllerEditedImage];
    if (result) {
        NSString* predictedURLString = [NSString stringWithFormat:@"https://demosten-test-1.s3.amazonaws.com/%@", [self profilePicturePath]];
        NSURL* predictedURL = [NSURL URLWithString:predictedURLString];
        [[KPImageCache sharedCache] setImage:result forURL:predictedURL];
        [kSettings setValue:predictedURLString forSetting:ProfilePictureURL];
        self.cellInfo[0][kKeyIcon] = result;
        [self reloadRow:0];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    DLog(@"Image picker canceled");
}

- (void)onSignOut
{
    [UTILITY confirmBoxWithTitle:LOCALIZE_STRING(@"Log out") andMessage:LOCALIZE_STRING(@"Are you sure you want to log out of your account?") block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.parentViewController dismissViewControllerAnimated:NO completion:nil];
            [ROOT_CONTROLLER logOut];
            [ROOT_CONTROLLER.drawerViewController closeDrawerAnimated:YES completion:nil];
        }
    }];
}

#pragma mark - Helpers

- (BOOL)hasProfilePicture
{
    NSString* profilePictureURL = [kSettings valueForSetting:ProfilePictureURL];
    return profilePictureURL && (10 < profilePictureURL.length); // http://a.b
}

- (NSString *)profilePicturePath
{
    return [NSString stringWithFormat:@"%@/%@.jpg", kCurrent.objectId, [UtilityClass generateIdWithLength:8]];
}

- (void)reload
{
    [self recreateCellInfo];
    [self reloadData];
}

- (void)goBack
{
    [kSettings setValue:self.cellInfo[1][kKeyText] forSetting:ProfileName];
    [kSettings setValue:self.cellInfo[3][kKeyText] forSetting:ProfilePhone];
    [kSettings setValue:self.cellInfo[4][kKeyText] forSetting:ProfileCompany];
    [kSettings setValue:self.cellInfo[5][kKeyText] forSetting:ProfilePosition];
    [super goBack];
}

@end
