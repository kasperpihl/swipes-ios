//
//  AnalyticsHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 06/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "AnalyticsHandler.h"
#import "NSDate-Utilities.h"
#import "GAI.h"
#import "LocalyticsSession.h"
#import <Parse/PFUser.h>
@interface AnalyticsHandler ()
@property (nonatomic,strong) NSMutableDictionary *stats;
@property (nonatomic) BOOL runningSession;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSMutableArray *views;
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
-(NSMutableArray *)views{
    if(!_views) _views = [NSMutableArray array];
    return _views;
}
-(void)tagEvent:(NSString *)event options:(NSDictionary *)options{
    [[LocalyticsSession shared] tagEvent:event attributes:options];
}
-(NSMutableDictionary *)stats{
    if(!_stats) _stats = [NSMutableDictionary dictionary];
    return _stats;
}
-(NSInteger)amountForKey:(NSString*)key{
    NSNumber *value = [self.stats objectForKey:key];
    return [value integerValue];
}
-(NSArray*)keysArray{
    return @[NUMBER_OF_SCHEDULES_KEY,
             NUMBER_OF_COMPLETED_KEY,
             NUMBER_OF_ADDED_TASKS_KEY,
             NUMBER_OF_DELETED_TASKS_KEY,
             NUMBER_OF_REORDERED_TASKS_KEY,
             NUMBER_OF_UNSPECIFIED_TASKS_KEY,
             NUMBER_OF_ADDED_TAGS_KEY,
             NUMBER_OF_ASSIGNED_TAGS_KEY,
             NUMBER_OF_RESIGNED_TAGS_KEY,
             NUMBER_OF_ACTIONS_KEY
            ];
}
-(void)pushView:(NSString *)view{
    NSInteger viewsLeft = self.views.count;
    if(viewsLeft > 5) [self.views removeObjectAtIndex:0];
    [self.views addObject:view];
    [kGAnanlytics sendView:view];
    [[LocalyticsSession shared] tagScreen:view];
}
-(void)popView{
    NSInteger viewsLeft = self.views.count;
    if(viewsLeft > 0) [self.views removeLastObject];
    if(viewsLeft > 1){
        [[LocalyticsSession shared] tagScreen:[self.views lastObject]];
        [kGAnanlytics sendView:[self.views lastObject]];
    }
}
-(void)incrementKey:(NSString *)key withAmount:(NSInteger)amount{
    if(self.blockAnalytics) return;
    [self.stats setValue:[NSNumber numberWithInteger:[self amountForKey:key]+amount] forKey:key];
    [self.stats setValue:[NSNumber numberWithInteger:[self amountForKey:key]+amount] forKey:NUMBER_OF_ACTIONS_KEY];
}
-(void)startSession{
    if(self.runningSession) return;
    self.runningSession = YES;
    self.startDate = [NSDate date];
}
-(void)endSession{
    if(!self.runningSession) return;
    NSMutableDictionary *closedAppProperties = [NSMutableDictionary dictionary];
    NSInteger numberOfSecondsInSession = [[NSDate date] timeIntervalSinceDate:self.startDate];
    for(NSString *key in [self keysArray]){
        NSInteger value = [self amountForKey:key];
        // Disabled the people API
        [closedAppProperties setObject:[NSNumber numberWithInteger:value] forKey:key];
    }
    [closedAppProperties setObject:[NSNumber numberWithInteger:numberOfSecondsInSession] forKey:@"Session length (seconds)"];
    [MIXPANEL track:@"Session" properties:closedAppProperties];
    
    self.runningSession = NO;
    self.startDate = nil;
    self.stats = nil;
    
}
-(void)dealloc{
    if(self.runningSession) [self endSession];
}
@end
