//
//  PasswordChangeViewController.m
//  Swipes
//
//  Created by demosten on 6/24/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "PasswordChangeViewController.h"

@interface PasswordChangeViewController ()

@end

@implementation PasswordChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"CHANGE PASSWORD", nil);
    [self setDialogModeWithSize:CGSizeMake(300, 320) minOffset:10 options:@{}];
}

- (void)recreateCellInfo
{
    [super recreateCellInfo];
    
    self.cellInfo = @[
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeySecure: @(YES),
                        kKeyFocus: @(YES),
                        kKeyValidateSelector: NSStringFromSelector(@selector(validateEmptyField:)),
                        kKeyTitle: [NSLocalizedString(@"CURRENT PASSWORD", nil) uppercaseString],
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeySecure: @(YES),
                        kKeyTitle: [NSLocalizedString(@"NEW PASSWORD", nil) uppercaseString],
                        kKeyValidateSelector: NSStringFromSelector(@selector(validateEmptyField:)),
                        //kKeyValidateSelector: NSStringFromSelector(@selector(validateNewPassword2:)),
                        }.mutableCopy,
                      @{kKeyCellType: @(kIntegrationCellTypeTextField),
                        kKeySecure: @(YES),
                        kKeyTitle: [NSLocalizedString(@"CONFIRM NEW PASSWORD", nil) uppercaseString],
                        kKeyValidateSelector: NSStringFromSelector(@selector(validateEmptyField:)),
                        //kKeyValidateSelector: NSStringFromSelector(@selector(validateNewPassword2:)),
                        }.mutableCopy,
                      ];
}

#pragma mark - selectors



#pragma mark - Validators

- (BOOL)validateEmptyField:(NSDictionary *)data
{
    NSString* text = data[kKeyText];
    return text && (0 < text.length);
}

- (BOOL)validateNewPassword2:(NSDictionary *)data
{
    return (NSOrderedSame == [self.cellInfo[1][kKeyText] compare:self.cellInfo[2][kKeyText]]);
}

- (void)confirm
{
    DLog(@"trying to comfirm password change");
    
    [super confirm];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
