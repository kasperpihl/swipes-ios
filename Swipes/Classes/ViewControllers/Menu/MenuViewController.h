//
//  MenuViewController.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 13/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kSettingsBlurColor retColor(gray(230, 0.5),gray(50, 0.4))
typedef NS_ENUM(NSUInteger, KPMenuButtons){
    KPMenuButtonNotifications = 1,
    KPMenuButtonScheme = 2,
    KPMenuButtonUpgrade = 3,
    KPMenuButtonSnoozes = 4,
    KPMenuButtonHelp = 5,
    KPMenuButtonIntegrations = 6,
    KPMenuButtonLogout = 7,
    KPMenuButtonSync = 8,
    KPMenuButtonLocation = 9
};
@interface MenuViewController : UIViewController
-(void)renderSubviews;
-(void)resetAndOpenIntegrations;
-(void)reset;
@end
