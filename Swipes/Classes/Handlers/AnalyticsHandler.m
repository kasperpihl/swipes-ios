//
//  AnalyticsHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 06/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "AnalyticsHandler.h"
#import "NSDate-Utilities.h"
#import "LocalyticsSession.h"
#import <Parse/PFUser.h>
#import "Vero.h"
#import "UtilityClass.h"
#import "UserHandler.h"
#import "KeenClient.h"
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
    NSDate *lastHeartbeat = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastHeartBeat"];
    if(!lastHeartbeat || [lastHeartbeat daysBeforeDate:[NSDate date]] > 0){
        [self sendVeroEvent:@"Heartbeat" withData:nil];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastHeartBeat"];
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
        if([event isEqualToString:@"Heartbeat"] && error) [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastHeartBeat"];
    }];
}
-(NSMutableArray *)views{
    if(!_views) _views = [NSMutableArray array];
    return _views;
}
-(void)tagEvent:(NSString *)event options:(NSDictionary *)options{
    if(self.analyticsOff)
        return;
    return;
    [[LocalyticsSession shared] tagEvent:event attributes:options];
    NSError* error;
    [[KeenClient sharedClient] addEvent:options toEventCollection:event error:&error];
    if(error){
        NSLog(@"%@",error);
    }
}
-(NSString *)customDimension:(NSInteger)dimension{
    return [[LocalyticsSession shared] customDimension:(int)dimension];
}
-(void)setCustomDimension:(NSInteger)dimension value:(NSString *)value{
    [[LocalyticsSession shared] setCustomDimension:(int)dimension value:value];
}
-(void)updateIdentity{
    if(kCurrent){
        [[LocalyticsSession shared] setCustomerId:kCurrent.objectId];
        [[LocalyticsSession shared] setCustomerEmail:kCurrent.email];
    }
    NSString *userLevelString = [kUserHandler getUserLevelString];
    if(![[self customDimension:kCusDimUserLevel] isEqualToString:userLevelString]){
        [self setCustomDimension:kCusDimUserLevel value:userLevelString];
    }
//@"Language": [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:[[NSLocale currentLocale] identifier]],
    
    KeenClient *client = [KeenClient sharedClient];
    NSMutableDictionary *probs = [@{
        @"Platform": @"iOS",
        @"OS Version": [[UIDevice currentDevice] systemVersion],
        @"App Version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
        @"Country": [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]],
        @"Device": [[UIDevice currentDevice] model]
    } mutableCopy];
    //@"Language": [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:[[NSLocale currentLocale] identifier]],

    if(kCurrent){
        [probs setObject:[kUserHandler getUserLevelString] forKey:@"userLevel"];
        if(kCurrent.objectId)
            [probs setObject:kCurrent.objectId forKey:@"userId"];
        if(kCurrent.email)
            [probs setObject:kCurrent.email forKey:@"email"];
    }
    else{
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"isTryingOutSwipes"])
            [probs setObject:@"Is trying out" forKey:@"userLevel"];
        else
            [probs setObject:@"Not logged in" forKey:@"userLevel"];
    }
    client.globalPropertiesDictionary = [probs copy];
}
-(void)pushView:(NSString *)view{
    NSInteger viewsLeft = self.views.count;
    if(viewsLeft > 5)
        [self.views removeObjectAtIndex:0];
    [self.views addObject:view];
    [[LocalyticsSession shared] tagScreen:view];
}
-(void)popView{
    NSInteger viewsLeft = self.views.count;
    if(viewsLeft > 0)
        [self.views removeLastObject];
    if(viewsLeft > 1){
        [[LocalyticsSession shared] tagScreen:[self.views lastObject]];
    }
}
@end
