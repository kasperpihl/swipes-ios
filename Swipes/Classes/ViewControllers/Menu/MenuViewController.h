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
    KPMenuButtonUpgrade = 3,
    KPMenuButtonWalkthrough = 4 ,
    KPMenuButtonTerms = 5,
    KPMenuButtonPolicy = 6,
    KPMenuButtonLogout = 7,
    KPMenuButtonFeedback = 8,
    KPMenuButtonSync = 9,

};
@interface MenuViewController : UIViewController

@end
