//
//  KPTopClock.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 13/11/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "KPTopClock.h"
@interface KPTopClock ()
@property (nonatomic) UIView *view;
@property (nonatomic) UIButton *tapButton;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) BOOL isShowingRealStatusBar;
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


-(void)setIsShowingRealStatusBar:(BOOL)isShowingRealStatusBar{
    [self setIsShowingRealStatusBar:isShowingRealStatusBar animated:NO];
}

-(void)setIsShowingRealStatusBar:(BOOL)isShowingRealStatusBar animated:(BOOL)animated{
    _isShowingRealStatusBar = isShowingRealStatusBar;
    if(animated){
        [[UIApplication sharedApplication] setStatusBarHidden:!isShowingRealStatusBar withAnimation:UIStatusBarAnimationSlide];
        [UIView animateWithDuration:0.3 animations:^{
            self.view.alpha = isShowingRealStatusBar ? 0 : 1;
        }];
    }
    else{
        self.view.alpha = isShowingRealStatusBar ? 0 : 1;
        [[UIApplication sharedApplication] setStatusBarHidden:!isShowingRealStatusBar];
    }
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
    
    self.tapButton = [[UIButton alloc] initWithFrame:self.view.bounds];
    self.tapButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    self.tapButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.tapButton addTarget:self action:@selector(onTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.tapButton];
    
    [window addSubview:self.view];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClock) userInfo:nil repeats:YES];
    self.isShowingRealStatusBar = NO;
    [self updateClock];
}

-(void)onTap:(UIButton*)sender{
    [self hideForSeconds:3];
}

-(void)updateClock{
    [self.tapButton setTitle:[self.dateFormatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
}

-(void)hideForSeconds:(CGFloat)seconds{
    [self setIsShowingRealStatusBar:YES animated:YES];
    [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(showBack) userInfo:nil repeats:NO];
}
-(void)showBack{
    [self setIsShowingRealStatusBar:NO animated:YES];
}
-(void)showRealTopForSeconds:(CGFloat)seconds{
    
}
-(void)dealloc{
    self.view = nil;
    self.tapButton = nil;
}
@end
