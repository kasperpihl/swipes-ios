//
//  HintHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 24/03/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kHints [HintHandler sharedInstance]
typedef enum {
    HintWelcome = 1,
    HintAccount,
    HintSelected,
    HintCompleted,
    HintSwipedLeft,
    HintScheduled,
    HintPriority,
    HintEvernote
    
} Hints;

@class HintHandler;
@protocol HintHandlerDelegate <NSObject>
-(void)hintHandler:(HintHandler*)hintHandler triggeredHint:(Hints)hint;
@end

@interface HintHandler : NSObject
@property (nonatomic,weak) NSObject<HintHandlerDelegate> *delegate;
+(HintHandler*)sharedInstance;
-(BOOL)triggerHint:(Hints)hint;
-(BOOL)hasCompletedHint:(Hints)hint;
-(void)reset;
-(void)turnHintsOn:(BOOL)hintsOn;
@end
