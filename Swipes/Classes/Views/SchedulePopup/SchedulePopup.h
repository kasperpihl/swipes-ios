//
//  SchedulePopup.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 24/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPPopup.h"

typedef NS_ENUM(NSUInteger, KPScheduleButtons){
    KPScheduleButtonCancel = 0,
    KPScheduleButtonLaterToday = 1,
    KPScheduleButtonTomorrow = 2,
    KPScheduleButtonIn2Days = 3,
    KPScheduleButtonIn3Days = 4,
    KPScheduleButtonInAWeek = 5,
    KPScheduleButtonSpecificTime = 9,
    KPScheduleButtonUnscheduled = 7
};
typedef void (^SchedulePopupBlock)(KPScheduleButtons button, NSDate *chosenDate);
@interface SchedulePopup : KPPopup
+(SchedulePopup*)showInView:(UIView*)view withBlock:(SchedulePopupBlock)block;
@end
