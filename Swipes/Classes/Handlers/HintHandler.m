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
#import "EMHint.h"
#import "RootViewController.h"

@interface HintHandler () <EMHintDelegate>
@property NSMutableDictionary *hints;
@property EMHint *emHint;
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
    completedHint = YES;
    if(completedHint){
        if([self.delegate respondsToSelector:@selector(hintHandler:triggeredHint:)])
            [self.delegate hintHandler:self triggeredHint:hint];
        [self.emHint presentModalMessage:@"Just completed the first task" where:ROOT_CONTROLLER.view];
    }
    return completedHint;
}
-(BOOL)hasCompletedHint:(Hints)hint{
    NSString *key = [self keyForHint:hint];
    BOOL hasAlreadyCompletedHint = [[self.hints objectForKey:key] boolValue];
    return hasAlreadyCompletedHint;
}

-(NSArray*)hintStateRectsToHint:(id)hintState
{
    CGFloat ht = 40.0;
    CGFloat statusBarHt = 2.0;
    NSArray* rectArray = nil;
    CGRect rect = CGRectMake(ROOT_CONTROLLER.view.frame.size.width/2+55 ,
                            (statusBarHt + 44),ht,ht);
    return @[[NSValue valueWithCGRect:rect]];
}


-(void)initialize{
    self.hints = [[NSUserDefaults standardUserDefaults] objectForKey:kHintDictionaryKey];
    if(!self.hints)
        self.hints = [NSMutableDictionary dictionary];
    self.emHint = [[EMHint alloc] init];
    self.emHint.hintDelegate = self;
}
@end
