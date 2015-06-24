//
//  ProfileViewController.m
//  Swipes
//
//  Created by demosten on 2/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//
// TODO:
// - add support for https://github.com/iziz/libPhoneNumber-iOS
// - test on iPad
// - how do we act upon extraction of email from FB, do se set it to profile
// - how do we act upon email change

#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <DZNPhotoPickerController/UIImagePickerController+Edit.h>
//#import <DZNPhotoPickerController/DZNPhotoEditorViewController.h>
#import <AFAmazonS3Manager/AFAmazonS3Manager.h>
#import <AFAmazonS3Manager/AFAmazonS3ResponseSerializer.h>

#import "KPImageCache.h"
#import "AnalyticsHandler.h"
#import "UtilityClass.h"
#import "UserHandler.h"
#import "RootViewController.h"
#import "SettingsHandler.h"
#import "DejalActivityView.h"
#import "IntegrationTextFieldCell.h"
#import "ProfileViewController.h"

static NSString* const kAmazonS3BucketName = @"demosten-test-1";
static NSString* const kFacebookKeyEmail = @"email";

@interface ProfileViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ProfileViewController {
    BOOL _canTakePicture;
}

+ (AFAmazonS3Manager *)s3Manager
{
    static AFAmazonS3Manager* s_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // TODO ensure encoded data
        s_manager = [[AFAmazonS3Manager alloc] initWithAccessKeyID:@"AKIAIT34G5FY7B7UGIQA" secret:@"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"];
        s_manager.requestSerializer.region = AFAmazonS3USStandardRegion;
        s_manager.requestSerializer.bucket = kAmazonS3BucketName;
    });
    return s_manager;
}

// update string value only if changed
+ (void)updateValue:(NSString *)value forSetting:(KPSettings)setting
{
    NSString* currentValue = [kSettings valueForSetting:setting];
    if (currentValue && [currentValue isEqualToString:value]) {
        return; // do not store if the value is unchanged
    }
    [kSettings setValue:value forSetting:setting];
}

+ (void)checkUploadPhoto
{
    AFAmazonS3Manager* s3Manager = [ProfileViewController s3Manager];
    if (![[kSettings valueForSetting:ProfilePictureUploaded] boolValue]) {
        NSString* pictureURLString = [kSettings valueForSetting:ProfilePictureURL];
        if (pictureURLString && (10 < pictureURLString.length)) {
            NSURL* pictureURL = [NSURL URLWithString:pictureURLString];
            NSString* fullImagePath = [[KPImageCache sharedCache] imagePathForURL:pictureURL];
            if (fullImagePath) {
                NSString* remotePath = [pictureURL path];
                [s3Manager putObjectWithFile:fullImagePath
                             destinationPath:remotePath
                                  parameters:nil
                                    progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                                        DLog(@"%f%% Uploaded", (totalBytesWritten / (totalBytesExpectedToWrite * 1.0f) * 100));
                                    }
                                     success:^(AFAmazonS3ResponseObject *responseObject) {
                                         DLog(@"Upload Complete: %@", responseObject.URL);
                                         [kSettings setValue:@YES forSetting:ProfilePictureUploaded];
                                         [ProfileViewController updateValue:[responseObject.URL absoluteString] forSetting:ProfilePictureURL];
                                     }
                                     failure:^(NSError *error) {
                                         [UtilityClass sendError:error type:@"Profile picture upload"];
                                     }];
            }
        }
    }
    
    // delete old profile picture if it exists
    NSString* profileURLToDelete = [kSettings valueForSetting:ProfilePictureURLToDelete];
    if (profileURLToDelete && (10 < profileURLToDelete.length)) {
        NSURL* pictureURL = [NSURL URLWithString:profileURLToDelete];
        NSString* remotePath = [pictureURL path];
        if (remotePath) {
            [s3Manager deleteObjectWithPath:remotePath
                                    success:^(AFAmazonS3ResponseObject *responseObject) {
                                        [kSettings setValue:@"" forSetting:ProfilePictureURLToDelete];
                                    }
                                    failure:^(NSError *error) {
                                        [UtilityClass sendError:error type:@"Profile picture delete"];
                                    }];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"PROFILE", nil);
}

- (void)recreateCellInfo
{
    [super recreateCellInfo];
    
    NSString* email = kCurrent.email;
    if (![UtilityClass validateEmail:email]) {
        email = kCurrent.username;
        if (![UtilityClass validateEmail:email]) {
            email = @"";
        }
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
                        kKeyValidateSelector: NSStringFromSelector(@selector(validateName:)),
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeyIsOn: @(YES),
                        kKeyTitle: @"EMAIL",
                        kKeyText: email,
                        kKeyTextType: @(IntegrationTextFieldStyleEmail),
                        kKeyPlaceholder: @"Your email is mandatory",
                        kKeyValidateSelector: NSStringFromSelector(@selector(validateEmail:)),
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
    
    // load Facebook email if needed
    if (0 == email.length && [PFFacebookUtils isLinkedWithUser:kCurrent]) {
        [self loadFacebookEmail];
    }
}

#pragma mark - selectors

- (void)onSelectImageTouch
{
    // TODO make it work for iPad too
    
    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select picture", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:[self hasProfilePicture]  ? NSLocalizedString(@"Remove current picture", nil) : nil otherButtonTitles:NSLocalizedString(@"Take from Photos", nil), nil];
    
    _canTakePicture = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (_canTakePicture) {
        [action addButtonWithTitle:NSLocalizedString(@"Take picture", nil)];
    }

    if ([PFFacebookUtils isLinkedWithUser:kCurrent]) {
        [action addButtonWithTitle:NSLocalizedString(@"Facebook profile picture", nil)];
    }
    
    [action showFromRect:self.view.frame inView:self.view animated:YES];
}

#pragma mark - Validators

- (BOOL)validateEmail:(NSDictionary *)data
{
    return [UtilityClass validateEmail:data[kKeyText]];
}

- (BOOL)validateName:(NSDictionary *)data
{
    NSString* text = data[kKeyText];
    return text && (1 < text.length);
}

#pragma mark - Helpers

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
                [kSettings setValue:[kSettings valueForSetting:ProfilePictureURL] forSetting:ProfilePictureURLToDelete];
                [kSettings setValue:@"" forSetting:ProfilePictureURL];
                [kSettings setValue:@NO forSetting:ProfilePictureUploaded];
                [self.cellInfo[0] removeObjectForKey:kKeyIcon];
                [self reloadRow:0];
                [ProfileViewController checkUploadPhoto];
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
        [self storeProfilePicture:result];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    DLog(@"Image picker canceled");
}

