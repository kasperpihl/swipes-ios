//
//  SchedulePopup.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 24/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
typedef NS_ENUM(NSUInteger, KPScheduleButtons){
    KPScheduleButtonCancel = 0,
    KPScheduleButtonLaterToday = 1,
    KPScheduleButtonThisEvening = 2,
    KPScheduleButtonTomorrow = 3,
    KPScheduleButtonIn2Days = 4,
    KPScheduleButtonThisWeekend = 5,
    KPScheduleButtonNextWeek = 6,
    KPScheduleButtonUnscheduled = 7,
    KPScheduleButtonLocation = 8,
    KPScheduleButtonSpecificTime = 9
};
typedef void (^SchedulePopupBlock)(KPScheduleButtons button, NSDate *chosenDate, CLPlacemark *chosenLocation, GeoFenceType type);
@interface SchedulePopup : UIView
/* Used for analytics reasons */
+(SchedulePopup*)popupWithFrame:(CGRect)frame block:(SchedulePopupBlock)block;
//+(SchedulePopup*)showInView:(UIView*)view withBlock:(SchedulePopupBlock)block;

@property (nonatomic) NSDate *calendarDate;
@property (nonatomic) NSInteger numberOfItems;
@property (nonatomic,strong) UIView *contentView;

@end
