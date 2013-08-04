//
//  KPTimePicker.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KPTimePicker;
@protocol KPTimePickerDelegate
-(void)timePicker:(KPTimePicker*)timePicker selectedDate:(NSDate *)date;
@optional
-(NSString*)timePicker:(KPTimePicker*)timePicker titleForDate:(NSDate *)time;
@end


@interface KPTimePicker : UIView

@property (nonatomic,weak) NSObject<KPTimePickerDelegate> *delegate;
@property (nonatomic) NSInteger wheelRadius;
@property (nonatomic) UIColor *wheelColor;
@property (nonatomic) UIColor *foregroundColor;
@property (nonatomic) UIColor *wheelBackgroundColor;
@property (nonatomic) NSInteger middleRadius;

@property (nonatomic,strong) NSDate *pickingDate;
@property (nonatomic,strong) NSDate *minimumDate;
@property (nonatomic,strong) NSDate *maximumDate;
@property (nonatomic) CGPoint centerPoint;
@property (nonatomic) UIColor *lightColor;
@property (nonatomic) UIColor *darkColor;

-(void)forwardGesture:(UIPanGestureRecognizer*)sender;
@end