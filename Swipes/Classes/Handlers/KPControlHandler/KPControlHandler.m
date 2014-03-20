//
//  KPControlView.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 22/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#define ADD_TOOLBAR_TAG 13004
#define EDIT_TOOLBAR_TAG 13003


#define ADD_TOOLBAR_HEIGHT GLOBAL_TOOLBAR_HEIGHT
#define EDIT_TOOLBAR_HEIGHT GLOBAL_TOOLBAR_HEIGHT


#import "KPControlHandler.h"
#import "KPToolbar.h"
#import <QuartzCore/QuartzCore.h>

#import "UIImage+Utilities.h"


@interface KPControlHandler () <ToolbarDelegate>
@property (nonatomic) KPControlHandlerState activeState;
@property (nonatomic) KPControlHandlerState lastChosen;
@property (nonatomic,weak) UIView* view;
@property (nonatomic,weak) KPToolbar *addToolbar;
@property (nonatomic,weak) KPToolbar *editToolbar;
@property (nonatomic) UIView *gradientView;
@property (nonatomic) BOOL isShowingGradient;
@property (nonatomic) BOOL hasStarted;
@end
@implementation KPControlHandler
+(KPControlHandler*)instanceInView:(UIView*)view{
    KPControlHandler *object = [[KPControlHandler alloc] initWithView:view];
    object.view = view;
    return object;
}
-(CGFloat)getYForBigSize:(BOOL)big{
    CGFloat size;
    if(big) size = (self.view.frame.size.height-EDIT_TOOLBAR_HEIGHT);
    else size = (self.view.frame.size.height-ADD_TOOLBAR_HEIGHT);
    return size;
}
- (id)initWithView:(UIView*)view
{
    self = [super init];
    if (self) {
        self.view = view;
        
        
        UIView *gradientBackground = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height, view.frame.size.width, EDIT_TOOLBAR_HEIGHT)];
        CAGradientLayer *agradient = [CAGradientLayer layer];
        agradient.frame = gradientBackground.bounds;
        agradient.colors = @[(id)alpha(tcolor(BackgroundColor),0.0f).CGColor,(id)alpha(tcolor(BackgroundColor),1.0f).CGColor,(id)tcolor(BackgroundColor).CGColor];
        agradient.locations = @[@0.0,@0.4,@1.0];
        [gradientBackground.layer insertSublayer:agradient atIndex:0];
        self.gradientView = gradientBackground;
        [view addSubview:self.gradientView];
        
        
        KPToolbar *addToolbar = [[KPToolbar alloc] initWithFrame:CGRectMake(0, view.frame.size.height, view.frame.size.width, ADD_TOOLBAR_HEIGHT) items:@[timageStringBW(@"round_plus")] delegate:self];
        addToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        addToolbar.tag = ADD_TOOLBAR_TAG;
        [addToolbar setTopInset:-addToolbar.frame.size.height*0.05];
        [view addSubview:addToolbar];
        self.addToolbar = (KPToolbar*)[view viewWithTag:ADD_TOOLBAR_TAG];
        
        
        KPToolbar *editToolbar = [[KPToolbar alloc] initWithFrame:CGRectMake(0, view.frame.size.height, view.frame.size.width, EDIT_TOOLBAR_HEIGHT) items:@[timageStringBW(@"edit_icon"),timageStringBW(@"tag_icon"),timageStringBW(@"trashcan_icon"),timageStringBW(@"share_icon")] delegate:self];
        editToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        editToolbar.tag = EDIT_TOOLBAR_TAG;
        [editToolbar setTopInset:editToolbar.frame.size.height*0.05];
        [view addSubview:editToolbar];
        self.editToolbar = (KPToolbar*)[view viewWithTag:EDIT_TOOLBAR_TAG];
        
        [self setState:KPControlHandlerStateAdd animated:NO];
    }
    return self;
}
-(voidBlock)getClearBlockFromState:(KPControlHandlerState)state toState:(KPControlHandlerState)toState{
    CGFloat targetY = self.view.frame.size.height;
    voidBlock block = ^(void) {
        switch (state) {
            case KPControlHandlerStateAdd:
                CGRectSetY(self.addToolbar, targetY);
                break;
            case KPControlHandlerStateEdit:
                CGRectSetY(self.editToolbar, targetY);
                break;
            default:
                break;
        }
    };
    return block;
}

