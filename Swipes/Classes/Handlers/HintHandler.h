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
#define HH_TriggeredHintListener @"HH_TriggeredHint"

typedef NS_ENUM(NSInteger, Hints) {
    HintWelcomeVideo = 1,
    HintAddTask,
    HintCompleted,
    HintScheduled,
    HintAllDone
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
-(void)turnHintsOff:(BOOL)hintsOff;
-(NSArray*)getCurrentHints;
-(NSInteger)hintLeftForCurrentHints;
@end
