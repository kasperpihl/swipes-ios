//
//  DateStampView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 05/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kLabelSpacing 0
#define kLabelYHack -1
#define kColor alpha([UIColor whiteColor],0.8)
#define kFontColor kColor
#define kAllDoneFont [UIFont fontWithName:@"NexaHeavy" size:22]

#define kMonthFont [UIFont fontWithName:@"NexaHeavy" size:15]

#define kAllDoneSpacing 20
#define kMonthSpacing 10

#import "DateStampView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate-Utilities.h"
@interface DateStampView ()

@end
@implementation DateStampView
-(id)initWithDate:(NSDate *)date{
    self = [super init];
    if(self){
        CGFloat width = 320;
        CGRectSetWidth(self, width);
        UIImageView *dateStampBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"date_stamp_background"]];
        [self addSubview:dateStampBackground];
        CGRectSetCenterX(dateStampBackground, width/2);
        //self.frame = dateStampBackground.bounds;
        self.backgroundColor = CLEAR;
        //self.frame = CGRectMake(0, 0, kStampSize, kStampSize);
        //self.layer.cornerRadius = kStampSize/2;
        //self.layer.borderWidth = kOuterStrokeSize;
        //self.layer.borderColor = kColor.CGColor;
        
        
        self.allDoneLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.allDoneLabel.backgroundColor = CLEAR;
        self.allDoneLabel.text = @" ALL DONE FOR TODAY ";
        self.allDoneLabel.textAlignment = NSTextAlignmentCenter;
        self.allDoneLabel.font = kAllDoneFont;
        self.allDoneLabel.textColor = kFontColor;
        [self.allDoneLabel sizeToFit];
        [self addSubview:self.allDoneLabel];
        CGRectSetWidth(self.allDoneLabel,width);
        CGRectSetY(self.allDoneLabel, CGRectGetMaxY(dateStampBackground.frame) + kAllDoneSpacing);
        CGRectSetCenterX(self.allDoneLabel, width/2);
        
        
        self.monthLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.monthLabel.text = @"Next task @ 16:30        ";
        self.monthLabel.backgroundColor = CLEAR;
        self.monthLabel.textColor = kFontColor;
        self.monthLabel.textAlignment = NSTextAlignmentCenter;
        self.monthLabel.font = kMonthFont;
        [self.monthLabel sizeToFit];
        [self addSubview:self.monthLabel];
        CGRectSetWidth(self.monthLabel,width);
        CGRectSetY(self.monthLabel, CGRectGetMaxY(self.allDoneLabel.frame) + kMonthSpacing);
        
        
        
        
        self.date = date;
        CGRectSetHeight(self, CGRectGetMaxY(self.monthLabel.frame));
    }
    return self;
}
-(void)setDate:(NSDate *)date{
    _date = date;
    //self.allDoneLabel.frame = self.bounds;
    //self.monthLabel.frame = self.bounds;
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    formatter.dateFormat = @"MMM";
    
    //self.monthLabel.text = [NSString stringWithFormat:@"- %@ %i -",[[formatter stringFromDate:date] lowercaseString],date.day];
    
}
-(void)dealloc{
    self.allDoneLabel = nil;
    self.monthLabel = nil;
}
@end
