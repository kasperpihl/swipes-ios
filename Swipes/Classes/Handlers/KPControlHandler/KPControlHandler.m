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
#define kActionButtonSize 42

#import "AudioHandler.h"
#import "KPControlHandler.h"
#import "KPToolbar.h"
#import <QuartzCore/QuartzCore.h>
#import "AwesomeMenu.h"
#import "UIColor+Utilities.h"
#import "UIImage+Utilities.h"


@interface KPControlHandler () <ToolbarDelegate, AwesomeMenuDelegate>
@property (nonatomic) KPControlHandlerState activeState;
@property (nonatomic) KPControlHandlerState lastChosen;
@property (nonatomic,weak) UIView* view;
@property (nonatomic) AwesomeMenu *awesomeMenu;
@property (nonatomic,weak) KPToolbar *addToolbar;
@property (nonatomic,weak) KPToolbar *editToolbar;

@property (nonatomic) UIButton *tagButton;
@property (nonatomic) UIButton *deleteButton;
@property (nonatomic) UIButton *shareButton;

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
    if(big) size = (self.view.frame.size.height-kActionButtonSize-5-self.bottomPadding);
    else size = (self.view.frame.size.height-ADD_TOOLBAR_HEIGHT-self.bottomPadding);
    return size;
}
-(void)addAwesomeMenu{
    if(self.awesomeMenu){
        [self.awesomeMenu removeFromSuperview];
        self.awesomeMenu = nil;
    }
    AwesomeMenuItem *starMenuItem1 = [[AwesomeMenuItem alloc] initWithImageString:iconString(@"actionMenuSettings")];
    AwesomeMenuItem *starMenuItem2 = [[AwesomeMenuItem alloc] initWithImageString:iconString(@"actionMenuSearch")];
    AwesomeMenuItem *starMenuItem3 = [[AwesomeMenuItem alloc] initWithImageString:iconString(@"actionMenuFilter")];
    AwesomeMenuItem *starMenuItem4 = [[AwesomeMenuItem alloc] initWithImageString:iconString(@"actionMenuSelect")];
    
    AwesomeMenu *menu = [[AwesomeMenu alloc] initWithFrame:self.view.bounds menus:[NSArray arrayWithObjects:starMenuItem1,starMenuItem2,starMenuItem3,starMenuItem4, nil]];
    menu.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    menu.startPoint = CGPointMake(self.view.bounds.size.width-30, self.view.bounds.size.height-30);
    menu.addButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    
    menu.rotateAngle = radians(270);
    menu.endRadius = 90;
    menu.nearRadius = 85;
    menu.farRadius = 105;
    menu.menuWholeAngle = radians(120);
    //menu.frame = CGRectSetPos(menu.frame, ;
    menu.delegate = self;
    self.awesomeMenu = menu;
    [self.view addSubview:self.awesomeMenu];
}
- (id)initWithView:(UIView*)view
{
    self = [super init];
    if (self) {
        self.view = view;
        
        
        UIView *gradientBackground = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height, view.frame.size.width, EDIT_TOOLBAR_HEIGHT)];
        CAGradientLayer *agradient = [CAGradientLayer layer];
        agradient.frame = gradientBackground.bounds;
        gradientBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        agradient.colors = @[(id)alpha(tcolor(BackgroundColor),0.0f).CGColor,(id)alpha(tcolor(BackgroundColor),1.0f).CGColor,(id)tcolor(BackgroundColor).CGColor];
        agradient.locations = @[@0.0,@0.4,@1.0];
        [gradientBackground.layer insertSublayer:agradient atIndex:0];
        self.gradientView = gradientBackground;
        [view addSubview:self.gradientView];
        
        [self addAwesomeMenu];
        
        KPToolbar *addToolbar = [[KPToolbar alloc] initWithFrame:CGRectMake(view.frame.size.width/3, view.frame.size.height, view.frame.size.width/3, ADD_TOOLBAR_HEIGHT) items:nil delegate:self];
        addToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        addToolbar.font = iconFont(45);
        addToolbar.titleColor = tcolor(TextColor);
        addToolbar.titleHighlightString = @"Full";
        addToolbar.items = @[@"roundAdd"];

        addToolbar.tag = ADD_TOOLBAR_TAG;
        [addToolbar setTopInset:-addToolbar.frame.size.height*0.05];
        
        [view addSubview:addToolbar];
        self.addToolbar = (KPToolbar*)[view viewWithTag:ADD_TOOLBAR_TAG];
        
        CGFloat oneThird = 320/5;
        CGFloat spacing = oneThird;
        
        self.tagButton = [self actionButtonWithTitle:@"actionTag"];
        [self.tagButton addTarget:self action:@selector(pressedTag:) forControlEvents:UIControlEventTouchUpInside];
        self.tagButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleTopMargin;
        CGRectSetCenterX(self.tagButton, view.frame.size.width/2 - spacing);
        [view addSubview:self.tagButton];
        
        self.deleteButton = [self actionButtonWithTitle:@"actionDelete"];
        [self.deleteButton addTarget:self action:@selector(pressedDelete:) forControlEvents:UIControlEventTouchUpInside];
        self.deleteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleTopMargin;
        CGRectSetCenterX(self.deleteButton, view.frame.size.width/2);
        [view addSubview:self.deleteButton];
        
        self.shareButton = [self actionButtonWithTitle:@"actionShare"];
        [self.shareButton addTarget:self action:@selector(pressedShare:) forControlEvents:UIControlEventTouchUpInside];
        self.shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleTopMargin;
        CGRectSetCenterX(self.shareButton, view.frame.size.width/2+spacing);
        [view addSubview:self.shareButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:@"willRotateToInterfaceOrientation"
                                                   object:nil];
        [self setState:KPControlHandlerStateAdd animated:NO];
    }
    return self;
}

