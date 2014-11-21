//
//  HintHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 24/03/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kHints [HintHandler sharedInstance]

#define HH_TriggerHint @"HH_TriggerHint"

typedef NS_ENUM(NSInteger, Hints) {
    HintWelcome = 1,
    HintAccount,
    HintSelected,
    HintCompleted,
    HintSwipedLeft,
    HintScheduled,
    HintPriority,
    HintEvernoteIntegration
};

@class HintHandler;
@protocol HintHandlerDelegate <NSObject>
-(void)hintHandler:(HintHandler*)hintHandler triggeredHint:(Hints)hint;
@end

@interface HintHandler : NSObject
@property (nonatomic,weak) id<HintHandlerDelegate> delegate;
+(HintHandler*)sharedInstance;
-(BOOL)triggerHint:(Hints)hint;
-(BOOL)hasCompletedHint:(Hints)hint;
-(void)reset;
-(void)turnHintsOn:(BOOL)hintsOn;
@end
