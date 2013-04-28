//
//  KPTagView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPAddTagPanel.h"

#import "DWTagList.h"
#import "UtilityClass.h"
#define BACKGROUND_VIEW_TAG 2
#define TAG_VIEW_TAG 3
#define ANIMATION_DURATION 0.25f

@interface KPAddTagPanel ()
@property (nonatomic,weak) IBOutlet UIView *backgroundView;
@end
@implementation KPAddTagPanel
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.tag = BACKGROUND_VIEW_TAG;
        backgroundView.backgroundColor = [UtilityClass colorWithRed:125 green:125 blue:125 alpha:0.5];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = backgroundView.frame;
        [closeButton addTarget:self action:@selector(didPressClose:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:closeButton];
        [self addSubview:backgroundView];
        self.backgroundView = [self viewWithTag:BACKGROUND_VIEW_TAG];
        
        
        KPTagList *tagView = [[KPTagList alloc] initWithFrame:CGRectMake(0, 5, 320, 60)];
        tagView.tag = TAG_VIEW_TAG;
        [self addSubview:tagView];
        
        
        /*
        DWTagList *tagList = [[DWTagList alloc] initWithFrame:self.bounds];
        
        //CGRectSetY(tagList.frame, 50);
        self.backgroundColor = [UIColor whiteColor];
        [tagList setTags:@[@"Tag1",@"Tag2",@"Tag3"]];
        [self addSubview:tagList];*/
        
    }
    return self;
}
-(void)pressedCreateTag:(id)sender{
    
}
-(void)didPressClose:(id)sender{
    [self show:NO];
}
-(void)show:(BOOL)show{
    void (^preblock)(void);
    void (^showBlock)(void);
    void (^completionBlock)(void);
    if(show){
        preblock = ^(void){
            self.backgroundView.alpha = 0;
        };
        showBlock = ^(void) {
            self.backgroundView.alpha = 1;
        };
    }
    else{
        preblock = ^(void){
        };
        showBlock = ^(void) {
            self.backgroundView.alpha = 0;
        };
        completionBlock = ^(void){
            /*if([self.tagDelegate respondsToSelector:@selector(tagPanel:closedWithSelectedTags:unselectedTags:)]) [self.tagDelegate tagPanel:self closedWithSelectedTags:self.selectedTags unselectedTags:self.unselectedTags];*/
            [self removeFromSuperview];
        };
        
    }
    preblock();
    [UIView animateWithDuration:ANIMATION_DURATION animations:showBlock completion:^(BOOL finished) {
        if(finished){
            if(completionBlock) completionBlock();
        }
    }];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
