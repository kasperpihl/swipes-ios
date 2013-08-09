//
//  DayPickerSettingsCell.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 08/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kDayPickerHeight kCellHeight
#import "DayPickerSettingsCell.h"
#import <QuartzCore/QuartzCore.h>
@interface DayPickerSettingsCell () <KPDayPickerDelegate>

@end
@implementation DayPickerSettingsCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.dayPicker = [[KPDayPicker alloc] initWithHeight:kDayPickerHeight selectedDay:1];
        self.dayPicker.delegate = self;
        CGRectSetY(self.dayPicker, kCellHeight);
        [self addSubview:self.dayPicker];
        self.layer.masksToBounds = YES;
    }
    return self;
}
-(void)dayPicker:(KPDayPicker *)dayPicker selectedWeekday:(NSInteger)weekday{
    [self.delegate dayPickerCell:self pickedWeekDay:weekday];
}
@end
