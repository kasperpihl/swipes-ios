//
//  KPTimePicker.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kMinutesInDay 1440
#define kMinutesInHalfDay 720

#define kSunImageDistance valForScreen(160, 100)
#define kLabelSpacing valForScreen(0,0)
#define kClockLabelY valForScreen(0,0)
#define kClockLabelFont [UIFont fontWithName:@"BebasNeue" size:valForScreen(65,75)]
#define kDayLabelFont KP_SEMIBOLD(valForIpad(25,valForScreen(14,16)))
#define kDefMiddleButtonRadius 60
#define kDefActualSize valForScreen(85,93)

#define kDefClearMiddle 45

#define kBackMargin 10

#define kOpenedSunAngle valForScreen(70,60)
#define kExtraAngleForIcons 22

#define kDefLightColor          retColor(tcolor(BackgroundColor),gray(255,1)) //tcolor(BackgroundColor) //retColor(gray(30,1),gray(230,1))
#define kDefDarkColor           retColor(tcolor(BackgroundColor),gray(255,1)) //gray(255,1) //tcolor(BackgroundColor)


#define kGlowShowHack           0.4
#define kGlowMiddleShowHack     0.12
#define kBackButtonSize         52

#import <QuartzCore/QuartzCore.h>
#import "KPTimePicker.h"
#import "NSDate-Utilities.h"
#import "UtilityClass.h"
#import "UIColor+Utilities.h"
#import "SlowHighlightIcon.h"
@class KPTimePicker;


