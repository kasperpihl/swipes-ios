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
#import "HintHandler.h"
#import "EMHint.h"
#import "SlowHighlightIcon.h"
#import "UtilityClass.h"
#import "RootViewController.h"
#import "ToDoListViewController.h"
#import "UIColor+Utilities.h"

@interface HintHandler () <EMHintDelegate>
@property NSMutableDictionary *hints;
@property EMHint *emHint;
@property Hints currentHint;
@property BOOL hintsIsOff;
@end

@implementation HintHandler
-(void)reset{
    self.hints = [NSMutableDictionary dictionary];
}
-(BOOL)triggerHint:(Hints)hint{
    if(self.hintsIsOff)
        return NO;
    
    BOOL completedHint = [self completeHint:hint];
#warning Forced hints to show
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
            case HintAccount:
                hintText = @"Register an account to safely back up your data";
                break;
            case HintCompleted:
                hintText = @"You've completed a task";
                break;
            case HintSwipedLeft:
                hintText = @"Snooze for later or pick a date";
                break;
            case HintScheduled:
                hintText = @"You've snoozed a task - it'll return to the focus area on time";
                break;
            case HintSelected:
                hintText = @"You selected a task.\n\nYou can select more and take an action below.";
                break;
            case HintPriority:
                hintText = @"You marked a task as priority\n\nThis shows it's importance";
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



static HintHandler *sharedObject;
+(HintHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[HintHandler allocWithZone:NULL] init];
        [sharedObject initialize];
        sharedObject.hintsIsOff = [kSettings settingForKey:kHintsOffKey];
    }
    return sharedObject;
}
-(void)turnOffHints{
    [kSettings setSetting:YES forKey:kHintsOffKey];
    self.hintsIsOff = YES;
}
-(NSString*)keyForHint:(Hints)hint{
    NSString *key;
    switch (hint) {
        case HintWelcome:
            key = @"Welcome";
            break;
        case HintAccount:
            key = @"Account";
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
-(UIView *)hintStateViewForDialog:(id)hintState inBounds:(CGSize)bounds{
    if(self.currentHint == HintPriority){
        CGFloat viewWidth = 260;
        CGFloat viewHeight = 120;
        CGFloat yHack = 100;
        UIView *priorityHint = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
        DotView *dotView = [[DotView alloc] init];
        [dotView setScale:3];
        NSString *currentScreenState = ROOT_CONTROLLER.menuViewController.currentViewController.state;
        UIColor *dotColor = tcolor(TasksColor);
        if([currentScreenState isEqualToString:@"schedule"])
            dotColor = tcolor(LaterColor);
        else if([currentScreenState isEqualToString:@"done"])
            dotColor = tcolor(DoneColor);
        
        [dotView setDotColor:dotColor];
        dotView.priority = YES;
        [priorityHint addSubview:dotView];
        CGRectSetCenter(dotView, bounds.width/2, bounds.height/2-yHack);
        return priorityHint;
    }
    return nil;
}

-(NSArray*)hintStateRectsToHint:(id)hintState
{
    CGFloat ht = 32.0;
    CGFloat statusBarHt = 20.0;
    //
    NSArray *rectArray;
    CGRect rect;
    switch (self.currentHint) {
        case HintAccount:{
            rect = CGRectMake(ROOT_CONTROLLER.view.frame.size.width-CELL_LABEL_X/2, (statusBarHt + 26), ht, ht);
            rectArray = @[[NSValue valueWithCGRect:rect]];
            break;
        }
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
            CGFloat popupSize = 315;
            CGFloat buttonSize = popupSize/3;
            
            CGFloat spotlightRadius = buttonSize/2+10;
            
            CGFloat popupY = (height-popupSize)/2;
            CGFloat popupX = (width-popupSize)/2;
            
            rect = CGRectMake(popupX + buttonSize/2 - 3 , popupY + buttonSize/2 - 2, spotlightRadius,spotlightRadius);
            
            
            rectArray = @[[NSValue valueWithCGRect:rect],[NSValue valueWithCGRect:CGRectMake(popupX + popupSize - spotlightRadius+ 5, popupY + popupSize - spotlightRadius+ 5  , spotlightRadius, spotlightRadius)]];
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
            //title = @"Select an icon";
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

-(UIButton *)turnOffButtonForHint:(CGRect)hintBounds{
    CGFloat closeHeight = 32;
    CGFloat closeWidth = 60;
    CGFloat closeSpacing = 5;
    
    UIColor *buttonColor = alpha(tcolorF(TextColor,ThemeDark),0.7);
    UIButton *closeButton = [[SlowHighlightIcon alloc] initWithFrame:CGRectMake(0, 0, closeWidth, closeHeight)];
    closeButton.layer.cornerRadius = 4;
    //closeButton.layer.borderWidth = 1;
    closeButton.layer.masksToBounds = YES;
    closeButton.titleLabel.font = KP_LIGHT(14);
    //closeButton.layer.borderColor = buttonColor.CGColor;
    
    [closeButton setTitle:@"Turn off" forState:UIControlStateNormal];
    [closeButton setTitleColor:tcolorF(TextColor, ThemeLight) forState:UIControlStateHighlighted];
    [closeButton setBackgroundImage:[buttonColor image] forState:UIControlStateHighlighted];
    
    
    CGPoint originForButton = CGPointMake(closeSpacing, hintBounds.size.height-closeHeight-closeSpacing);
    switch (self.currentHint) {
        case HintSelected:
            originForButton = CGPointMake(hintBounds.size.width - closeWidth - closeSpacing, (OSVER >= 7 ? 20 : 0));
            break;
        default:
            
            break;
    }
    CGRectSetX(closeButton, originForButton.x);
    CGRectSetY(closeButton, originForButton.y);
    return closeButton;
    //[self addSubview:closeButton];
}

-(void)hintTurnedOff{
    [UTILITY confirmBoxWithTitle:@"Hints" andMessage:@"Hints only show once and will guide you through the main functions." cancel:@"Keep on" confirm:@"Turn off" block:^(BOOL succeeded, NSError *error) {
        if(succeeded)
            [self turnOffHints];
    }];
}

-(void)initialize{
    self.hints = [[NSUserDefaults standardUserDefaults] objectForKey:kHintDictionaryKey];
    if(!self.hints)
        self.hints = [NSMutableDictionary dictionary];
    self.emHint = [[EMHint alloc] init];
    self.emHint.hintDelegate = self;
}
@end
