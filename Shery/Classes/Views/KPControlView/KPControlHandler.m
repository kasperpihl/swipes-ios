//
//  KPControlView.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 22/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#define ADD_BUTTON_TAG 13000

#define BIG_BUTTON_HEIGHT 90
#define BIG_BUTTON_BOTTOM_MARGIN 10
#define SMALL_BUTTON_HEIGHT 52
#define SMALL_BUTTON_BOTTOM_MARGIN 5
#define ANIMATION_DURATION 0.3
#define ADD_BUTTON_X ((320/2)-(BIG_BUTTON_HEIGHT/2))


#import "KPControlHandler.h"
#import "RootViewController.h"
typedef void (^voidBlock)(void);
@interface KPControlHandler ()
@property (nonatomic) KPControlViewState activeState;
@property (nonatomic,weak) UIView* view;
@property (nonatomic,strong) UIButton *addButton;
@property (nonatomic,strong) UIButton *deleteButton;
@property (nonatomic,strong) UIButton *deselectButton;
@property (nonatomic,strong) UIButton *shareButton;
@end
@implementation KPControlHandler
+(KPControlHandler*)instanceInView:(UIView*)view{
    KPControlHandler *object = [[KPControlHandler alloc] initWithView:view];
    object.view = view;
    return object;
}
-(CGFloat)getYForBigSize:(BOOL)big{
    CGFloat size;
    if(big) size = (self.view.frame.size.height-BIG_BUTTON_HEIGHT-BIG_BUTTON_BOTTOM_MARGIN);
    else size = (self.view.frame.size.height-SMALL_BUTTON_HEIGHT-SMALL_BUTTON_BOTTOM_MARGIN);
    return size;
}
- (id)initWithView:(UIView*)view
{
    self = [super init];
    if (self) {
        self.view = view;
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addButton.frame = CGRectMake(ADD_BUTTON_X,view.frame.size.height,BIG_BUTTON_HEIGHT,BIG_BUTTON_HEIGHT);
        addButton.tag = ADD_BUTTON_TAG;
        [addButton addTarget:self action:@selector(pressedAdd:) forControlEvents:UIControlEventTouchUpInside];
        [addButton setImage:[UIImage imageNamed:@"addbutton"] forState:UIControlStateNormal];
        [addButton setImage:[UIImage imageNamed:@"addbutton-highlighted"] forState:UIControlStateHighlighted];
        [view addSubview:addButton];
        self.addButton = (UIButton*)[view viewWithTag:ADD_BUTTON_TAG];
        
        [self setState:KPControlViewStateAdd animated:NO];
    }
    return self;
}
-(voidBlock)getClearBlockForState:(KPControlViewState)state{
    CGFloat targetY = self.view.frame.size.height;
    voidBlock block = ^(void) {
        switch (state) {
            case KPControlViewStateNone:
                break;
            case KPControlViewStateAdd:
                CGRectSetY(self.addButton.frame, targetY);
                break;
            case KPControlViewStateEdit:
                CGRectSetY(self.deleteButton.frame, targetY);
                CGRectSetY(self.deselectButton.frame, targetY);
                CGRectSetY(self.shareButton.frame, targetY);
                break;
        }
    };
    return block;
}
-(voidBlock)getShowBlockForState:(KPControlViewState)state{
    CGFloat bigButtonY = [self getYForBigSize:YES];
    CGFloat smallButtonY = [self getYForBigSize:NO];
    voidBlock block = ^(void) {
        switch (state) {
            case KPControlViewStateNone:
                break;
            case KPControlViewStateAdd:
                CGRectSetY(self.addButton.frame, bigButtonY);
                break;
            case KPControlViewStateEdit:
                CGRectSetY(self.deleteButton.frame, smallButtonY);
                CGRectSetY(self.deselectButton.frame, smallButtonY);
                CGRectSetY(self.shareButton.frame, smallButtonY);
                break;
        }
    };
    return block;
}
-(void)setState:(KPControlViewState)state animated:(BOOL)animated{
    if(state == self.activeState) return;
    voidBlock clearBlock = [self getClearBlockForState:self.activeState];
    CGFloat clearDuration = (self.activeState == KPControlViewStateNone) ? 0 : ANIMATION_DURATION;
    CGFloat showDuration = (state == KPControlViewStateNone) ? 0 : ANIMATION_DURATION;
    voidBlock showBlock = [self getShowBlockForState:state];
    if(animated){
        voidBlock nextBlock = clearBlock;
        if(clearDuration == 0){
            nextBlock();
            nextBlock = showBlock;
            showBlock = nil;
            clearDuration = showDuration;
        }
        [UIView animateWithDuration:clearDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:nextBlock completion:^(BOOL finished) {
            if(finished && showBlock){
                if(showDuration == 0) showBlock();
                else [UIView animateWithDuration:showDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:showBlock completion:nil];
            }
        }];
    }
    else{
        clearBlock();
        showBlock();
    }
    self.activeState = state;
}
-(void)pressedAdd:(id)sender{
    if([self.delegate respondsToSelector:@selector(pressedAdd:)]) [self.delegate pressedAdd:self];
}
-(void)pressedDelete:(id)sender{
    if([self.delegate respondsToSelector:@selector(pressedDelete:)]) [self.delegate pressedDelete:self];
}
-(void)pressedDeselect:(id)sender{
    if([self.delegate respondsToSelector:@selector(pressedDeselect:)]) [self.delegate pressedDeselect:self];
}

@end