@interface KPTimePicker () <UIGestureRecognizerDelegate>
@property (nonatomic) CGPoint lastPosition;
@property (nonatomic) CGFloat lastChangedAngle;
@property (nonatomic) BOOL isInConfirmButton;
@property (nonatomic) BOOL isOutOfScope;
@property (nonatomic,strong) UIImageView *timeSlider;
@property (nonatomic,strong) UIButton *confirmButton;
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UILabel *dayLabel;
@property (nonatomic,strong) UILabel *clockLabel;
@end
@implementation KPTimePicker
/*-(void)setDelegate:(NSObject<KPTimePickerDelegate> *)delegate{
    _delegate = delegate;
    [self updateForDate:self.pickingDate];
}*/
-(void)setPickingDate:(NSDate *)pickingDate{
    if(_pickingDate != pickingDate){
        if(pickingDate) pickingDate = [pickingDate dateToNearest5Minutes];
        _pickingDate = pickingDate;
        [self updateForDate:pickingDate];
    }
}
-(void)setIsInConfirmButton:(BOOL)isInConfirmButton{
    if(_isInConfirmButton != isInConfirmButton){
        _isInConfirmButton = isInConfirmButton;
        if(_isInConfirmButton){
            [self performSelector:@selector(didWaitDelay) withObject:nil afterDelay:kGlowShowHack];
        }
        else [self didWaitDelay];
    }
}
-(void)setIsOutOfScope:(BOOL)isOutOfScope{
    if(_isOutOfScope != isOutOfScope){
        _isOutOfScope = isOutOfScope;
        if(isOutOfScope){
            [self performSelector:@selector(didWaitInMiddle) withObject:nil afterDelay:kGlowMiddleShowHack];
        }
    }
}
-(void)highlightImageForSlider:(BOOL)highlight animated:(BOOL)animated{
    if(highlight == self.timeSlider.highlighted)
        return;
    if(animated){
        self.timeSlider.highlighted = highlight;
        CATransition *transition = [CATransition animation];
        transition.duration = 0.25f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        
        [self.timeSlider.layer addAnimation:transition forKey:nil];
    }
    else{
        self.timeSlider.highlighted = highlight;
    }
}
-(void)didWaitInMiddle{
    if(self.isOutOfScope){
        self.confirmButton.highlighted = YES;
    }
}
-(void)didWaitDelay{
    self.confirmButton.highlighted = self.isInConfirmButton;
}
#pragma mark Actions
-(void)pressedBackButton:(UIButton*)sender{
    [self.delegate timePicker:self selectedDate:nil];
}
-(void)pressedConfirmButton:(UIButton*)sender{
    [self.delegate timePicker:self selectedDate:self.pickingDate];
}
-(void)forwardGesture:(UIPanGestureRecognizer *)sender{
    [self panGestureRecognized:sender];
}
#define distanceBetween(p1,p2) sqrt(pow((p2.x-p1.x),2) + pow((p2.y-p1.y),2))
- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    CGPoint velocity = [sender velocityInView:self];
    CGPoint location = [sender locationInView:self];
    CGFloat vel = fabsf(velocity.y)+fabsf(velocity.x);
    NSInteger minutesPerInterval = 5;
    CGFloat angleInterval = 50;
    //NSLog(@"%f",vel);
    if(vel > 1400){
        minutesPerInterval = 30;
        angleInterval = 40;
    }
    angleInterval = angleInterval*M_PI/180;
    CGFloat distanceToMiddle = distanceBetween(self.centerPoint, location);
    self.isInConfirmButton = (distanceToMiddle < kDefMiddleButtonRadius);
    self.isOutOfScope = (distanceToMiddle < kDefClearMiddle);
    if (sender.state == UIGestureRecognizerStateChanged || sender.state == UIGestureRecognizerStateBegan) {
        if(!self.isOutOfScope){
            [self highlightImageForSlider:YES animated:YES];
            CGPoint sliderStartPoint = self.lastPosition;// CGPointMake(self.centerPoint.x, self.centerPoint.y - 100.0);
            if(CGPointEqualToPoint(self.lastPosition, CGPointZero)) sliderStartPoint = location;
            CGFloat angle = [self angleBetweenCenterPoint:self.centerPoint point1:sliderStartPoint point2:location];
            CGFloat imageAngle = [self angleBetweenCenterPoint:self.centerPoint point1:CGPointMake(-100, self.centerPoint.y) point2:location];
            CGFloat rounded = floorf((degrees(imageAngle)+1)/2)*2;
            self.timeSlider.transform = CGAffineTransformMakeRotation(-radians(rounded));
            self.lastChangedAngle = self.lastChangedAngle + angle;
            self.lastPosition = location;
            NSInteger numberOfIntervals = round(self.lastChangedAngle/angleInterval);
            if(numberOfIntervals != 0){
                
                NSInteger timeAdded = minutesPerInterval*numberOfIntervals;
                NSDate *newTime = [self.pickingDate dateBySubtractingMinutes:timeAdded];
                self.lastChangedAngle = 0;
                
                if(self.minimumDate && [newTime isEarlierThanDate:self.minimumDate]) newTime = self.minimumDate;
                if(self.maximumDate && [newTime isLaterThanDate:self.maximumDate]) newTime = self.maximumDate;
                
                self.pickingDate = newTime;
            }
        }
        else{
            self.lastPosition = CGPointZero;
            self.lastChangedAngle = 0;
            
        }
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self highlightImageForSlider:NO animated:YES];
        self.lastPosition = CGPointZero;
        self.lastChangedAngle = 0;
        self.confirmButton.highlighted = NO;
        if(self.isInConfirmButton){
            [self.delegate timePicker:self selectedDate:self.pickingDate];
        }
    }
}
-(CGFloat)angleBetweenCenterPoint:(CGPoint)centerPoint point1:(CGPoint)p1 point2:(CGPoint)p2{
    CGPoint v1 = CGPointMake(p1.x - centerPoint.x, p1.y - centerPoint.y);
	CGPoint v2 = CGPointMake(p2.x - centerPoint.x, p2.y - centerPoint.y);
	
	CGFloat angle = atan2f(v2.x*v1.y - v1.x*v2.y, v1.x*v2.x + v1.y*v2.y);
	
	return angle;
}
- (CGPoint)pointFromPoint:(CGPoint)origin withDistance:(float)distance towardAngle:(float)angle
{
    double radAngle = angle * M_PI / 180.0;
    return CGPointMake(origin.x + distance * cos(radAngle), origin.y + distance * sin(radAngle));
}

