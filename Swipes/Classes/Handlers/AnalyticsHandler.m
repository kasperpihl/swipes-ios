//
//  AnalyticsHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 06/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "AnalyticsHandler.h"
#import "NSDate-Utilities.h"
#import <Parse/PFUser.h>
//#import <Leanplum/Leanplum.h>
#import "Vero.h"
#import "UtilityClass.h"
#import "UserHandler.h"
#import "EvernoteIntegration.h"

@interface AnalyticsHandler ()
@property (nonatomic) NSMutableArray *views;
@property (nonatomic) Vero* vero;
@end
@implementation AnalyticsHandler
static AnalyticsHandler *sharedObject;
+(AnalyticsHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[AnalyticsHandler allocWithZone:NULL] init];
        [sharedObject updateIdentity];
    }
    return sharedObject;
}
-(Vero *)vero{
    if(!_vero){
        _vero = [Vero shared];
        [_vero setAuthToken:@"YmU3ZGNlMTBhOTAzZTJlMjRhMTJkZjFjODYyODE2YzZmZWFkMmRmNzphZmZiNjI1YWQ4YzY3YTU1NDA3Nzk4ZTZjMWY4OWZjNTAyZjU1NTQ4"];
        [_vero setDevelopmentMode:YES];
#ifdef RELEASE
        [_vero setDevelopmentMode:NO];
#endif
    }
    return _vero;
}
-(void)heartbeat{
    NSDate *lastHeartbeat = [USER_DEFAULTS objectForKey:@"lastHeartBeat"];
    if(!lastHeartbeat || [lastHeartbeat daysBeforeDate:[NSDate date]] > 0){
        [self sendVeroEvent:@"Heartbeat" withData:nil];
        [USER_DEFAULTS setObject:[NSDate date] forKey:@"lastHeartBeat"];
    }
}
-(void)sendVeroEvent:(NSString*)event withData:(NSDictionary*)data{
    NSString *email = kCurrent.email;
    if(!email) email = kCurrent.username;
    if(![UtilityClass validateEmail:email]) return;
    NSNumber *userLevel = [kCurrent objectForKey:@"userLevel"];
    if(!userLevel) userLevel = [NSNumber numberWithInteger:0];
    NSDictionary *identity = @{@"id":kCurrent.objectId,@"email":email,@"userlevel":userLevel};
    [self.vero eventsTrack:event identity:identity data:data completionHandler:^(id result, NSError *error) {
        if([event isEqualToString:@"Heartbeat"] && error) [USER_DEFAULTS removeObjectForKey:@"lastHeartBeat"];
    }];
}
-(NSMutableArray *)views{
    if(!_views) _views = [NSMutableArray array];
    return _views;
}
-(void)trackEvent:(NSString *)event info:(NSString *)info value:(double)value parameters:(NSDictionary *)parameters{
    //[Leanplum track:event withValue:value andInfo:info
      //andParameters:parameters];
}
-(void)trackEvent:(NSString *)event options:(NSDictionary *)options{
    if(self.analyticsOff)
        return;
    //[Leanplum track:event withParameters:options];
    //[[LocalyticsSession shared] tagEvent:event attributes:options];
}
-(NSString *)customDimension:(NSInteger)dimension{
    //return [[LocalyticsSession shared] customDimension:(int)dimension];
    return nil;
}
-(void)setCustomDimension:(NSInteger)dimension value:(NSString *)value{
    //[[LocalyticsSession shared] setCustomDimension:(int)dimension value:value];
}
-(void)updateIdentity{
    NSString *userLevel = @"None";
    if(kCurrent){
        //[Leanplum setUserId:kCurrent.objectId];
        //[[LocalyticsSession shared] setCustomerId:kCurrent.objectId];
        //[[LocalyticsSession shared] setCustomerEmail:kCurrent.email];
        userLevel = @"User";
        if([kUserHandler isPlus])
            userLevel = @"Plus";
    }
    else if([kUserHandler isTryingOutApp]){
        userLevel = @"Tryout";
    }
    
    NSMutableDictionary *userAttributes = [@{} mutableCopy];
    
    NSString *currentTheme = ([THEMER currentTheme] == ThemeDark) ? @"Dark" : @"Light";
    [userAttributes setObject:currentTheme forKey:@"Active Theme"];
    
    if(kCurrent.email)
        [userAttributes setObject:kCurrent.email forKey:@"Email"];
    
    NSString *evernoteUserLevel = @"Not Installed";
    if([USER_DEFAULTS boolForKey:@"isEvernoteInstalled"])
        evernoteUserLevel = @"Not Linked";
    if(kEnInt.isAuthenticated){
        evernoteUserLevel = @"Standard";
        if(kEnInt.isPremiumUser)
            evernoteUserLevel = @"Premium";
        if(kEnInt.isBusinessUser)
            evernoteUserLevel = @"Business";
    }
    [userAttributes setObject:evernoteUserLevel forKey:@"Evernote User Level"];
    
}
-(void)pushView:(NSString *)view{
    NSInteger viewsLeft = self.views.count;
    if(viewsLeft > 5)
        [self.views removeObjectAtIndex:0];
    [self.views addObject:view];
    //[Leanplum advanceTo:view];
}
-(void)popView{
    NSInteger viewsLeft = self.views.count;
    if(viewsLeft > 0)
        [self.views removeLastObject];
    if(viewsLeft > 1){
        //[Leanplum advanceTo:[self.views lastObject]];
    }
}
-(void)clearViews{
    [self.views removeAllObjects];
    //[Leanplum advanceTo:nil];
}
@end
