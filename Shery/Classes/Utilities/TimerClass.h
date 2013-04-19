//
//  TimerClass.h
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TimerClass;
@protocol TimerDelegate
-(void)didRunTimer:(id)sender;
@end
@interface TimerClass : NSObject
@property (nonatomic,weak) NSObject<TimerDelegate> *delegate;
#define TIMER_CLASS [TimerClass sharedInstance]
+(TimerClass *)sharedInstance;
-(void)startTimerWithInterval:(NSTimeInterval)interval andDelegate:(NSObject<TimerDelegate> *)delegate;
@end
