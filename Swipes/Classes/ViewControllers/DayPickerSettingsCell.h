//
//  DayPickerSettingsCell.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 08/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "SettingsCell.h"
#import "KPDayPicker.h"
@class DayPickerSettingsCell;
@protocol DayPickerSettingsDelegate
-(void)dayPickerCell:(DayPickerSettingsCell*)cell pickedWeekDay:(NSInteger)weekday;
@end
@interface DayPickerSettingsCell : SettingsCell
@property (nonatomic) KPDayPicker *dayPicker;
@property (nonatomic,weak) NSObject<DayPickerSettingsDelegate> *delegate;
@end
