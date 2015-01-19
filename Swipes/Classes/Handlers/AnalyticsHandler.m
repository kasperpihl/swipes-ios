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
#import "KPToDo.h"
#import "KPTag.h"
#import "UserHandler.h"
#import "EvernoteIntegration.h"
#import "Intercom.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface AnalyticsHandler () <IntercomSessionListener>
@property (nonatomic) NSMutableArray *views;
@property (nonatomic) Vero* vero;
@property (nonatomic) BOOL intercomSession;
@property (nonatomic) BOOL initializedIntercom;
@property (nonatomic) BOOL isBeginningIntercomSession;
@end
@implementation AnalyticsHandler
static AnalyticsHandler *sharedObject;
+(AnalyticsHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[AnalyticsHandler allocWithZone:NULL] init];
        [sharedObject initializeIntercom];
    }
    return sharedObject;
}
-(void)initialize{
    notify(@"logged in", beginSession);
}
-(BOOL)initializedIntercom{
    if(!_initializedIntercom){
        [self initializeIntercom];
    }
    return _initializedIntercom;
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
-(void)trackCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value{
    if(self.analyticsOff)
        return;
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:value] build]];
}
-(void)trackEvent:(NSString *)event options:(NSDictionary *)options{
    if(self.analyticsOff)
        return;
    if(self.initializedIntercom && self.intercomSession){
        [Intercom logEventWithName:event optionalMetaData:options completion:^(NSError *error) {
            NSLog(@"Error: %@",error);
        }];
    }
    //[Leanplum track:event withParameters:options];
    //[[LocalyticsSession shared] tagEvent:event attributes:options];
}
-(void)beginSession{
    if(self.isBeginningIntercomSession)
        return;
    self.isBeginningIntercomSession = YES;
    if(self.initializedIntercom){
        __weak AnalyticsHandler *weakSelf = self;
        [Intercom beginSessionForUserWithUserId:kCurrent.objectId completion:^(NSError *error) {
            weakSelf.isBeginningIntercomSession = NO;
            [weakSelf checkForUpdatesOnIdentity];
        }];
    }
}

-(void)checkForUpdatesOnIdentity{
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    NSMutableDictionary *currentValues = [[USER_DEFAULTS objectForKey:@"identityValues"] mutableCopy];
    if(!currentValues){
        currentValues = [NSMutableDictionary dictionary];
    }
    
    __block BOOL shouldUpdate = NO;
    BOOL gaUpdate = NO;
    
    GAIDictionaryBuilder *gaCustomBuilder = [GAIDictionaryBuilder createEventWithCategory:@"Session" action:@"Updated Identity" label:nil value:nil];
    NSMutableDictionary *intercomAttributes = [@{} mutableCopy];
    NSMutableDictionary *customIntercomAttributes = [@{} mutableCopy];
    
    
    // User ID Checking
    NSString *currentUserId = [currentValues objectForKey:@"userId"];
    NSString *userId = kCurrent.objectId;
    if(userId && ![userId isEqualToString:currentUserId]){
        gaUpdate = YES;
        shouldUpdate = YES;
        if(self.initializedIntercom && !self.intercomSession)
            [self beginSession];
        [currentValues setObject:userId forKey:@"userId"];
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
        
        [intercomAttributes setObject:email forKey:@"email"];
    }

    
    
    
    // Signup date
    NSString *currentSignupDate = [currentValues objectForKey:@"signup_date"];
    if(kCurrent.createdAt){
        NSDateFormatter *dateFormatter = [Global isoDateFormatter];
        NSString *isoSignup = [dateFormatter stringFromDate:kCurrent.createdAt];
        if(![isoSignup isEqualToString:currentSignupDate]){
            shouldUpdate = YES;
            
            [currentValues setObject:isoSignup forKey:@"signup_date"];
            
            [intercomAttributes setObject:isoSignup forKey:@"remote_created_at"];
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
        [customIntercomAttributes setObject:userLevel forKey:@"user_level"];
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
        
        [customIntercomAttributes setObject:evernoteUserLevel forKey:@"evernote_user_level"];
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
        
        [customIntercomAttributes setObject:theme forKey:@"active_theme"];
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
        
        [customIntercomAttributes setObject:numberOfRecurring forKey:@"recurring_tasks"];
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
        [customIntercomAttributes setObject:numberOfTags forKey:@"number_of_tags"];
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
        
        [customIntercomAttributes setObject:isMailboxInstalled forKey:@"mailbox_installed"];
    }
    

    if(gaUpdate){
        [tracker send:[gaCustomBuilder build]];
    }

    
    // Update Intercom / start session
    [intercomAttributes setObject:customIntercomAttributes forKey:@"custom_attributes"];
    if(self.initializedIntercom){
        if(self.intercomSession && kCurrent && shouldUpdate){
            [Intercom updateUserWithAttributes:intercomAttributes completion:^(NSError *error) {
                if (!error) {
                    if( shouldUpdate ){
                        DLog(@"did update");
                        [USER_DEFAULTS setObject:[currentValues copy] forKey:@"identityValues"];
                        [USER_DEFAULTS synchronize];
                    }
                }
                else{
                    NSLog(@"error %@",error);
                }
            }];
            
        }
    }
    
    
    // Update Google Analytics Custom
}


- (void)intercomSessionStatusDidChange:(BOOL)isSessionOpen{
    self.intercomSession = isSessionOpen;
    if(isSessionOpen){
        DLog(@"session on");
    }
    else
        DLog(@"session off");
}

-(void)initializeIntercom{
    NSString *hmac = [USER_DEFAULTS objectForKey:@"intercom-hmac"];
    if(kCurrent.objectId && hmac){
        DLog(@"initialized intercom %@",hmac);
        
        [Intercom setApiKey:@"ios_sdk-050d2c5445d903ddad5e59fdb7ab9e01543303a1" forAppId:@"yobuz4ff" securityOptions:@{ @"hmac" : hmac, @"data": kCurrent.objectId }];
        [Intercom enableLogging];
        [Intercom setPresentationInsetOverScreen:UIEdgeInsetsMake(0, 0, 0, 0)];
        [Intercom setSessionListener:self];
        self.initializedIntercom = YES;
    }
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
