//
//  AnalyticsHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 06/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kCusDimUserLevel 0

#define ANALYTICS [AnalyticsHandler sharedInstance]
@interface AnalyticsHandler : NSObject
+(AnalyticsHandler*)sharedInstance;
-(void)trackEvent:(NSString*)event info:(NSString*)info value:(double)value parameters:(NSDictionary*)parameters;
-(void)tagEvent:(NSString*)event options:(NSDictionary*)options;
-(void)pushView:(NSString*)view;
-(void)popView;
-(void)heartbeat;
-(void)updateIdentity;
@property BOOL analyticsOff;
@end