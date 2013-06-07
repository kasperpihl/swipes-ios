//
//  AnalyticsHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 06/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "AnalyticsHandler.h"
#import "NSDate-Utilities.h"
@interface AnalyticsHandler ()
@property (nonatomic,strong) NSMutableDictionary *stats;
@property (nonatomic) BOOL runningSession;
@property (nonatomic) NSDate *startDate;
@end
@implementation AnalyticsHandler
static AnalyticsHandler *sharedObject;
+(AnalyticsHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[AnalyticsHandler allocWithZone:NULL] init];
    }
    return sharedObject;
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
             NUMBER_OF_UNSPECIFIED_TASKS
            ];
}
-(void)incrementKey:(NSString *)key withAmount:(NSInteger)amount{
    [self.stats setValue:[NSNumber numberWithInteger:[self amountForKey:key]+amount] forKey:key];
}
-(void)startSession{
    if(self.runningSession) return;
    self.runningSession = YES;
    self.startDate = [NSDate date];
}
-(void)endSession{
    if(!self.runningSession) return;
    NSMutableDictionary *closedAppProperties = [NSMutableDictionary dictionary];
    for(NSString *key in [self keysArray]){
        NSInteger value = [self amountForKey:key];
        [MIXPANEL.people increment:key by:[NSNumber numberWithInteger:value]];
        [closedAppProperties setObject:[NSNumber numberWithInteger:value] forKey:key];
    }
    NSInteger numberOfSecondsInSession = [[NSDate date] timeIntervalSinceDate:self.startDate];
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
