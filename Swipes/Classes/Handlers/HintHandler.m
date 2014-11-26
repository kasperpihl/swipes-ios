//
//  HintHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 24/03/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#define kHintDictionaryKey @"HintsDictionary"
#define kHintsOnKey @"HintsTurnedOn"


#import "DotView.h"


#import "SettingsHandler.h"
#import "AnalyticsHandler.h"
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
@property BOOL hintsIsOn;
@property double hintStartTime;
@end

@implementation HintHandler
-(void)reset{
    self.hints = [NSMutableDictionary dictionary];
    [self turnHintsOn:YES];
}
-(BOOL)triggerHint:(Hints)hint{
    if(!self.hintsIsOn)
        return NO;
    if([self.emHint isShowingHint])
        return NO;
    BOOL completedHint = [self completeHint:hint];
    if(completedHint){
        if([self.delegate respondsToSelector:@selector(hintHandler:triggeredHint:)])
            [self.delegate hintHandler:self triggeredHint:hint];
        NSString *hintText;
        switch (hint) {
            case HintWelcome:
                hintText = @"Keep your current tasks here\n\nSnooze or complete the rest!";
                break;
            case HintAccount:
                hintText = @"Register an account to safely back up your data";
                break;
            case HintCompleted:
                hintText = @"Hooray! You've completed a task";
                break;
            case HintSwipedLeft:
                hintText = @"Snooze for later or pick a date";
                break;
            case HintScheduled:
                hintText = @"You've snoozed a task\n\nYou'll be reminded on time";
                break;
            case HintSelected:
                hintText = @"You selected a task\n\nYou can select more and take an action below";
                break;
            case HintPriority:
                hintText = @"You marked a task as priority\n\nThis shows its importance";
                break;
            case HintEvernoteIntegration:{
                return YES;
            }
        }
        self.currentHint = hint;
        self.hintStartTime = CACurrentMediaTime();
        NSDictionary *options = @{
                                  @"Message": [self keyForHint:hint]
                                  };

        [ANALYTICS trackEvent:@"Hint Opened" options:options];
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
        sharedObject.hintsIsOn = [kSettings settingForKey:kHintsOnKey];
        
    }
    return sharedObject;
}
-(void)turnHintsOn:(BOOL)hintsOn{
    [kSettings setSetting:hintsOn forKey:kHintsOnKey];
    self.hintsIsOn = hintsOn;
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
        case HintEvernoteIntegration:
            key = @"EvernoteIntegration";
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


-(void)hintStateWillClose:(id)hintState{
    double endtime = CACurrentMediaTime();
    double elapsedTime = endtime - self.hintStartTime;

    NSString *elapsedWithOneDecimalString = [NSString stringWithFormat:@"%.1lf",elapsedTime];
    NSNumber *numberWithOneDecimal = @([elapsedWithOneDecimalString floatValue]);
    if(!numberWithOneDecimal)
        numberWithOneDecimal = @(0);
    
    self.hintStartTime = 0;
    NSDictionary *options = @{
                              @"Message": [self keyForHint:self.currentHint],
                              @"Length": numberWithOneDecimal
                              };
    [ANALYTICS trackEvent:@"Hint Closed" options:options];
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
    
    UIApplication *application = [UIApplication sharedApplication];
    BOOL landscape = UIInterfaceOrientationIsLandscape(application.statusBarOrientation);
    CGFloat height = landscape ? ROOT_CONTROLLER.view.frame.size.width : ROOT_CONTROLLER.view.frame.size.height;
    CGFloat width = landscape ? ROOT_CONTROLLER.view.frame.size.height : ROOT_CONTROLLER.view.frame.size.width;
    CGFloat ht = 32.0;
    CGFloat statusBarHt = 20.0;
    //
    NSArray *rectArray;
    CGRect rect;
    switch (self.currentHint) {
            
        case HintAccount:{
            rect = CGRectMake(width-CELL_LABEL_X/2, (statusBarHt + 26), ht, ht);
            rectArray = @[[NSValue valueWithCGRect:rect]];
            break;
        }
        case HintSelected:{
            NSMutableArray *mutRect = [NSMutableArray array];
            CGFloat oneFourth = width / 4;
            for(NSInteger i = 1 ; i <= 4 ; i++){
                CGFloat x = oneFourth * i - oneFourth/2;
                CGRect tmpRect = CGRectMake(x, height - 28.5, ht, ht);
                [mutRect addObject:[NSValue valueWithCGRect:tmpRect]];
            }
            rectArray = [mutRect copy];
            break;
        }
        case HintCompleted:
        
            rect = CGRectMake(width/2+54 ,
                       (statusBarHt + 26),ht,ht);
            rectArray = @[[NSValue valueWithCGRect:rect]];
            break;
        case HintSwipedLeft:{
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
            rect = CGRectMake(width/2-54 ,
                              (statusBarHt + 26),ht,ht);
            rectArray = @[[NSValue valueWithCGRect:rect]];
            break;
        case HintWelcome:
            rect = CGRectMake(width/2, (statusBarHt + 26), ht, ht);
            rectArray = @[[NSValue valueWithCGRect:rect]];
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
            if(index == 0) title = @"Open/Edit";
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
            [self turnHintsOn:NO];
    }];
}

- (void)orientationChanged:(NSNotification *)notification{
    [self.emHint clear];
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
    self.emHint = [[EMHint alloc] init];
    self.emHint.hintDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"willRotateToInterfaceOrientation" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTriggerHint:) name:HH_TriggerHint object:nil];
}

-(void)dealloc{
    clearNotify();
}
@end
