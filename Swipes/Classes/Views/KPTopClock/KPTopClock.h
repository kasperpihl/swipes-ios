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

@property (nonatomic) UIFont *font;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) NSDateFormatter *dateFormatter;
+(KPTopClock*)sharedInstance;

-(void)showNotificationWithMessage:(NSString*)message forSeconds:(CGFloat)seconds;
@end
