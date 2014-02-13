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
    KPMenuButtonTerms = 6,
    KPMenuButtonPolicy = 7,
    KPMenuButtonLogout = 8,
    KPMenuButtonFeedback = 9,
    KPMenuButtonSync = 10,
    KPMenuButtonScheme = 11,

};
@interface MenuViewController : UIViewController

@end
