//
//  SnoozesViewController.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 05/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SnoozeSettings) {
    SnoozeNone = -1,
    SnoozeWeekStartTime = 0,
    SnoozeEveningStartTime,
    SnoozeWeekendStartTime,
    SnoozeWeekStart,
    SnoozeWeekendStart,
    SnoozeLaterToday,
    SnoozeTotalNumber
};

@interface SnoozesViewController : UIViewController

@end
