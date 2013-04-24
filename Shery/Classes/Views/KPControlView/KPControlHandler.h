//
//  KPControlView.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 22/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, KPControlViewState){
    KPControlViewStateNone = 0,
    KPControlViewStateAdd,
    KPControlViewStateEdit
};
@protocol KPControlHandlerDelegate <NSObject>
@optional
-(void)pressedAdd:(id)sender;
-(void)pressedDelete:(id)sender;
-(void)pressedDeselect:(id)sender;
-(void)pressedShare:(id)sender;
@end

@interface KPControlHandler : NSObject
@property (nonatomic,readonly) KPControlViewState activeState;
@property (nonatomic,weak) NSObject<KPControlHandlerDelegate> *delegate;
+(KPControlHandler*)instanceInView:(UIView*)view;
-(void)setState:(KPControlViewState)state animated:(BOOL)animated;
@end
