//
//  KPTimePicker.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define TIME_VIEWER_LABEL_TAG 9
#define TIME_SLIDER_TAG 10
#define TIME_VIEWER_TAG 8
#define kMinutesInDay 1440
#define kMinutesInHalfDay 720

#define kDefWheelRadius valForScreen(120,135)
#define kExtraWheelRadius valForScreen(15,20)


#define kSunImageDistance valForScreen(200, 230)
#define kLabelSpacing valForScreen(0,0)
#define kClockLabelY valForScreen(0,0)
#define kClockLabelFont KP_EXTRABOLD(valForScreen(46,52))
#define kDayLabelFont KP_REGULAR(valForScreen(16,19))
#define kDefMiddleButtonRadius 60
#define kDefClearMiddle 45

#define kOpenedSunAngle valForScreen(70,60)
#define kExtraAngleForIcons 5

#define kDefWheelColor          [UIColor whiteColor]
#define kDefForegroundColor     tbackground(MenuBackground) //tcolor(LaterColor)
#define kDefWheelBackgroundColor tbackground(TimePickerWheelBackground)
#define kDefLightColor          tbackground(TaskTableGradientBackground) //tcolor(SearchDrawerColor)
#define kDefDarkColor           tbackground(SearchDrawerBackground)

#define kEndAngle               (360-(90-kOpenedSunAngle/2) + kExtraAngleForIcons)
#define kStartAngle             (kEndAngle- kOpenedSunAngle - 2*kExtraAngleForIcons)

#define kAngleSpan              (kEndAngle-kStartAngle)
#define kSunRiseMinutes         5*60
#define kSunSetMinutes          19*60
#define kSunSpan                (kSunSetMinutes - kSunRiseMinutes)
#define kMoonRiseMinutes        17*60
#define kMoonRiseSpan           (kMinutesInDay - kMoonRiseMinutes)
#define kMoonSetMinutes         7*60
#define kMoonSetSpan            (kMoonSetMinutes)
#define kGlowShowHack           0.4
#define kGlowMiddleShowHack     0.12
#define kGlowAnimationDuration  0.2f
#define kBackButtonSize         52

#import <QuartzCore/QuartzCore.h>
#import "KPTimePicker.h"
#import "NSDate-Utilities.h"
#import "UtilityClass.h"
#import "UIColor+Utilities.h"
@class KPTimePicker;
@interface _KPTimePickerForeGroundView : UIView

@property (nonatomic) KPTimePicker *timePicker;
-(id)initWithFrame:(CGRect)frame timePicker:(KPTimePicker *)timePicker;
@end

@implementation _KPTimePickerForeGroundView
-(id)initWithFrame:(CGRect)frame timePicker:(KPTimePicker *)timePicker{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        self.timePicker = timePicker;
    }
    return self;
}
-(CGFloat)calculateHeightForAngle:(CGFloat)angle{
    CGFloat radians = radians(angle);
    CGFloat newHeight = (self.bounds.size.width/2)/tanf(radians);
    return newHeight;
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGFloat backCircleSize = 2*self.timePicker.wheelRadius + 2*kExtraWheelRadius;
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.timePicker.centerPoint.x-backCircleSize/2, self.timePicker.centerPoint.y-backCircleSize/2, backCircleSize, backCircleSize)];
    
    CGContextAddPath(currentContext, circlePath.CGPath);
    CGContextSetFillColorWithColor(currentContext,self.timePicker.wheelBackgroundColor.CGColor);
    CGContextFillPath(currentContext);
    
    CGFloat angledYTopCoordinate = self.timePicker.centerPoint.y - [self calculateHeightForAngle:kOpenedSunAngle/2];
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    [aPath moveToPoint:self.timePicker.centerPoint];
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    [aPath addLineToPoint:CGPointMake(0, angledYTopCoordinate)];
    [aPath addLineToPoint:CGPointMake(0, height)];
    [aPath addLineToPoint:CGPointMake(width, height)];
    [aPath addLineToPoint:CGPointMake(width, angledYTopCoordinate)];
    [aPath closePath];
    CGContextAddPath(currentContext, aPath.CGPath);
    CGContextSetFillColorWithColor(currentContext,self.timePicker.foregroundColor.CGColor);
    CGContextFillPath(currentContext);
    
    UIBezierPath *wheelPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.timePicker.centerPoint.x-self.timePicker.wheelRadius, self.timePicker.centerPoint.y-self.timePicker.wheelRadius, 2*self.timePicker.wheelRadius, 2*self.timePicker.wheelRadius)];
    
    CGContextAddPath(currentContext, wheelPath.CGPath);
    CGContextSetFillColorWithColor(currentContext,self.timePicker.wheelColor.CGColor);
    CGContextFillPath(currentContext);
    
    UIBezierPath *confirmButtonPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.timePicker.centerPoint.x-self.timePicker.middleRadius, self.timePicker.centerPoint.y-self.timePicker.middleRadius, 2*self.timePicker.middleRadius, 2*self.timePicker.middleRadius)];
    
    CGContextAddPath(currentContext, confirmButtonPath.CGPath);
    CGContextSetFillColorWithColor(currentContext,self.timePicker.foregroundColor.CGColor);
    CGContextFillPath(currentContext);
}