-(void)pressedTag:(UIButton*)sender
{
    if([self.delegate respondsToSelector:@selector(pressedTag:)])
        [self.delegate pressedTag:self];
}

-(void)pressedDelete:(UIButton*)sender
{
    if([self.delegate respondsToSelector:@selector(pressedDelete:)])
        [self.delegate pressedDelete:self];
}

-(void)pressedShare:(UIButton*)sender
{
    if([self.delegate respondsToSelector:@selector(pressedShare:)])
        [self.delegate pressedShare:sender];
}

-(UIButton*)actionButtonWithTitle:(NSString*)title{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, kActionButtonSize, kActionButtonSize)];
    button.backgroundColor = tcolor(BackgroundColor);
    [button setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
    [button setTitleColor:tcolor(BackgroundColor) forState:UIControlStateHighlighted];
    [button setBackgroundImage:[tcolor(BackgroundColor) image] forState:UIControlStateNormal];
    [button setBackgroundImage:[tcolor(TextColor) image] forState:UIControlStateHighlighted];
    button.titleLabel.font = iconFont(23);
    [button setTitle:iconString(title) forState:UIControlStateNormal];
    button.layer.cornerRadius = kActionButtonSize/2;
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = 1;
    button.layer.borderColor = tcolor(TextColor).CGColor;
    return button;
}

-(voidBlock)getClearBlockFromState:(KPControlHandlerState)state toState:(KPControlHandlerState)toState{
    CGFloat targetY = self.view.frame.size.height;
    voidBlock block = ^(void) {
        switch (state) {
            case KPControlHandlerStateAdd:
                CGRectSetY(self.addToolbar, targetY);
                CGRectSetY(self.awesomeMenu, CGRectGetMaxY(self.awesomeMenu.frame)-self.awesomeMenu.startPoint.y+self.awesomeMenu.addButton.frame.size.height/2);
                break;
            case KPControlHandlerStateEdit:
                CGRectSetY(self.tagButton, targetY);
                CGRectSetY(self.deleteButton, targetY);
                CGRectSetY(self.shareButton, targetY);
                break;
            default:
                break;
        }
        if(toState == KPControlHandlerStateNone && !self.lockGradient){
            CGRectSetY(self.gradientView, targetY);
            self.isShowingGradient = NO;
        }
    };
    return block;
}
-(void)setBottomPadding:(CGFloat)bottomPadding{
    if(_bottomPadding != bottomPadding){
        _bottomPadding = bottomPadding;
    }
    
}
-(void)setLockGradient:(BOOL)lockGradient{
    if(_lockGradient != lockGradient){
        _lockGradient = lockGradient;
        CGFloat targetY = lockGradient ? self.view.frame.size.height-self.bottomPadding : [self getYForBigSize:YES];
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
                CGRectSetY(self.awesomeMenu, self.awesomeMenu.superview.frame.size.height-self.awesomeMenu.frame.size.height-self.bottomPadding);
                
                break;
            case KPControlHandlerStateEdit:
                if(!self.isShowingGradient && !self.lockGradient){
                    CGRectSetY(self.gradientView, smallButtonY);
                    self.isShowingGradient = YES;
                }
                CGRectSetY(self.tagButton, bigButtonY);
                CGRectSetY(self.deleteButton, bigButtonY);
                CGRectSetY(self.shareButton, bigButtonY);
                
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

#pragma mark AwesomeMenuDelegate
-(void)AwesomeMenuWillExpand:(AwesomeMenu *)menu{
    CGFloat targetY = self.view.frame.size.height;
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRectSetY(self.addToolbar, targetY);
    } completion:^(BOOL finished) {
        
    }];
    //[self.controlHandler setState:KPControlHandlerStateNone animated:YES];
}
-(void)cleanFromAwesomeMenu{
    if(self.activeState == KPControlHandlerStateAdd && !self.awesomeMenu.isExpanding){
        CGFloat smallButtonY = [self getYForBigSize:NO];
        [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            CGRectSetY(self.addToolbar, smallButtonY);
        } completion:^(BOOL finished) {
            
        }];
    }
}
-(void)AwesomeMenuDidCollapse:(AwesomeMenu *)menu{
    [self cleanFromAwesomeMenu];
    

    //[self.controlHandler setState:KPControlHandlerStateAdd animated:YES];
}
-(void)AwesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx{
    [self cleanFromAwesomeMenu];
    if([self.delegate respondsToSelector:@selector(pressedAwesomeMenuIndex:)])
        [self.delegate pressedAwesomeMenuIndex:idx];
    
}

-(void)dealloc{
    clearNotify();
}
- (void)orientationChanged:(NSNotification *)notification
{
    [self addAwesomeMenu];
    [self cleanFromAwesomeMenu];
}

-(void)toolbar:(KPToolbar *)toolbar pressedItem:(NSInteger)item{
    if(item == 0 && [self.delegate respondsToSelector:@selector(pressedAdd:)]) [self.delegate pressedAdd:self];
}
@end