-(void)setLockGradient:(BOOL)lockGradient{
    if(_lockGradient != lockGradient){
        _lockGradient = lockGradient;
        CGFloat targetY = lockGradient ? self.view.frame.size.height : [self getYForBigSize:YES];
        CGRectSetY(self.gradientView, targetY);
    }
}
-(voidBlock)getShowBlockForState:(KPControlHandlerState)state{
    CGFloat bigButtonY = [self getYForBigSize:YES];
    CGFloat smallButtonY = [self getYForBigSize:NO];
    voidBlock block = ^(void) {
        switch (state) {
            case KPControlHandlerStateAdd:
                if(!self.isShowingGradient && !self.lockGradient){
                    CGRectSetY(self.gradientView, smallButtonY);
                    self.isShowingGradient = YES;
                }
                CGRectSetY(self.addToolbar, smallButtonY);
                
                break;
            case KPControlHandlerStateEdit:
                if(!self.isShowingGradient && !self.lockGradient){
                    CGRectSetY(self.gradientView, smallButtonY);
                    self.isShowingGradient = YES;
                }
                CGRectSetY(self.editToolbar, bigButtonY);
                break;
            default:
                break;
        }
    };
    return block;
}
-(void)finishedChangeForState:(KPControlHandlerState)state{
    /*KPControlHandlerState stateToClear = (self.activeState == KPControlHandlerStateAdd) ? KPControlHandlerStateEdit : KPControlHandlerStateAdd;
    [self getClearBlockFromState:stateToClear toState:self.activeState];*/
    self.activeState = state;
    if(self.lastChosen != self.activeState) [self setState:self.lastChosen animated:YES];
}
-(void)setState:(KPControlHandlerState)state animated:(BOOL)animated{
    self.lastChosen = state;
    if(state == self.activeState && self.hasStarted) return;
    
    if(!self.hasStarted) self.hasStarted = YES;
    voidBlock clearBlock = [self getClearBlockFromState:self.activeState toState:state];
    CGFloat clearDuration = ANIMATION_DURATION;
    CGFloat showDuration = ANIMATION_DURATION;
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
                if(showDuration == 0){
                    showBlock();
                    [self finishedChangeForState:state];
                }
                else [UIView animateWithDuration:showDuration delay:0 options:showAnimationOption animations:showBlock completion:^(BOOL finished) {
                    [self finishedChangeForState:state];
                }];
            }
        }];
    }
    else{
        clearBlock();
        showBlock();
        [self finishedChangeForState:state];
        //if(self.lock) [self forceHide];
    }
    
}
-(void)toolbar:(KPToolbar *)toolbar pressedItem:(NSInteger)item{
    if(toolbar.tag == ADD_TOOLBAR_TAG){
        if(item == 0 && [self.delegate respondsToSelector:@selector(pressedAdd:)]) [self.delegate pressedAdd:self];
    }
    else{
        if(item == 0 && [self.delegate respondsToSelector:@selector(pressedEdit:)]) [self.delegate pressedEdit:self];
        else if(item == 1 && [self.delegate respondsToSelector:@selector(pressedTag:)]) [self.delegate pressedTag:self];
        else if(item == 2 && [self.delegate respondsToSelector:@selector(pressedDelete:)]) [self.delegate pressedDelete:self];
        else if(item == 3 && [self.delegate respondsToSelector:@selector(pressedShare:)]) [self.delegate pressedShare:self];
    }
}
@end
