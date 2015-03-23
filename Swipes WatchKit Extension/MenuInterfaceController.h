//
//  MenuInterfaceController.h
//  Swipes
//
//  Created by demosten on 3/23/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import <WatchKit/WatchKit.h>

typedef NS_ENUM(NSUInteger, SWAMenuChoice) {
    SWA_MENU_CHOICE_COMPLETE = 0,
    SWA_MENU_CHOICE_SNOOZE = 1,
};

@protocol MenuInterfaceControllerDelegate <NSObject>

- (void)onMenuChoice:(SWAMenuChoice)choice;

@end

@interface MenuInterfaceController : WKInterfaceController

@end
