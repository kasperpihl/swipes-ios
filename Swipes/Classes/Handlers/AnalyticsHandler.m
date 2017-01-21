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
#import "Vero.h"
#import "UtilityClass.h"
#import "KPToDo.h"
#import "KPTag.h"
#import "UserHandler.h"
#import "EvernoteIntegration.h"
#import "GmailIntegration.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface AnalyticsHandler ()
@property (nonatomic) NSMutableArray *views;
@property (nonatomic) BOOL intercomSession;
@end
@implementation AnalyticsHandler
static AnalyticsHandler *sharedObject;
+(AnalyticsHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[AnalyticsHandler allocWithZone:NULL] init];
        [sharedObject initialize];
        
    }
    return sharedObject;
}
-(void)initialize{
}

-(void)logout{
    [self clearViews];
}

-(NSMutableArray *)views{
    if(!_views) _views = [NSMutableArray array];
    return _views;
}
-(void)trackCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value{
    if(self.analyticsOff)
        return;
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:value] build]];
}
-(void)trackEvent:(NSString *)event options:(NSDictionary *)options{
    if(self.analyticsOff)
        return;
}

-(void)checkForUpdatesOnIdentity{
    id tracker = [[GAI sharedInstance] defaultTracker];
    NSDictionary *current = [USER_DEFAULTS objectForKey:@"identityValues"];
    if(!current)
        current = [NSDictionary dictionary];
    NSMutableDictionary *currentValues = [current mutableCopy];
    if(!currentValues){
        currentValues = [NSMutableDictionary dictionary];
    }
    
    __block BOOL shouldUpdate = NO;
    BOOL gaUpdate = NO;
    
    GAIDictionaryBuilder *gaCustomBuilder = [GAIDictionaryBuilder createEventWithCategory:@"Session" action:@"Updated Identity" label:nil value:nil];
    
    
    // User ID Checking
    NSString *currentUserId = [currentValues objectForKey:@"userId"];
    NSString *userId = kCurrent.objectId;
    if(userId && ![userId isEqualToString:currentUserId]){
        gaUpdate = YES;
        shouldUpdate = YES;
        [currentValues setObject:userId forKey:@"userId"];
    }
    if(userId){
        [tracker set:@"&uid"
           value:userId];
    }
    
    // Email Checking
    NSString *currentEmail = [currentValues objectForKey:@"email"];
    NSString *email;
    if(kCurrent.username && [UtilityClass validateEmail:kCurrent.username])
        email = kCurrent.username;
    if(kCurrent.email && [UtilityClass validateEmail:kCurrent.email])
        email = kCurrent.email;
    
    
    if(email && ![email isEqualToString:currentEmail]){
        shouldUpdate = YES;
        [currentValues setObject:email forKey:@"email"];
    }

    
    
    
    // Signup date
    NSString *currentSignupDate = [currentValues objectForKey:@"signup_date"];
    if(kCurrent.createdAt){
        NSDateFormatter *dateFormatter = [Global isoDateFormatter];
        NSString *isoSignup = [dateFormatter stringFromDate:kCurrent.createdAt];
        if(![isoSignup isEqualToString:currentSignupDate]){
            shouldUpdate = YES;
            
            [currentValues setObject:isoSignup forKey:@"signup_date"];
            
        }
    }
    
    
    
    // User level
    NSString *currentUserLevel = [currentValues objectForKey:@"user_level"];
    NSString *userLevel = @"None";
    if(kCurrent){
        userLevel = @"User";
        if([kUserHandler isPlus])
            userLevel = @"Plus";
    }
    else if([kUserHandler isTryingOutApp]){
        userLevel = @"Tryout";
    }
    if(![userLevel isEqualToString:currentUserLevel]){
        shouldUpdate = YES;
        gaUpdate = YES;
        [currentValues setObject:userLevel forKey:@"user_level"];
        
        [tracker set:[GAIFields customDimensionForIndex:1]
               value:userLevel];
        [gaCustomBuilder set:userLevel forKey:[GAIFields customDimensionForIndex:1]];
    }
   
    

    
    
    // Evernote User Level
    NSString *currentEvernoteUserLevel = [currentValues objectForKey:@"evernote_user_level"];
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
    if(![evernoteUserLevel isEqualToString:currentEvernoteUserLevel]){
        shouldUpdate = YES;
        gaUpdate = YES;
        
        [currentValues setObject:evernoteUserLevel forKey:@"evernote_user_level"];
        
        [tracker set:[GAIFields customDimensionForIndex:2]
               value:evernoteUserLevel];
        [gaCustomBuilder set:evernoteUserLevel forKey:[GAIFields customDimensionForIndex:2]];
    }
    
    
    // Gmail User Level
    NSString *currentGmailUserLevel = [currentValues objectForKey:@"gmail_user_level"];
    NSString *gmailUserLevel = @"Not Linked";
    if(kGmInt.isAuthenticated){
        gmailUserLevel = @"Linked";
    }
    if(kGmInt.isUsingMailbox){
        gmailUserLevel = @"Mailbox";
    }
    if(![gmailUserLevel isEqualToString:currentGmailUserLevel]){
        shouldUpdate = YES;
        gaUpdate = YES;
        
        [currentValues setObject:gmailUserLevel forKey:@"gmail_user_level"];
        
        [tracker set:[GAIFields customDimensionForIndex:8]
               value:gmailUserLevel];
        [gaCustomBuilder set:gmailUserLevel forKey:[GAIFields customDimensionForIndex:8]];
    }
    
    
    
    
    // Active Theme
    NSString *currentTheme = [currentValues objectForKey:@"active_theme"];
    NSString *theme = ([THEMER currentTheme] == ThemeDark) ? @"Dark" : @"Light";
    if(![theme isEqualToString:currentTheme]){
        shouldUpdate = YES;
        gaUpdate = YES;
        [currentValues setObject:theme forKey:@"active_theme"];
        
        [tracker set:[GAIFields customDimensionForIndex:3]
               value:theme];
        [gaCustomBuilder set:theme forKey:[GAIFields customDimensionForIndex:3]];
    }
    
    
    // Number of Recurring Tasks
    NSNumber *currentRecurringTasks = [currentValues objectForKey:@"recurring_tasks"];
    NSPredicate *recurringPredicate = [NSPredicate predicateWithFormat:@"repeatOption != 'never'"];
    NSNumber *numberOfRecurring = @([KPToDo MR_countOfEntitiesWithPredicate:recurringPredicate]);
    if(!currentRecurringTasks || ![numberOfRecurring isEqualToNumber:currentRecurringTasks]){
        shouldUpdate = YES;
        gaUpdate = YES;
        [currentValues setObject:numberOfRecurring forKey:@"recurring_tasks"];
        
        [tracker set:[GAIFields customDimensionForIndex:4]
               value:[numberOfRecurring stringValue]];
        [gaCustomBuilder set:[numberOfRecurring stringValue] forKey:[GAIFields customDimensionForIndex:4]];
    }
    
    
    // Number of Tags
    NSNumber *currentNumberOfTags = [currentValues objectForKey:@"number_of_tags"];
    NSNumber *numberOfTags = @([KPTag MR_countOfEntities]);
    if(!currentNumberOfTags || ![numberOfTags isEqualToNumber:currentNumberOfTags]){
        shouldUpdate = YES;
        gaUpdate = YES;
        [currentValues setObject:numberOfTags forKey:@"number_of_tags"];
        
        [tracker set:[GAIFields customDimensionForIndex:5]
               value:[numberOfTags stringValue]];
        [gaCustomBuilder set:[numberOfTags stringValue] forKey:[GAIFields customDimensionForIndex:5]];
    }
    
    
    
    NSString *currentIsMailboxInstalled = [currentValues objectForKey:@"mailbox_installed"];
    NSString *isMailboxInstalled = @"Not Installed";
    if([USER_DEFAULTS boolForKey:@"isMailboxInstalled"])
        isMailboxInstalled = @"Installed";
    if(![isMailboxInstalled isEqualToString:currentIsMailboxInstalled]){
        shouldUpdate = YES;
        gaUpdate = YES;
        
        [currentValues setObject:isMailboxInstalled forKey:@"mailbox_installed"];
        
        [tracker set:[GAIFields customDimensionForIndex:6]
               value:isMailboxInstalled];
        [gaCustomBuilder set:isMailboxInstalled forKey:[GAIFields customDimensionForIndex:6]];
    }
    
    NSString *currentPlatform = [currentValues objectForKey:@"platform"];
    NSString *platform = @"iOS";
    if(![currentPlatform isEqualToString:platform]){
        gaUpdate = YES;
        [tracker set:[GAIFields customDimensionForIndex:7] value:platform];
        [gaCustomBuilder set:platform forKey:[GAIFields customDimensionForIndex:7]];
    }
    

    if(gaUpdate){
        [tracker send:[gaCustomBuilder build]];
    }

    
    // Update Intercom / start session
    if(shouldUpdate || gaUpdate){
        [USER_DEFAULTS setObject:[currentValues copy] forKey:@"identityValues"];
        [USER_DEFAULTS synchronize];
    }
    // Update Google Analytics Custom
}

-(void)pushView:(NSString *)view{
    
    NSInteger viewsLeft = self.views.count;
    if(viewsLeft > 5)
        [self.views removeObjectAtIndex:0];
    [self.views addObject:view];
    //[Leanplum advanceTo:view];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:view];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}
-(void)popView{
    NSInteger viewsLeft = self.views.count;
    if(viewsLeft > 0)
        [self.views removeLastObject];
    if(viewsLeft > 1){
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName
               value:[self.views lastObject]];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    }
}
-(void)clearViews{
    [self.views removeAllObjects];
}
-(void)dealloc{
    clearNotify();
}
@end
