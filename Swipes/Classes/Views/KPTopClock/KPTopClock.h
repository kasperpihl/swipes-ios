//
//  KPTopClock.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 13/11/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kTopClock [KPTopClock sharedInstance]

typedef enum {
    TopClockStateNone = 0,
    TopClockStateClock,
    TopClockStateNotification,
    TopClockStateRealStatusBar
} TopClockState;

@interface KPTopClock : NSObject

+(instancetype)sharedInstance;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

-(void)addTopClock;
-(void)showNotificationWithMessage:(NSString*)message forSeconds:(CGFloat)seconds;
-(void)pushClockToView:(UIView *)view;
-(void)popClock;
-(void)setCurrentState:(TopClockState)currentState animated:(BOOL)animated;

@end
