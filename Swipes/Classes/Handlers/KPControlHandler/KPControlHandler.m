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
#define TOOLBAR_TAG 13003

#define BIG_BUTTON_HEIGHT 65
#define BIG_BUTTON_BOTTOM_MARGIN 15
#define SMALL_BUTTON_HEIGHT 60
#define SMALL_BUTTON_BOTTOM_MARGIN 15

#define ANIMATION_DURATION 0.15f

#define ADD_BUTTON_X ((320/2)-(BIG_BUTTON_HEIGHT/2))

#define SMALL_BUTTON_SPACING 24


#define TAG_BUTTON_X ((320/2)+(SMALL_BUTTON_SPACING/2))
#define DELETE_BUTTON_X ((320/2)-(SMALL_BUTTON_HEIGHT)-(SMALL_BUTTON_SPACING/2))
//(TAG_BUTTON_X - SMALL_BUTTON_SPACING - SMALL_BUTTON_HEIGHT)
#define SHARE_BUTTON_X (TAG_BUTTON_X + SMALL_BUTTON_HEIGHT + SMALL_BUTTON_SPACING)

#define DESELECT_BUTTON_X 150

#import "UtilityClass.h"
#import "KPControlHandler.h"
#import "RootViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "KPToolbar.h"

@interface KPControlHandler () <ToolbarDelegate>
@property (nonatomic) KPControlHandlerState activeState;
@property (nonatomic,weak) UIView* view;
@property (nonatomic,weak) UIButton *addButton;
@property (nonatomic,weak) KPToolbar *toolbar;
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
    else size = (self.view.frame.size.height-SMALL_BUTTON_HEIGHT);
    return size;
}
- (id)initWithView:(UIView*)view
{
    self = [super init];
    if (self) {
        self.view = view;
        
        
        UIButton *addButton = [self roundedButtonWithSize:BIG_BUTTON_HEIGHT];
        addButton.frame = CGRectSetPos(addButton.frame, ADD_BUTTON_X,view.frame.size.height);
        addButton.tag = ADD_BUTTON_TAG;
        addButton.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin);
        [addButton addTarget:self action:@selector(pressedAdd:) forControlEvents:UIControlEventTouchUpInside];
        [addButton setImage:[UIImage imageNamed:@"addbutton"] forState:UIControlStateNormal];
        [view addSubview:addButton];
        self.addButton = (UIButton*)[view viewWithTag:ADD_BUTTON_TAG];
        
        KPToolbar *toolbar = [[KPToolbar alloc] initWithFrame:CGRectMake(0, view.frame.size.height, view.frame.size.width, 60) items:@[@"toolbar_tag_icon",@"toolbar_trashcan_icon",@"toolbar_share_icon"]];
        toolbar.tag = TOOLBAR_TAG;
        toolbar.backgroundColor = tbackground(MenuBackground);
        toolbar.delegate = self;
        toolbar.seperatorColor = tcolor(SearchDrawerColor);
        [view addSubview:toolbar];
        self.toolbar = (KPToolbar*)[view viewWithTag:TOOLBAR_TAG];
        
        [self setState:KPControlHandlerStateAdd animated:NO];
    }
    return self;
}
-(UIButton*)roundedButtonWithSize:(NSInteger)size{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonBackgroundImage = [UtilityClass imageWithColor:tcolor(ColoredButton)];
    CGRectSetSize(button, size, size);
    button.layer.cornerRadius = size/2;
    button.layer.masksToBounds = YES;
    [button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    return button;
}
-(voidBlock)getClearBlockForState:(KPControlHandlerState)state{
    CGFloat targetY = self.view.frame.size.height;
    voidBlock block = ^(void) {
        switch (state) {
            case KPControlHandlerStateNone:
                break;
            case KPControlHandlerStateAdd:
                CGRectSetY(self.addButton, targetY);
                break;
            case KPControlHandlerStateEdit:
                //CGRectSetY(self.deleteButton, targetY);
                CGRectSetY(self.toolbar, targetY);
                //CGRectSetY(self.tagButton, targetY);
                break;
        }
    };
    return block;
}
-(void)setLock:(BOOL)lock{
    if(_lock != lock){
        if(lock) [self setState:KPControlHandlerStateNone animated:YES];
        _lock = lock;
    }
}
-(void)forceHide{
    CGFloat targetY = self.view.frame.size.height;
    CGRectSetY(self.addButton, targetY);
    CGRectSetY(self.toolbar, targetY);
    //CGRectSetY(self.deleteButton, targetY);
    //CGRectSetY(self.tagButton, targetY);
}
-(voidBlock)getShowBlockForState:(KPControlHandlerState)state{
    CGFloat bigButtonY = [self getYForBigSize:YES];
    CGFloat smallButtonY = [self getYForBigSize:NO];
    voidBlock block = ^(void) {
        switch (state) {
            case KPControlHandlerStateNone:
                break;
            case KPControlHandlerStateAdd:
                CGRectSetY(self.addButton, bigButtonY);
                break;
            case KPControlHandlerStateEdit:
                //CGRectSetY(self.deleteButton, smallButtonY);
                CGRectSetY(self.toolbar, smallButtonY);
                //CGRectSetY(self.tagButton, smallButtonY);
                break;
        }
    };
    return block;
}
-(void)setState:(KPControlHandlerState)state animated:(BOOL)animated{
    if(state == self.activeState || self.lock) return;
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
            if(self.lock){
                [self forceHide];
                return;
            }
            if(finished && showBlock){
                if(showDuration == 0) showBlock();
                else [UIView animateWithDuration:showDuration delay:0 options:showAnimationOption animations:showBlock completion:^(BOOL finished) {
                    if(self.lock) [self forceHide];
                }];
            }
        }];
    }
    else{
        clearBlock();
        showBlock();
        if(self.lock) [self forceHide];
    }
    self.activeState = state;
}
-(void)pressedAdd:(id)sender{
    if([self.delegate respondsToSelector:@selector(pressedAdd:)]) [self.delegate pressedAdd:self];
}
-(void)toolbar:(KPToolbar *)toolbar pressedItem:(NSInteger)item{
    if(item == 0 && [self.delegate respondsToSelector:@selector(pressedTag:)]){
        [self.delegate pressedTag:self];
    }
    else if(item == 0 && [self.delegate respondsToSelector:@selector(pressedDelete:)]){
        [self.delegate pressedDelete:self];
    }
}
@end
