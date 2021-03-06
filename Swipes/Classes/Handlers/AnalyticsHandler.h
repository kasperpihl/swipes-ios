//
//  AnalyticsHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 06/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <Leanplum/Leanplum.h>

//DEFINE_VAR_BOOL(newOnboardingToggle, false); // iOS

#define kCusDimUserLevel 0

#define ANALYTICS [AnalyticsHandler sharedInstance]
@interface AnalyticsHandler : NSObject
+(AnalyticsHandler*)sharedInstance;
-(void)trackCategory:(NSString*)category action:(NSString*)action label:(NSString*)label value:(NSNumber*)value;
-(void)trackEvent:(NSString*)event options:(NSDictionary*)options;
-(void)pushView:(NSString*)view;
-(void)popView;
-(void)clearViews;
-(void)logout;
-(void)registerUser;
-(void)checkForUpdatesOnIdentity;
-(void)setHmac:(NSString*)hmac;
@property BOOL analyticsOff;
@end