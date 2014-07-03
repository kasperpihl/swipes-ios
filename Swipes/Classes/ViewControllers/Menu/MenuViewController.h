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
    KPMenuButtonLocation = 2,
    KPMenuButtonUpgrade = 3,
    KPMenuButtonSnoozes = 4,
    KPMenuButtonWalkthrough = 5 ,
    KPMenuButtonPolicies = 6,
    KPMenuButtonLogout = 7,
    KPMenuButtonFeedback = 8,
    KPMenuButtonScheme = 9,
    KPMenuButtonSync = 11,
    KPMenuButtonIntegrations = 12
};
@interface MenuViewController : UIViewController
-(void)renderSubviews;
@end
