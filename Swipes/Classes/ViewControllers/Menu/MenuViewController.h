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
    KPMenuButtonSnoozes = 2,
    KPMenuButtonWalkthrough = 4 ,
    KPMenuButtonFeedback = 5,
    KPMenuButtonUpgrade = 3,
    KPMenuButtonPolicy = 6,
    KPMenuButtonSync = 9,
    KPMenuButtonLogout = 7
};
@interface MenuViewController : UIViewController

@end
