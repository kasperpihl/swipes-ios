//
//  KPDayPicker.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 07/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KPRepeatPicker;

@protocol KPRepeatPickerDelegate <NSObject>
-(void)repeatPicker:(KPRepeatPicker*)repeatPicker selectedOption:(RepeatOptions)option;
@end
@interface KPRepeatPicker : UIView
@property (nonatomic) RepeatOptions currentOption;
@property (nonatomic) NSDate *selectedDate;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIColor *selectedColor;
@property (nonatomic) UIFont *font;
@property (nonatomic,weak) id<KPRepeatPickerDelegate> delegate;
-(id)initWithWidth:(CGFloat)width height:(CGFloat)height selectedDate:(NSDate *)date option:(RepeatOptions)option;
-(void)setSelectedDate:(NSDate *)selectedDate option:(RepeatOptions)option;
@end
