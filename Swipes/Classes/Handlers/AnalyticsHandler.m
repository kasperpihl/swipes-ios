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
@interface AnalyticsHandler ()
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
