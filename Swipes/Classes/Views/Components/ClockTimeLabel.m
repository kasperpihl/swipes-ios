//
//  ClockTimeLabel.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 07/10/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kDefTextColor tcolor(TextColor)
#import <QuartzCore/QuartzCore.h>
#import "ClockTimeLabel.h"
#import "NSDate-Utilities.h"
@implementation ClockTimeLabel
-(void)setCircleColor:(UIColor *)circleColor{
    _circleColor = circleColor;
    [self setNeedsDisplay];
}
-(void)setTime:(NSDate *)time{
    _time = [time dateToNearest15Minutes];
    
    self.text = [NSString stringWithFormat:@"%i",_time.hour];
    
    NSLog(@"self.text:%@",self.text);
    [self setNeedsDisplay];
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.textColor = kDefTextColor;
        self.backgroundColor = CLEAR;
        self.textAlignment = UITextAlignmentCenter;
        self.layer.masksToBounds = NO;
    }
    return self;
}
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    if(self.time && self.circleColor){
        CGFloat width = self.bounds.size.width;
        CGFloat height = self.bounds.size.height;
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, LINE_SIZE);
        CGContextSetStrokeColorWithColor(context, self.circleColor.CGColor);
        NSInteger angle = -90;
        NSInteger minute = self.time.minute;
        if(minute >= 10 && minute <= 24) angle = 360;
        else if(minute >= 25 && minute <= 39) angle = 90;
        else if(minute >= 40 && minute <= 54) angle = 180;
        CGContextAddArc(context, width/2, height/2, width/2-LINE_SIZE, 270*M_PI/180, angle*M_PI/180, 0);
        CGContextStrokePath(context);
    }
}
@end
