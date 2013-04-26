//
//  KPControlView.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 22/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#define ADD_BUTTON_TAG 13000
#define DELETE_BUTTON_TAG 13001
#define TAG_BUTTON_TAG 13002
#define SHARE_BUTTON_TAG 13003

#define BIG_BUTTON_HEIGHT 90
#define BIG_BUTTON_BOTTOM_MARGIN 0
#define SMALL_BUTTON_HEIGHT 64
#define SMALL_BUTTON_BOTTOM_MARGIN 0

#define ANIMATION_DURATION 0.15f

#define ADD_BUTTON_X ((320/2)-(BIG_BUTTON_HEIGHT/2))

#define SMALL_BUTTON_SPACING 5

#define DELETE_BUTTON_X SMALL_BUTTON_SPACING
#define TAG_BUTTON_X (DELETE_BUTTON_X+SMALL_BUTTON_HEIGHT+SMALL_BUTTON_SPACING)
#define SHARE_BUTTON_X (TAG_BUTTON_X+SMALL_BUTTON_HEIGHT+SMALL_BUTTON_SPACING)

#define DESELECT_BUTTON_X 150

#import "KPControlHandler.h"
#import "RootViewController.h"
typedef void (^voidBlock)(void);
@interface KPControlHandler ()
@property (nonatomic) KPControlHandlerState activeState;
@property (nonatomic,weak) UIView* view;
@property (nonatomic,weak) UIButton *addButton;
@property (nonatomic,weak) UIButton *deleteButton;
@property (nonatomic,weak) UIButton *shareButton;
@property (nonatomic,weak) UIButton *tagButton;
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
        [view addSubview:addButton];
        self.addButton = (UIButton*)[view viewWithTag:ADD_BUTTON_TAG];
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.frame = CGRectMake(DELETE_BUTTON_X,view.frame.size.height,SMALL_BUTTON_HEIGHT,SMALL_BUTTON_HEIGHT);
        deleteButton.tag = DELETE_BUTTON_TAG;
        [deleteButton addTarget:self action:@selector(pressedDelete:) forControlEvents:UIControlEventTouchUpInside];
        [deleteButton setImage:[UIImage imageNamed:@"deletebutton"] forState:UIControlStateNormal];
        [view addSubview:deleteButton];
        self.deleteButton = (UIButton*)[view viewWithTag:DELETE_BUTTON_TAG];
        
        UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tagButton.frame = CGRectMake(TAG_BUTTON_X,view.frame.size.height,SMALL_BUTTON_HEIGHT,SMALL_BUTTON_HEIGHT);
        tagButton.tag = TAG_BUTTON_TAG;
        [tagButton addTarget:self action:@selector(pressedTag:) forControlEvents:UIControlEventTouchUpInside];
        [tagButton setImage:[UIImage imageNamed:@"tagbutton"] forState:UIControlStateNormal];
        [view addSubview:tagButton];
        self.tagButton = (UIButton*)[view viewWithTag:TAG_BUTTON_TAG];
        
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shareButton.frame = CGRectMake(SHARE_BUTTON_X,view.frame.size.height,SMALL_BUTTON_HEIGHT,SMALL_BUTTON_HEIGHT);
        shareButton.tag = SHARE_BUTTON_TAG;
        [shareButton addTarget:self action:@selector(pressedShare:) forControlEvents:UIControlEventTouchUpInside];
        [shareButton setImage:[UIImage imageNamed:@"sharebutton"] forState:UIControlStateNormal];
        //[deleteButton setImage:[UIImage imageNamed:@"addbutton-highlighted"] forState:UIControlStateHighlighted];
        [view addSubview:shareButton];
        self.shareButton = (UIButton*)[view viewWithTag:SHARE_BUTTON_TAG];
        
        [self setState:KPControlHandlerStateAdd animated:NO];
    }
    return self;
}
-(voidBlock)getClearBlockForState:(KPControlHandlerState)state{
    CGFloat targetY = self.view.frame.size.height;
    voidBlock block = ^(void) {
        switch (state) {
            case KPControlHandlerStateNone:
                break;
            case KPControlHandlerStateAdd:
                CGRectSetY(self.addButton.frame, targetY);
                break;
            case KPControlHandlerStateEdit:
                CGRectSetY(self.deleteButton.frame, targetY);
                CGRectSetY(self.shareButton.frame, targetY);
                CGRectSetY(self.tagButton.frame, targetY);
                break;
        }
    };
    return block;
}
-(voidBlock)getShowBlockForState:(KPControlHandlerState)state{
    CGFloat bigButtonY = [self getYForBigSize:YES];
    CGFloat smallButtonY = [self getYForBigSize:NO];
    voidBlock block = ^(void) {
        switch (state) {
            case KPControlHandlerStateNone:
                break;
            case KPControlHandlerStateAdd:
                CGRectSetY(self.addButton.frame, bigButtonY);
                break;
            case KPControlHandlerStateEdit:
                CGRectSetY(self.deleteButton.frame, smallButtonY);
                CGRectSetY(self.shareButton.frame, smallButtonY);
                CGRectSetY(self.tagButton.frame, smallButtonY);
                break;
        }
    };
    return block;
}
-(void)setState:(KPControlHandlerState)state animated:(BOOL)animated{
    if(state == self.activeState) return;
    voidBlock clearBlock = [self getClearBlockForState:self.activeState];
    CGFloat clearDuration = (self.activeState == KPControlHandlerStateNone) ? 0 : ANIMATION_DURATION;
    CGFloat showDuration = (state == KPControlHandlerStateNone) ? 0 : ANIMATION_DURATION;
    UIViewAnimationOptions clearAnimationOption = UIViewAnimationOptionCurveEaseIn;
    UIViewAnimationOptions showAnimationOption = UIViewAnimationOptionCurveEaseInOut;
    voidBlock showBlock = [self getShowBlockForState:state];
    if(animated){
        if(clearDuration == 0){
            clearBlock();
            clearBlock = showBlock;
            clearAnimationOption = showAnimationOption;
            showBlock = nil;
            clearDuration = showDuration;
        }
        [UIView animateWithDuration:clearDuration delay:0 options:clearAnimationOption animations:clearBlock completion:^(BOOL finished) {
            if(finished && showBlock){
                if(showDuration == 0) showBlock();
                else [UIView animateWithDuration:showDuration delay:0 options:showAnimationOption animations:showBlock completion:nil];
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
-(void)pressedTag:(id)sender{
    if([self.delegate respondsToSelector:@selector(pressedTag:)]) [self.delegate pressedTag:self];
}
-(void)pressedShare:(id)sender{
    if([self.delegate respondsToSelector:@selector(pressedShare:)]) [self.delegate pressedShare:self];
}
@end
