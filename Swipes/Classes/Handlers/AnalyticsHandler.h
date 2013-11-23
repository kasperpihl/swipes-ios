//
//  AnalyticsHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 06/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define NUMBER_OF_SCHEDULES_KEY         @"Number of schedules"
#define NUMBER_OF_COMPLETED_KEY         @"Number of completions"
#define NUMBER_OF_ADDED_TASKS_KEY       @"Number of added tasks"
#define NUMBER_OF_DELETED_TASKS_KEY     @"Number of deleted tasks"
#define NUMBER_OF_REORDERED_TASKS_KEY   @"Number of reordered tasks"
#define NUMBER_OF_UNSPECIFIED_TASKS_KEY @"Number of unspecified tasks"
#define NUMBER_OF_ADDED_TAGS_KEY        @"Number of added tags"
#define NUMBER_OF_ASSIGNED_TAGS_KEY     @"Number of assigned tags"
#define NUMBER_OF_RESIGNED_TAGS_KEY     @"Number of resigned tags"
#define NUMBER_OF_ACTIONS_KEY           @"Number of actions"

#import <Foundation/Foundation.h>


#define ANALYTICS [AnalyticsHandler sharedInstance]
@interface AnalyticsHandler : NSObject
@property (nonatomic) BOOL blockAnalytics;
+(AnalyticsHandler*)sharedInstance;
-(NSInteger)amountForKey:(NSString*)key;
-(void)incrementKey:(NSString*)key withAmount:(NSInteger)amount;
-(void)tagEvent:(NSString*)event options:(NSDictionary*)options;
-(void)startSession;
-(void)endSession;
-(void)pushView:(NSString*)view;
-(void)popView;
@end
