//
//  KPPopup.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 07/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define CONTAINER_VIEW_TAG 1331

#define DEFAULT_CONTENT_SIZE 200
#define ANIMATION_SCALE 0.1
#define ANIMATION_DURATION 0.1
#define EXTRA_SCALE 1.02
#define EXTRA_DURATION 0.02

#import "KPPopup.h"
@interface KPPopup ()
@end
@implementation KPPopup

-(void)cancelled{
    NSAssert(YES,@"Should be overwritten");
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.backgroundColor = POPUP_OVERLAY_COLOR;
        UIButton *backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backgroundButton.frame = backgroundView.bounds;
        [backgroundButton addTarget:self action:@selector(pressedBackground:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:backgroundButton];
        [self addSubview:backgroundView];
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width-DEFAULT_CONTENT_SIZE)/2, (self.frame.size.height-DEFAULT_CONTENT_SIZE)/2, DEFAULT_CONTENT_SIZE, DEFAULT_CONTENT_SIZE)];
        containerView.hidden = YES;
        containerView.tag = CONTAINER_VIEW_TAG;
        [self addSubview:containerView];
        self.containerView = [self viewWithTag:CONTAINER_VIEW_TAG];
    }
    return self;
}
-(void)pressedBackground:(id)sender{
    [self show:NO completed:^(BOOL succeeded, NSError *error) {
        [self cancelled];
    }];
}
-(void)setContainerSize:(CGSize)size{
    self.containerView.frame = CGRectMake((self.frame.size.width-size.width)/2, (self.frame.size.height-size.height)/2, size.width, size.height);
}
-(void)show:(BOOL)show completed:(SuccessfulBlock)block{
    if(show){
        
        self.containerView.transform = CGAffineTransformMakeScale(ANIMATION_SCALE, ANIMATION_SCALE);
        self.containerView.hidden = NO;
        [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.containerView.transform = CGAffineTransformMakeScale(EXTRA_SCALE, EXTRA_SCALE);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:EXTRA_DURATION delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.containerView.transform = CGAffineTransformMakeScale(EXTRA_SCALE/EXTRA_SCALE, EXTRA_SCALE/EXTRA_SCALE);
            } completion:^(BOOL finished) {
                if(block) block(finished,nil);
            }];
        }];
    }else{
        [UIView animateWithDuration:EXTRA_DURATION delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.containerView.transform = CGAffineTransformMakeScale(EXTRA_SCALE, EXTRA_SCALE);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.containerView.transform = CGAffineTransformMakeScale(ANIMATION_SCALE, ANIMATION_SCALE);
            } completion:^(BOOL finished) {
                self.hidden = YES;
                if(block) block(finished,nil);
                [self removeFromSuperview];
            }];
        }];
    }
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