-(void)updateForDate:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dayString;
    NSString *timeString;
    if([self.delegate respondsToSelector:@selector(timePicker:titleForDate:)]) dayString = [self.delegate timePicker:self titleForDate:date];
    if(!dayString) dayString = [UtilityClass dayStringForDate:date];
    if([self.delegate respondsToSelector:@selector(timePicker:clockForDate:)]) timeString = [self.delegate timePicker:self clockForDate:date];
    if(!timeString) timeString = [[dateFormatter stringFromDate:date] lowercaseString];
    self.clockLabel.text = timeString;
    self.dayLabel.text = dayString;
    self.backgroundColor = [self colorForDate:date];
    if(self.hideIcons){
        return;
    }
}
-(UIColor *)colorForDate:(NSDate*)date{
    
    NSDate *startOfTheDay = [date dateAtStartOfDay];
    NSInteger minutesOfDayPassed = [date minutesAfterDate:startOfTheDay];
    BOOL overNoon = (minutesOfDayPassed > kMinutesInHalfDay);
    if(overNoon) minutesOfDayPassed = minutesOfDayPassed - kMinutesInHalfDay;
    CGFloat percentage = (CGFloat)minutesOfDayPassed / (CGFloat)kMinutesInHalfDay*100;
    UIColor *startColor = overNoon ? self.lightColor : self.darkColor;
    UIColor *endColor = overNoon ? self.darkColor : self.lightColor;
    return [startColor colorToColor:endColor percent:percentage];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hideIcons = YES;
        self.autoresizesSubviews = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.timeSlider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timepickerwheel"]];
        
        self.centerPoint = CGPointMake(self.bounds.size.width/2, self.bounds.size.height-self.timeSlider.frame.size.height/2-30);
        if(kIsIpad){
            self.centerPoint = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2 + self.timeSlider.frame.size.height/2);
        }
        self.lightColor = kDefLightColor;
        self.darkColor = kDefDarkColor;
        
        
        
        self.confirmButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
        self.confirmButton.backgroundColor = [UIColor clearColor];
        [self.confirmButton setBackgroundImage:[tcolor(DoneColor) image] forState:UIControlStateHighlighted];
        self.confirmButton.frame = CGRectMake(0, 0, 2*kDefActualSize, 2*kDefActualSize);
        
        //self.confirmButton.layer.borderWidth = LINE_SIZE;
        //self.confirmButton.layer.borderColor = tcolor(TextColor).CGColor;
        self.confirmButton.center = self.centerPoint;
        [self.confirmButton addTarget:self action:@selector(pressedConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
        self.confirmButton.titleLabel.font = iconFont(23);
        [self.confirmButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [self.confirmButton setTitle:iconString(@"done") forState:UIControlStateNormal];
        [self.confirmButton setTitleColor:tcolorF(TextColor,ThemeDark) forState:UIControlStateHighlighted];
        self.confirmButton.layer.masksToBounds = YES;
        self.confirmButton.layer.cornerRadius = kDefActualSize;
        [self addSubview:self.confirmButton];
        
        
        
        [self.timeSlider setHighlightedImage:[UIImage imageNamed:@"timepickerwheelselected"]];
        self.timeSlider.center = self.centerPoint;
        [self addSubview:self.timeSlider];
        
        self.backButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
        self.backButton.frame = CGRectMake(kBackMargin, self.bounds.size.height-kBackButtonSize-kBackMargin, kBackButtonSize, kBackButtonSize);
        self.backButton.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin);
        self.backButton.titleLabel.font = iconFont(41);
        [self.backButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [self.backButton setTitle:iconString(@"roundBack") forState:UIControlStateNormal];
        [self.backButton setTitle:iconString(@"roundBackFull") forState:UIControlStateHighlighted];
        [self.backButton addTarget:self action:@selector(pressedBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backButton];
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:panGestureRecognizer];
        
        self.dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 120)];
        self.dayLabel.backgroundColor = [UIColor clearColor];
        self.dayLabel.textColor = alpha(tcolor(TextColor),0.5);
        self.dayLabel.font = kDayLabelFont;
        self.dayLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.dayLabel];

        self.clockLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kClockLabelY, self.bounds.size.width, 120)];
        self.clockLabel.backgroundColor = [UIColor clearColor];
        self.clockLabel.textColor = alpha(tcolor(TextColor),0.8); //self.foregroundColor;
        self.clockLabel.font = kClockLabelFont;
        self.clockLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.clockLabel];
        [self setNeedsLayout];
        
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:@"willRotateToInterfaceOrientation"  object:nil];
        
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    if(!self.pickingDate) self.pickingDate = [NSDate date];
    else [self updateForDate:self.pickingDate];
    
    
    CGFloat heightForDay = sizeWithFont(@"abcdefghADB",self.dayLabel.font).height;
    CGFloat heightForTime = sizeWithFont(@"08:00pm",self.clockLabel.font).height;
    
    CGFloat totalHeightForLabels= heightForDay + kLabelSpacing + heightForTime;
    
    CGFloat imageStartY = (self.centerPoint.y - self.timeSlider.image.size.height/2);
    
    CGFloat spacing = (imageStartY - 20 - totalHeightForLabels)/2;
    
    CGFloat startY = imageStartY-totalHeightForLabels-MIN(spacing,100);
    self.dayLabel.frame = CGRectMake(0, startY, self.bounds.size.width, heightForDay);
    self.clockLabel.frame = CGRectMake(0, startY+heightForDay+kLabelSpacing, self.bounds.size.width, heightForTime);
    
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)orientationChanged:(NSNotification *)notification{
    
    [self pressedBackButton:self.backButton];
}
-(void)dealloc{
    self.confirmButton = nil;
    self.backButton = nil;
    self.timeSlider = nil;
    self.clockLabel = nil;
    clearNotify();
}

@end

