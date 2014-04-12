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
@property Hints currentHint;
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
        self.currentHint = hint;
        if([self.delegate respondsToSelector:@selector(hintHandler:triggeredHint:)])
            [self.delegate hintHandler:self triggeredHint:hint];
        NSString *hintText;
        switch (hint) {
            case HintWelcome:
                hintText = @"Keep your current tasks here.\n\nSnooze or complete the rest!";
                break;
            case HintCompleted:
                hintText = @"You've completed a task";
                break;
            case HintSwipedLeft:

                break;
            case HintScheduled:
                hintText = @"You've snoozed a task";
                break;
            case HintSelected:
                hintText = @"You selected a task.\n\nYou can select more and take an action below.";
                break;
            case HintPriority:
                break;
        }
        [self.emHint presentModalMessage:hintText where:ROOT_CONTROLLER.view];
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
    CGFloat ht = 32.0;
    CGFloat statusBarHt = 20.0;
    //
    NSArray *rectArray;
    CGRect rect;
    switch (self.currentHint) {
        case HintSelected:{
            NSMutableArray *mutRect = [NSMutableArray array];
            CGFloat oneFourth = ROOT_CONTROLLER.view.frame.size.width / 4;
            for(NSInteger i = 1 ; i <= 4 ; i++){
                CGFloat x = oneFourth * i - oneFourth/2;
                NSLog(@"x %f",x);
                CGRect tmpRect = CGRectMake(x, ROOT_CONTROLLER.view.frame.size.height - 28.5, ht, ht);
                [mutRect addObject:[NSValue valueWithCGRect:tmpRect]];
            }
            rectArray = [mutRect copy];
            break;
        }
        case HintCompleted:
        
            rect = CGRectMake(ROOT_CONTROLLER.view.frame.size.width/2+54 ,
                       (statusBarHt + 26),ht,ht);
            rectArray = @[[NSValue valueWithCGRect:rect]];
            break;
        case HintSwipedLeft:{
            CGFloat width = ROOT_CONTROLLER.view.frame.size.width;
            CGFloat height = ROOT_CONTROLLER.view.frame.size.height;
            rect = CGRectMake(width/2, height/2, width/4, width/4);
            rectArray = @[[NSValue valueWithCGRect:rect]];
            break;
        }
        case HintScheduled:
            rect = CGRectMake(ROOT_CONTROLLER.view.frame.size.width/2-54 ,
                              (statusBarHt + 26),ht,ht);
            rectArray = @[[NSValue valueWithCGRect:rect]];
            break;
        case HintWelcome:
            rect = CGRectMake(ROOT_CONTROLLER.view.frame.size.width/2, (statusBarHt + 26), ht, ht);
            rectArray = @[[NSValue valueWithCGRect:rect]];
            //,[NSValue valueWithCGRect:CGRectMake(ROOT_CONTROLLER.view.frame.size.width/2, ROOT_CONTROLLER.view.frame.size.height - (32), ht+10, ht+10)]
            //,[NSValue valueWithCGRect:CGRectMake(ROOT_CONTROLLER.view.frame.size.width/2-54,(statusBarHt + 26),ht,ht)],[NSValue valueWithCGRect:CGRectMake(ROOT_CONTROLLER.view.frame.size.width/2+54 ,(statusBarHt + 26),ht,ht)]
            break;
        default:
            break;
    }
    return rectArray;
}
-(NSString *)titleForRect:(CGRect)rect index:(NSInteger)index{
    NSString *title;
    switch (self.currentHint) {
        case HintSelected:{
            if(index == 0) title = @"Edit";
            else if(index == 1) title = @"Tag";
            else if(index == 2) title = @"Delete";
            else if(index == 3) title = @"Share";
            break;
        }
        case HintCompleted:
            title = @"Completed log";
            break;
        case HintSwipedLeft:{
            title = @"Select an icon";
            break;
        }
        case HintScheduled:
            title = @"Schedule";
            break;
        case HintWelcome:
            title = @"Focus area";
            break;
        default:
            break;
    }
    return title;
}

-(void)initialize{
    self.hints = [[NSUserDefaults standardUserDefaults] objectForKey:kHintDictionaryKey];
    if(!self.hints)
        self.hints = [NSMutableDictionary dictionary];
    self.emHint = [[EMHint alloc] init];
    self.emHint.hintDelegate = self;
}
@end