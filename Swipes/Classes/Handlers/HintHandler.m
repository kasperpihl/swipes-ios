//
//  HintHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 24/03/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#define kHintDictionaryKey @"HintsDictionary"
#define kHintsOffKey @"HintsTurnedOff"


#import "DotView.h"


#import "SettingsHandler.h"
#import "AnalyticsHandler.h"
#import "HintHandler.h"
#import "SlowHighlightIcon.h"
#import "UtilityClass.h"
#import "RootViewController.h"
#import "ToDoListViewController.h"
#import "UIColor+Utilities.h"

@interface HintHandler ()
@property NSMutableDictionary *hints;
@property BOOL hintsIsOff;
@end

@implementation HintHandler
-(void)reset{
    self.hints = [NSMutableDictionary dictionary];
    [self turnHintsOff:NO];
}
-(BOOL)triggerHint:(Hints)hint{
    if(self.hintsIsOff)
        return NO;
    BOOL completedHint = [self completeHint:hint];
    if(completedHint){
        if([self.delegate respondsToSelector:@selector(hintHandler:triggeredHint:)])
            [self.delegate hintHandler:self triggeredHint:hint];
        [[NSNotificationCenter defaultCenter] postNotificationName:HH_TriggeredHintListener object:self userInfo:@{@"Hint": @(hint)}];
    }
    return completedHint;
}
-(BOOL)isHintsOff{
    return self.hintsIsOff;
}

-(BOOL)hasCompletedHint:(Hints)hint{
    NSString *key = [self keyForHint:hint];
    BOOL hasAlreadyCompletedHint = [[self.hints objectForKey:key] boolValue];
    return hasAlreadyCompletedHint;
}
-(NSArray *)getCurrentHints{
    return @[ @(HintWelcomeVideo), @(HintAddTask), @(HintCompleted), @(HintScheduled), @(HintAllDone) ];
}
-(NSInteger)hintLeftForCurrentHints{
    NSArray *currentHints = [self getCurrentHints];
    NSInteger hintsLeft = 5;
    for( NSNumber *hint in currentHints){
        Hints intHint = [hint integerValue];
        if([self hasCompletedHint:intHint])
            hintsLeft--;
    }
    return hintsLeft;
}


static HintHandler *sharedObject;
+(HintHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[HintHandler allocWithZone:NULL] init];
        [sharedObject initialize];
        sharedObject.hintsIsOff = [kSettings settingForKey:kHintsOffKey];
    }
    return sharedObject;
}
-(void)turnHintsOff:(BOOL)hintsOff{
    [kSettings setSetting:hintsOff forKey:kHintsOffKey];
    self.hintsIsOff = hintsOff;
}
-(NSString*)keyForHint:(Hints)hint{
    NSString *key;
    switch (hint) {
        case HintWelcomeVideo:
            key = @"WelcomeVideo";
            break;
        case HintAddTask:
            key = @"AddTask";
            break;
        case HintCompleted:
            key = @"Completed";
            break;
        case HintScheduled:
            key = @"Scheduled";
            break;
        case HintAllDone:
            key = @"AllDone";
            break;
        default:
            key = [NSString stringWithFormat:@"Unknown hint: %ld", (long)hint];
            break;
    }
    return key;
}


-(BOOL)completeHint:(Hints)hint{
    NSString *key = [self keyForHint:hint];
    BOOL hasAlreadyCompletedHint = [[self.hints objectForKey:key] boolValue];
    if(!hasAlreadyCompletedHint){
        [self.hints setObject:@YES forKey:key];
        [USER_DEFAULTS setObject:self.hints forKey:kHintDictionaryKey];
        [USER_DEFAULTS synchronize];
    }
    
    return !hasAlreadyCompletedHint;
}



- (void)orientationChanged:(NSNotification *)notification{
    
}

- (void)onTriggerHint:(NSNotification *)notification{
    [self triggerHint:(Hints)[((NSNumber *)notification.object) integerValue]];
}

-(void)initialize {
    self.hints = [USER_DEFAULTS objectForKey:kHintDictionaryKey];
    if(!self.hints)
        self.hints = [NSMutableDictionary dictionary];
    else
        self.hints = [self.hints mutableCopy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"willRotateToInterfaceOrientation" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTriggerHint:) name:HH_TriggerHint object:nil];
}

-(void)dealloc{
    clearNotify();
}
@end
