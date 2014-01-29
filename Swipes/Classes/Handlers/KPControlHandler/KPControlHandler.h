//
//  KPControlView.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 22/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ANIMATION_DURATION GLOBAL_ANIMATION_DURATION

typedef NS_ENUM(NSUInteger, KPControlHandlerState){
    KPControlHandlerStateAdd,
    KPControlHandlerStateEdit
};
@protocol KPControlHandlerDelegate <NSObject>
@optional
-(void)pressedAdd:(id)sender;
-(void)pressedEdit:(id)sender;
-(void)pressedDelete:(id)sender;
-(void)pressedTag:(id)sender;
-(void)pressedShare:(id)sender;
@end

@interface KPControlHandler : NSObject
@property (nonatomic,readonly) KPControlHandlerState activeState;
@property (nonatomic,weak) NSObject<KPControlHandlerDelegate> *delegate;
@property (nonatomic) BOOL lockGradient;
+(KPControlHandler*)instanceInView:(UIView*)view;
-(void)setState:(KPControlHandlerState)state animated:(BOOL)animated;
@end
