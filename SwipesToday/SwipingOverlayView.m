//
//  SwipeTestingView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 07/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "SwipingOverlayView.h"
#define kTapThreshold 0.4
#define kTapMovementMaximum 10
@interface SwipingOverlayView () <UIGestureRecognizerDelegate>
@property CGFloat startX;
@property CGFloat startY;
@property CGFloat lastX;
@property CGFloat lastY;
@property CGFloat startTime;
@property BOOL notATap;
@property BOOL lock;
@end
@implementation SwipingOverlayView
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.lock = YES;
    self.startTime = CACurrentMediaTime();
    self.notATap = NO;
    UITouch *touch = [touches anyObject];
    CGPoint translation = [touch locationInView:self];
    self.startX = self.lastX = translation.x;
    self.startY = self.lastY = translation.y;
    
    [self.delegate swipingDidStartOverlay:self];
    

}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint translation = [touch locationInView:self];
    CGPoint totalMovement = CGPointMake(translation.x-self.startX,translation.y-self.startY);
    CGPoint relativeMovement = CGPointMake(translation.x-self.lastX,translation.y-self.lastY);
    self.lastX = translation.x;
    self.lastY = translation.y;
    if(ABS(totalMovement.x) > kTapMovementMaximum || ABS(totalMovement.y) > kTapMovementMaximum)
        self.notATap = YES;
    if(self.notATap)
        [self.delegate swipingOverlay:self didMoveDistance:totalMovement relative:relativeMovement];
    //NSLog(@"relative: %f",translation.x-self.startX);

}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint translation = [touch locationInView:self];
    CGPoint totalMovement = CGPointMake(translation.x-self.startX,translation.y-self.startY);
    CGPoint relativeMovement = CGPointMake(translation.x-self.lastX,translation.y-self.lastY);
    self.lock = NO;
    if(!self.notATap && (CACurrentMediaTime() - self.startTime) < kTapThreshold)
        return [self.delegate didTapSwipingOverlay:self];
    [self.delegate swipingOverlay:self didEndWithDistance:totalMovement relative:relativeMovement];
    
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.delegate swipingDidCancelOverlay:self];
    self.lock = NO;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        UIPanGestureRecognizer *gestures = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
        [self addGestureRecognizer:gestures];
        [gestures setDelegate:self];
    }
    return self;
}
- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture{
    CGPoint translation = [gesture translationInView:self];
    NSLog(@"x %f",translation.x);
}
@end
