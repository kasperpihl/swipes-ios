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

@interface KPControlHandler () <ToolbarDelegate>
@property (nonatomic) KPControlHandlerState activeState;
@property (nonatomic,weak) UIView* view;
@property (nonatomic,weak) UITableView *shrinkingView;
@property (nonatomic,weak) KPToolbar *addToolbar;
@property (nonatomic,weak) KPToolbar *editToolbar;
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
        
        KPToolbar *addToolbar = [[KPToolbar alloc] initWithFrame:CGRectMake(0, view.frame.size.height, view.frame.size.width, ADD_TOOLBAR_HEIGHT) items:@[@"toolbar_plus_icon"]];
        addToolbar.tag = ADD_TOOLBAR_TAG;
        addToolbar.delegate = self;
        [view addSubview:addToolbar];
        self.addToolbar = (KPToolbar*)[view viewWithTag:ADD_TOOLBAR_TAG];
        
        KPToolbar *editToolbar = [[KPToolbar alloc] initWithFrame:CGRectMake(0, view.frame.size.height, view.frame.size.width, EDIT_TOOLBAR_HEIGHT) items:@[@"toolbar_tag_icon",@"toolbar_trashcan_icon",@"toolbar_share_icon"]];
        editToolbar.tag = EDIT_TOOLBAR_TAG;
        editToolbar.delegate = self;
        [view addSubview:editToolbar];
        self.editToolbar = (KPToolbar*)[view viewWithTag:EDIT_TOOLBAR_TAG];
        
        [self setState:KPControlHandlerStateAdd shrinkingView:self.shrinkingView animated:NO];
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
                CGRectSetY(self.addToolbar, targetY);
                break;
            case KPControlHandlerStateEdit:
                [self shrinkTableView:NO];
                //CGRectSetY(self.deleteButton, targetY);
                CGRectSetY(self.editToolbar, targetY);
                //CGRectSetY(self.tagButton, targetY);
                break;
        }
    };
    return block;
}
-(void)setLock:(BOOL)lock animated:(BOOL)animated{
    if(_lock != lock){
        if(lock) [self setState:KPControlHandlerStateNone shrinkingView:self.shrinkingView animated:animated];
        _lock = lock;
    }
}
-(void)setLock:(BOOL)lock{
    [self setLock:lock animated:YES];
}
-(void)forceHide{
    CGFloat targetY = self.view.frame.size.height;
    CGRectSetY(self.addToolbar, targetY);
    CGRectSetY(self.editToolbar, targetY);
}
-(void)shrinkTableView:(BOOL)shrink{
    return;
    CGFloat shrinkHeight = shrink ? 60 : 0;
    self.shrinkingView.contentInset = UIEdgeInsetsMake(0, 0, shrinkHeight, 0);
    //CGRectSetHeight(self.shrinkingView, self.view.frame.size.height-heightForNavigation-shrinkHeight);
}
-(voidBlock)getShowBlockForState:(KPControlHandlerState)state{
    CGFloat bigButtonY = [self getYForBigSize:YES];
    CGFloat smallButtonY = [self getYForBigSize:NO];
    voidBlock block = ^(void) {
        switch (state) {
            case KPControlHandlerStateNone:
                break;
            case KPControlHandlerStateAdd:
                CGRectSetY(self.addToolbar, smallButtonY);
                break;
            case KPControlHandlerStateEdit:
                [self shrinkTableView:YES];
                //CGRectSetY(self.deleteButton, smallButtonY);
                CGRectSetY(self.editToolbar, bigButtonY);
                //CGRectSetY(self.tagButton, smallButtonY);
                break;
        }
    };
    return block;
}
-(void)setState:(KPControlHandlerState)state shrinkingView:(UITableView *)view animated:(BOOL)animated{
    if(state == self.activeState || self.lock) return;
    self.shrinkingView = view;
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
-(void)toolbar:(KPToolbar *)toolbar pressedItem:(NSInteger)item{
    if(toolbar.tag == ADD_TOOLBAR_TAG){
        if(item == 0 && [self.delegate respondsToSelector:@selector(pressedAdd:)]) [self.delegate pressedAdd:self];
    }
    else{
        if(item == 0 && [self.delegate respondsToSelector:@selector(pressedTag:)]){
            [self.delegate pressedTag:self];
        }
        else if(item == 1 && [self.delegate respondsToSelector:@selector(pressedDelete:)]){
            [self.delegate pressedDelete:self];
        }
    }
}
@end
