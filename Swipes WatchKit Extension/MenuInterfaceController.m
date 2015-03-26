//
//  MenuInterfaceController.m
//  Swipes
//
//  Created by demosten on 3/23/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "Global.h"
#import "MenuInterfaceController.h"

@interface MenuInterfaceController ()

@property (nonatomic, weak) IBOutlet WKInterfaceButton* completeButton;
@property (nonatomic, weak) IBOutlet WKInterfaceButton* snoozeButton;

@property (nonatomic, weak) id<MenuInterfaceControllerDelegate> delegate;

@end

@implementation MenuInterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    _delegate = context;
    [_completeButton setTitle:iconString(@"roundConfirm")];
    [_snoozeButton setTitle:iconString(@"settingsSchedule")];
}

- (void)willActivate
{
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate
{
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)onComplete:(id)sender
{
    [self popController];
    if (_delegate) {
        [_delegate onMenuChoice:SWA_MENU_CHOICE_COMPLETE];
    }
}

- (IBAction)onSnooze:(id)sender
{
    [self popController];
    if (_delegate) {
        [_delegate onMenuChoice:SWA_MENU_CHOICE_SNOOZE];
    }
}

@end
