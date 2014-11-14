//
//  KPTopClock.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 13/11/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
typedef enum {
    TopClockStateNone = 0,
    TopClockStateClock,
    TopClockStateNotification,
    TopClockStateRealStatusBar
} TopClockState;

#import "KPTopClock.h"
@interface KPTopClock ()

@property (nonatomic) UIView *view;
@property (nonatomic) UIButton *tapButton;
@property (nonatomic) UILabel *clockLabel;
@property (nonatomic) UILabel *notificationLabel;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) TopClockState currentState;
@property (nonatomic) BOOL lock;
@end

@implementation KPTopClock
static KPTopClock *sharedObject;
+(KPTopClock *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[KPTopClock alloc] init];
        [sharedObject addTopClock];
    }
    return sharedObject;
}
-(NSDateFormatter *)dateFormatter{
    if(!_dateFormatter){
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
        [_dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [_dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return _dateFormatter;
}

-(void)setCurrentState:(TopClockState)currentState{
    [self setCurrentState:currentState animated:NO];
}
-(void)setCurrentState:(TopClockState)currentState animated:(BOOL)animated{
    
    voidBlock beforeBlock = ^{
        if(currentState == TopClockStateRealStatusBar || _currentState == TopClockStateRealStatusBar || _currentState == TopClockStateNone){
            if(animated){
                [[UIApplication sharedApplication] setStatusBarHidden:(currentState != TopClockStateRealStatusBar) withAnimation:UIStatusBarAnimationSlide];
            }
            else{
                [[UIApplication sharedApplication] setStatusBarHidden:(currentState != TopClockStateRealStatusBar)];
            }
        }
        if(currentState == TopClockStateNotification || _currentState == TopClockStateNotification){
            self.lock = (currentState == TopClockStateNotification);
        }
    };
    
    voidBlock showBlock = ^{
        
        if(currentState == TopClockStateRealStatusBar || _currentState == TopClockStateRealStatusBar){
            self.view.alpha = (currentState == TopClockStateRealStatusBar) ? 0 : 1;
        }
        if(currentState == TopClockStateNotification){
            [self.tapButton setTitle:self.notificationLabel.text forState:UIControlStateNormal];
        }
        if(_currentState == TopClockStateNotification){
            [self updateClock];
        }
    };
    
    voidBlock completionBlock = ^{
    
    };
    
    if(!animated){
        beforeBlock();
        showBlock();
        completionBlock();
    }
    else{
        beforeBlock();
        [UIView animateWithDuration:0.3 animations:showBlock completion:^(BOOL finished) {
            completionBlock();
        }];
    }
    
    _currentState = currentState;

}


-(void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    [self.tapButton setTitleColor:textColor forState:UIControlStateNormal];
}
-(void)setFont:(UIFont *)font{
    _font = font;
    [self.tapButton.titleLabel setFont:font];
}


-(void)addTopClock{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, window.frame.size.width, 20)];
    self.clockLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    self.notificationLabel = [[UILabel alloc] initWithFrame:self.view.bounds];

    self.tapButton = [[UIButton alloc] initWithFrame:self.view.bounds];

    
    self.tapButton.autoresizingMask = self.clockLabel.autoresizingMask = self.notificationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.tapButton addTarget:self action:@selector(onTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.tapButton];
    
    [window addSubview:self.view];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClock) userInfo:nil repeats:YES];
    [self setCurrentState:TopClockStateClock];
    [self updateClock];
}

-(void)onTap:(UIButton*)sender{
    if(self.currentState == TopClockStateNotification){
        [self setCurrentState:TopClockStateClock animated:YES];
    }else{
        [self setCurrentState:TopClockStateRealStatusBar animated:YES];
        [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(showBack) userInfo:nil repeats:NO];
    }
}

-(void)updateClock{
    if(self.lock)
        return;
    [self.tapButton setTitle:[self.dateFormatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
}

-(void)showBack{
    [self setCurrentState:TopClockStateClock animated:YES];
}
-(void)showNotificationWithMessage:(NSString *)message forSeconds:(CGFloat)seconds{
    self.notificationLabel.text = message;
    [self setCurrentState:TopClockStateNotification animated:YES];
    [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(showBack) userInfo:nil repeats:NO];
}



-(void)dealloc{
    self.view = nil;
    self.tapButton = nil;
}
@end
