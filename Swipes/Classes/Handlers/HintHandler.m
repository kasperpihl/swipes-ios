//
//  HintHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 24/03/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#define kHintDictionaryKey @"HintsDictionary"

#import "SettingsHandler.h"
#import "HintHandler.h"
@interface HintHandler ()
@property NSMutableDictionary *hints;
@property BOOL hintsIsOff;
@end

@implementation HintHandler
static HintHandler *sharedObject;
+(HintHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[HintHandler allocWithZone:NULL] init];
        [sharedObject initialize];
    }
    return sharedObject;
}
-(NSString*)keyForHint:(Hints)hint{
    NSString *key;
    switch (hint) {
        case HintWelcome:
            key = @"Welcome";
            break;
        case HintSelected:
            key = @"Selected";
            break;
        case HintCompleted:
            key = @"Completed";
            break;
        case HintSwipedLeft:
            key = @"SwipedLeft";
            break;
        case HintScheduled:
            key = @"Scheduled";
            break;
        case HintPriority:
            key = @"Priority";
            break;
    }
    return key;
}
-(BOOL)completeHint:(Hints)hint{
    NSString *key = [self keyForHint:hint];
    BOOL hasAlreadyCompletedHint = [[self.hints objectForKey:key] boolValue];
    if(!hasAlreadyCompletedHint){
        NSLog(@"completed hint %@",key);
        [self.hints setObject:@YES forKey:key];
        [[NSUserDefaults standardUserDefaults] setObject:self.hints forKey:kHintDictionaryKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else NSLog(@"hint already completed %@",key);
    
    return !hasAlreadyCompletedHint;
}
/*
 
*/
-(BOOL)triggerHint:(Hints)hint{
    BOOL completedHint = [self completeHint:hint];
    if(completedHint){
        if([self.delegate respondsToSelector:@selector(hintHandler:triggeredHint:)])
            [self.delegate hintHandler:self triggeredHint:hint];
    }
    return completedHint;
}
-(BOOL)hasCompletedHint:(Hints)hint{
    NSString *key = [self keyForHint:hint];
    BOOL hasAlreadyCompletedHint = [[self.hints objectForKey:key] boolValue];
    return hasAlreadyCompletedHint;
}
-(void)initialize{
    self.hints = [[NSUserDefaults standardUserDefaults] objectForKey:kHintDictionaryKey];
    if(!self.hints)
        self.hints = [NSMutableDictionary dictionary];
}
@end
