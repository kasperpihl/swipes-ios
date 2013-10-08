//
//  DateStampView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 05/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kOuterStrokeSize LINE_SIZE
#define kLabelSpacing 0
#define kLabelYHack -1
#define kColor alpha([UIColor whiteColor],0.8)
#define kFontColor kColor//tcolor(TaskCellTagColor)
#define kNumberFont KP_BOLD(50)
#define kMonthFont KP_BOLD(20)

#import "DateStampView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate-Utilities.h"
@interface DateStampView ()

@property (nonatomic) UILabel *numberLabel;
@property (nonatomic) UILabel *monthLabel;
@end
@implementation DateStampView
-(id)initWithDate:(NSDate *)date{
    self = [super init];
    if(self){
        
        self.backgroundColor = CLEAR;
        self.frame = CGRectMake(0, 0, kStampSize, kStampSize);
        self.layer.cornerRadius = kStampSize/2;
        self.layer.borderWidth = kOuterStrokeSize;
        self.layer.borderColor = kColor.CGColor;
        
        
        self.numberLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.numberLabel.backgroundColor = CLEAR;
        self.numberLabel.textAlignment = UITextAlignmentCenter;
        self.numberLabel.font = kNumberFont;
        self.numberLabel.textColor = kFontColor;
        
        
        self.monthLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.monthLabel.backgroundColor = CLEAR;
        self.monthLabel.textColor = kFontColor;
        self.monthLabel.textAlignment = UITextAlignmentCenter;
        self.monthLabel.font = kMonthFont;
        
        [self addSubview:self.monthLabel];
        [self addSubview:self.numberLabel];
        
        self.date = date;
    }
    return self;
}
-(void)setDate:(NSDate *)date{
    _date = date;
    self.numberLabel.frame = self.bounds;
    self.monthLabel.frame = self.bounds;
    self.numberLabel.text = [NSString stringWithFormat:@"%i",date.day];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    formatter.dateFormat = @"MMM";
    self.monthLabel.text = [[formatter stringFromDate:date] uppercaseString];
    
    [self.numberLabel sizeToFit];
    [self.monthLabel sizeToFit];
    
    CGFloat totalSize = self.numberLabel.bounds.size.height + kLabelSpacing + self.monthLabel.bounds.size.height;
    self.numberLabel.frame = CGRectSetPos(self.numberLabel.frame, (kStampSize-self.numberLabel.frame.size.width)/2, (kStampSize-totalSize)/2 + kLabelYHack);
    self.monthLabel.frame = CGRectSetPos(self.monthLabel.frame, (kStampSize-self.monthLabel.frame.size.width)/2, kStampSize-((kStampSize-totalSize)/2)-self.monthLabel.frame.size.height + kLabelYHack);
    
}
-(void)dealloc{
    self.numberLabel = nil;
    self.monthLabel = nil;
}
@end