@end


@interface KPTimePicker () <UIGestureRecognizerDelegate>
@property (nonatomic) CGPoint lastPosition;
@property (nonatomic) CGFloat lastChangedAngle;
@property (nonatomic) CGFloat distanceForIcons;
@property (nonatomic) BOOL isInConfirmButton;
@property (nonatomic) BOOL isOutOfScope;

@property (nonatomic,strong) UIImageView *timeSlider;
@property (nonatomic,strong) UIButton *confirmButton;
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UIImageView *sunImage;
@property (nonatomic,strong) UIImageView *moonImage;
@property (nonatomic,strong) _KPTimePickerForeGroundView *foregroundView;
@property (nonatomic,strong) UILabel *dayLabel;
@property (nonatomic,strong) UILabel *clockLabel;
@end
@implementation KPTimePicker
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
-(void)didWaitInMiddle{
    if(self.isOutOfScope){
        [UIView animateWithDuration:kGlowAnimationDuration animations:^{
            self.confirmButton.backgroundColor = tcolor(DoneColor);
        }];
    }
}
-(void)didWaitDelay{
    
    [UIView animateWithDuration:kGlowAnimationDuration animations:^{
        self.confirmButton.backgroundColor = self.isInConfirmButton ? tcolor(DoneColor) : kDefForegroundColor;
    }];
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
    self.isInConfirmButton = (distanceToMiddle < self.middleRadius);
    self.isOutOfScope = (distanceToMiddle < kDefClearMiddle);
    if (sender.state == UIGestureRecognizerStateChanged || sender.state == UIGestureRecognizerStateBegan) {
        if(!self.isOutOfScope){
            CGPoint sliderStartPoint = self.lastPosition;// CGPointMake(self.centerPoint.x, self.centerPoint.y - 100.0);
            if(CGPointEqualToPoint(self.lastPosition, CGPointZero)) sliderStartPoint = location;
            CGFloat angle = [self angleBetweenCenterPoint:self.centerPoint point1:sliderStartPoint point2:location];
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
        self.lastPosition = CGPointZero;
        self.lastChangedAngle = 0;
        self.confirmButton.backgroundColor = CLEAR;
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
    self.clockLabel.text =  [[dateFormatter stringFromDate:date] lowercaseString];
    self.dayLabel.text = [UtilityClass dayStringForDate:date];
    self.backgroundColor = [self colorForDate:date];
    BOOL hiddenSun = YES;
    CGFloat sunAngle = 0;
    NSInteger minutesOfDayPassed = [date minutesAfterDate:[date dateAtStartOfDay]];
    if(minutesOfDayPassed > kSunRiseMinutes && minutesOfDayPassed < kSunSetMinutes){
        hiddenSun = NO;
        NSInteger minutesSinceSunrise = minutesOfDayPassed - kSunRiseMinutes;
        CGFloat percentageOfSun = (CGFloat)minutesSinceSunrise / kSunSpan;
        sunAngle = percentageOfSun * kAngleSpan + kStartAngle;
    }
    self.sunImage.hidden = hiddenSun;
    
    BOOL hiddenMoon = YES;
    CGFloat moonAngle = 0;
    
    if(minutesOfDayPassed > kMoonRiseMinutes){
        hiddenMoon = NO;
        NSInteger minutesSinceMoonrise = minutesOfDayPassed - kMoonRiseMinutes;
        CGFloat percentageOfMoonRise = (CGFloat)minutesSinceMoonrise / kMoonRiseSpan;
        moonAngle = percentageOfMoonRise * (kAngleSpan/2) + (kStartAngle);
    }
    else if(minutesOfDayPassed < kMoonSetMinutes){
        hiddenMoon = NO;
        CGFloat minutesFloat = (CGFloat)minutesOfDayPassed;
        CGFloat percentageOfMoonSet = minutesFloat/(CGFloat)kMoonSetSpan;
        
        moonAngle = percentageOfMoonSet * (kAngleSpan/2) + (kStartAngle + (kAngleSpan/2));
        //NSLog(@"moonangle:%f",moonAngle);
    }
    if(!hiddenSun){
        self.sunImage.center = [self pointFromPoint:self.centerPoint withDistance:self.distanceForIcons towardAngle:sunAngle];
    }
    if(!hiddenMoon){
        self.moonImage.center = [self pointFromPoint:self.centerPoint withDistance:self.distanceForIcons towardAngle:moonAngle];
    }
    self.moonImage.hidden = hiddenMoon;
}
-(void)setDistanceForIcons:(CGFloat)distanceForIcons{
    _distanceForIcons = distanceForIcons;
    CGFloat calcMoonAngle = 360 - degrees([self angleBetweenCenterPoint:self.centerPoint point1:CGPointMake(self.centerPoint.x+100, self.centerPoint.y) point2:self.moonImage.center]);
    CGFloat calcSunAngle = 360 - degrees([self angleBetweenCenterPoint:self.centerPoint point1:CGPointMake(self.centerPoint.x+100, self.centerPoint.y) point2:self.sunImage.center]);
    self.moonImage.center = [self pointFromPoint:self.centerPoint withDistance:distanceForIcons towardAngle:calcMoonAngle];
    self.sunImage.center = [self pointFromPoint:self.centerPoint withDistance:distanceForIcons towardAngle:calcSunAngle];
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
        self.centerPoint = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/3*2);
        self.foregroundColor = kDefForegroundColor;
        self.wheelBackgroundColor = kDefWheelBackgroundColor;
        self.distanceForIcons = kSunImageDistance;
        self.wheelColor = kDefWheelColor;
        self.wheelRadius = kDefWheelRadius;
        self.middleRadius = kDefMiddleButtonRadius;
        self.lightColor = kDefLightColor;
        self.darkColor = kDefDarkColor;
        
        
        self.moonImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"schedule_image_moon"]];
        self.moonImage.center = [self pointFromPoint:self.centerPoint withDistance:kSunImageDistance towardAngle:235];
        [self addSubview:self.moonImage];
        
        self.sunImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"schedule_image_sun"]];
        self.sunImage.center = [self pointFromPoint:self.centerPoint withDistance:kSunImageDistance towardAngle:305];
        [self addSubview:self.sunImage];

        
        self.foregroundView = [[_KPTimePickerForeGroundView alloc] initWithFrame:self.bounds timePicker:self];
        [self addSubview:self.foregroundView];
        
        self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.confirmButton.backgroundColor = [UIColor clearColor];
        [self.confirmButton setBackgroundImage:[tcolor(DoneColor) image] forState:UIControlStateHighlighted];
        self.confirmButton.frame = CGRectMake(0, 0, 2*self.middleRadius, 2*self.middleRadius);
        self.confirmButton.center = self.centerPoint;
        [self.confirmButton addTarget:self action:@selector(pressedConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.confirmButton setImage:[UIImage imageNamed:@"done-selected"] forState:UIControlStateNormal];
        [self.confirmButton setImage:[UIImage imageNamed:@"done-selected"] forState:UIControlStateHighlighted];
        self.confirmButton.layer.masksToBounds = YES;
        self.confirmButton.layer.cornerRadius = self.middleRadius;
        [self addSubview:self.confirmButton];
        
        self.timeSlider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_wheel"]];
        self.timeSlider.center = self.centerPoint;
        [self addSubview:self.timeSlider];
        
        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.backButton.frame = CGRectMake(0, self.bounds.size.height-kBackButtonSize, kBackButtonSize, kBackButtonSize);
        self.backButton.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin);
        [self.backButton setImage:[UIImage imageNamed:@"back_icon_white"] forState:UIControlStateNormal];
        self.backButton.imageEdgeInsets = UIEdgeInsetsMake(3, 0, 0, 0);
        [self.backButton addTarget:self action:@selector(pressedBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backButton];
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:panGestureRecognizer];
        
        self.dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 120)];
        self.dayLabel.backgroundColor = [UIColor clearColor];
        self.dayLabel.textColor = [UIColor whiteColor];
        self.dayLabel.font = kDayLabelFont;
        self.dayLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:self.dayLabel];

        self.clockLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kClockLabelY, self.bounds.size.width, 120)];
        self.clockLabel.backgroundColor = [UIColor clearColor];
        self.clockLabel.textColor = [UIColor whiteColor]; //self.foregroundColor;
        self.clockLabel.font = kClockLabelFont;
        self.clockLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:self.clockLabel];
        self.pickingDate = [NSDate date];
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat heightForContent = self.centerPoint.y - self.wheelRadius - kExtraWheelRadius;
    
    
    CGFloat heightForDay = [@"abcdefghADB" sizeWithFont:self.dayLabel.font].height;
    CGFloat heightForTime = [@"08:00pm" sizeWithFont:self.clockLabel.font].height;
    CGFloat iconHeigt = self.sunImage.image.size.height;
    
    CGFloat overflowSpace = heightForContent - heightForDay - kLabelSpacing - heightForTime - iconHeigt;
    CGFloat spacing = overflowSpace / 6;
    
    self.dayLabel.frame = CGRectMake(0, spacing, self.bounds.size.width, heightForDay);
    self.clockLabel.frame = CGRectMake(0, spacing+heightForDay+kLabelSpacing, self.bounds.size.width, heightForTime);
    
    self.distanceForIcons = self.wheelRadius + kExtraWheelRadius + spacing*4 + iconHeigt/2;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
-(void)dealloc{
    self.confirmButton = nil;
    self.backButton = nil;
    self.foregroundView = nil;
    self.timeSlider = nil;
    self.sunImage = nil;
    self.moonImage = nil;
    self.clockLabel = nil;
}

@end

