//
//  KPTopClock.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 13/11/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTopClock [KPTopClock sharedInstance]
@interface KPTopClock : NSObject

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
+(KPTopClock*)sharedInstance;
-(void)addTopClock;
-(void)showNotificationWithMessage:(NSString*)message forSeconds:(CGFloat)seconds;
- (void)pushClockToView:(UIView *)view;
- (void)popClock;

@end
