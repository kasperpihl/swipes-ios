//
//  TimerClass.m
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "TimerClass.h"
@interface TimerClass ()
@property (nonatomic,strong) NSTimer *timer;
@end

@implementation TimerClass
@synthesize 
timer = _timer,
delegate = _delegate;
-(void)setDelegate:(NSObject<TimerDelegate> *)delegate{
    if(!delegate) [self removeTimer];
    _delegate = delegate;
    
}
static TimerClass *sharedObject;
+(TimerClass *)sharedInstance{
    if(!sharedObject) sharedObject = [[TimerClass allocWithZone:NULL] init];
    return sharedObject;
}
-(void)startTimerWithInterval:(NSTimeInterval)interval andDelegate:(NSObject<TimerDelegate> *)delegate{
    [self removeTimer];
    self.delegate = delegate;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                              target:self 
                                                            selector:@selector(autoTimerFired:) 
                                                            userInfo:nil 
                                                             repeats:YES];
}
-(void)autoTimerFired:(id)sender{
    if([self.delegate respondsToSelector:@selector(didRunTimer:)]){
        [self.delegate didRunTimer:self];
    }
}
-(void)removeTimer{
    if(self.timer){ 
        [self.timer invalidate];
        self.timer = nil;
    }
}
@end