- (void)onSignOut
{
    [UTILITY confirmBoxWithTitle:NSLocalizedString(@"Log out", nil) andMessage:NSLocalizedString(@"Are you sure you want to log out of your account?", nil) block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.parentViewController dismissViewControllerAnimated:NO completion:nil];
            [ROOT_CONTROLLER logOut];
            [ROOT_CONTROLLER.drawerViewController closeDrawerAnimated:YES completion:nil];
        }
    }];
}

#pragma mark - Helpers

- (void)downloadFacebookPicture
{
    // TODO show wait screen?
    [DejalBezelActivityView activityViewForView:[GlobalApp topView] withLabel:NSLocalizedString(@"Loading from Facebook...", nil)];

    FBSession* fbSession = [PFFacebookUtils session];
    NSString* accessToken = fbSession.accessTokenData.accessToken;
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token=%@", accessToken]];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:pictureURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [DejalBezelActivityView removeViewAnimated:YES];
        if (data) {
            UIImage* image = [UIImage imageWithData:data];
            if (image) {
                // TODO search for the circular editor problem
//                DZNPhotoEditorViewController *editor = [[DZNPhotoEditorViewController alloc] initWithImage:image];
//                editor.cropMode = DZNPhotoEditorViewControllerCropModeCircular;
//                CGFloat width = CGRectGetWidth(self.view.frame) - 50;
//                editor.cropSize = CGSizeMake(width, width);
//                
//                [editor setAcceptBlock:^(DZNPhotoEditorViewController *editor, NSDictionary *userInfo){
                    [self storeProfilePicture:image];
//                }];
//                
//                [editor setCancelBlock:^(DZNPhotoEditorViewController *editor){
//                    DLog(@"Canceled");
//                    [self dismissViewControllerAnimated:NO completion:nil];
//                }];
//                [self presentViewController:editor animated:YES completion:nil];
                return;
            }
        }
        // report error
        NSError* error = connectionError;
        if (!error) {
            error = [NSError errorWithDomain:@"Invalid facebook image without error and data" code:801 userInfo:nil];
        }
        [UtilityClass sendError:error type:@"Facebook profile picture extract"];
    }];
}

- (void)storeProfilePicture:(UIImage *)image
{
    NSString* predictedURLString = [NSString stringWithFormat:@"https://%@.s3.amazonaws.com/%@", kAmazonS3BucketName, [self profilePicturePath]];
    NSURL* predictedURL = [NSURL URLWithString:predictedURLString];
    [[KPImageCache sharedCache] setImage:image forURL:predictedURL];
    [kSettings setValue:[kSettings valueForSetting:ProfilePictureURL] forSetting:ProfilePictureURLToDelete];
    [kSettings setValue:predictedURLString forSetting:ProfilePictureURL];
    [kSettings setValue:@NO forSetting:ProfilePictureUploaded];
    self.cellInfo[0][kKeyIcon] = image;
    [self reloadRow:0];
    [ProfileViewController checkUploadPhoto];
}

- (BOOL)hasProfilePicture
{
    NSString* profilePictureURL = [kSettings valueForSetting:ProfilePictureURL];
    return profilePictureURL && (10 < profilePictureURL.length); // http://a.b
}

- (NSString *)profilePicturePath
{
    return [NSString stringWithFormat:@"%@/%@.jpg", kCurrent.objectId, [UtilityClass generateIdWithLength:8]];
}

- (void)loadFacebookEmail
{
    FBSession* fbSession = [PFFacebookUtils session];
    NSString* accessToken = fbSession.accessTokenData.accessToken;
    NSURL *profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/?fields=email&access_token=%@", accessToken]];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:profileURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
            NSError *error = nil;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (jsonDict && jsonDict[kFacebookKeyEmail]) {
                self.cellInfo[2][kKeyText] = jsonDict[kFacebookKeyEmail];
                [self reloadRow:2];
            }
        }
    }];
}

- (void)reload
{
    [self recreateCellInfo];
    [self reloadData];
}

- (void)goBack
{
    // store values
    // TODO: store email (change it/update it)
    [ProfileViewController updateValue:self.cellInfo[1][kKeyText] forSetting:ProfileName];
    [ProfileViewController updateValue:self.cellInfo[3][kKeyText] forSetting:ProfilePhone];
    [ProfileViewController updateValue:self.cellInfo[4][kKeyText] forSetting:ProfileCompany];
    [ProfileViewController updateValue:self.cellInfo[5][kKeyText] forSetting:ProfilePosition];

    [super goBack];
}

@end
