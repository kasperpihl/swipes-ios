//
//  KPDayPicker.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 07/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KPDayPicker;
@protocol KPDayPickerDelegate <NSObject>
-(void)dayPicker:(KPDayPicker*)dayPicker selectedWeekday:(NSInteger)weekday;
@end
@interface KPDayPicker : UIView
@property (nonatomic) NSInteger selectedDay;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIColor *selectedColor;
@property (nonatomic) UIFont *font;
@property (nonatomic,weak) id<KPDayPickerDelegate> delegate;
-(id)initWithHeight:(CGFloat)height selectedDay:(NSInteger)selectedDay;
@end
