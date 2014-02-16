//
//  MenuViewController.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 13/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, KPMenuButtons){
    KPMenuButtonNotifications = 1,
    KPMenuButtonLocation = 2,
    KPMenuButtonUpgrade = 3,
    KPMenuButtonSnoozes = 4,
    KPMenuButtonWalkthrough = 5 ,
    KPMenuButtonPolicies = 6,
    KPMenuButtonLogout = 7,
    KPMenuButtonFeedback = 8,
    KPMenuButtonSync = 11,
    KPMenuButtonScheme = 9

};
@interface MenuViewController : UIViewController

@end
