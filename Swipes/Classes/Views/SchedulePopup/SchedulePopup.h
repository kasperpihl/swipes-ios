//
//  SchedulePopup.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 24/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KPScheduleButtons){
    KPScheduleButtonCancel = 0,
    KPScheduleButtonTomorrow = 1,
    KPScheduleButtonIn2Days = 2,
    KPScheduleButtonIn3Days = 3,
    KPScheduleButtonInAWeek = 5,
    KPScheduleButtonSpecificTime = 9,
    KPScheduleButtonUnscheduled = 7
};
typedef void (^SchedulePopupBlock)(KPScheduleButtons button, NSDate *chosenDate);
@interface SchedulePopup : UIView
+(SchedulePopup*)showInView:(UIView*)view withBlock:(SchedulePopupBlock)block;
@end
