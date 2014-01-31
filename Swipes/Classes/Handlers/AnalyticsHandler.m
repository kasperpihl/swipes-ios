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

@interface AnalyticsHandler ()
@property (nonatomic) NSMutableArray *views;
@property (nonatomic) Vero* vero;
@end
@implementation AnalyticsHandler
static AnalyticsHandler *sharedObject;
+(AnalyticsHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[AnalyticsHandler allocWithZone:NULL] init];
        if(kCurrent){
            [[LocalyticsSession shared] setCustomerId:kCurrent.objectId];
            if(kCurrent.email) [[LocalyticsSession shared] setCustomerEmail:kCurrent.email];
        }
    }
    return sharedObject;
}
-(Vero *)vero{
    if(!_vero){
        _vero = [Vero shared];
        [_vero setAuthToken:@"YmU3ZGNlMTBhOTAzZTJlMjRhMTJkZjFjODYyODE2YzZmZWFkMmRmNzphZmZiNjI1YWQ4YzY3YTU1NDA3Nzk4ZTZjMWY4OWZjNTAyZjU1NTQ4"];
        [_vero setDevelopmentMode:YES];
        [_vero setLogging:YES];
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
    [[LocalyticsSession shared] tagEvent:event attributes:options];
}
-(NSString *)customDimension:(NSInteger)dimension{
    return [[LocalyticsSession shared] customDimension:dimension];
}
-(void)setCustomDimension:(NSInteger)dimension value:(NSString *)value{
    [[LocalyticsSession shared] setCustomDimension:dimension value:value];
}

-(void)pushView:(NSString *)view{
    NSInteger viewsLeft = self.views.count;
    if(viewsLeft > 5) [self.views removeObjectAtIndex:0];
    [self.views addObject:view];
    [[LocalyticsSession shared] tagScreen:view];
}
-(void)popView{
    NSInteger viewsLeft = self.views.count;
    if(viewsLeft > 0) [self.views removeLastObject];
    if(viewsLeft > 1){
        [[LocalyticsSession shared] tagScreen:[self.views lastObject]];
    }
}
@end
