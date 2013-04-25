//
//  SchedulePopup.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 24/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, KPScheduleButtons){
    KPScheduleButtonLater = 0,
    KPScheduleButtonTomorrow,
    KPScheduleButtonDayAfterTomorrow,
    KPScheduleButtonWeekend,
    KPScheduleButtonNextWeek
};

@interface SchedulePopup : UIView

@end
