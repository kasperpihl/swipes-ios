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
    if([self.delegate respondsToSelector:@selector(swipingDidStartOverlay:)])
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
    if(self.notATap && [self.delegate respondsToSelector:@selector(swipingOverlay:didMoveDistance:relative:)])
        [self.delegate swipingOverlay:self didMoveDistance:totalMovement relative:relativeMovement];
    //NSLog(@"relative: %f",translation.x-self.startX);

}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint translation = [touch locationInView:self];
    CGPoint totalMovement = CGPointMake(translation.x-self.startX,translation.y-self.startY);
    CGPoint relativeMovement = CGPointMake(translation.x-self.lastX,translation.y-self.lastY);
    self.lock = NO;
    if(!self.notATap && (CACurrentMediaTime() - self.startTime) < kTapThreshold && [self.delegate respondsToSelector:@selector(swipingOverlay:didTapInPoint:)])
        return [self.delegate swipingOverlay:self didTapInPoint:CGPointMake(self.lastX, self.lastY)];
    if([self.delegate respondsToSelector:@selector(swipingOverlay:didEndWithDistance:relative:)])
        [self.delegate swipingOverlay:self didEndWithDistance:totalMovement relative:relativeMovement];
    
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if([self.delegate respondsToSelector:@selector(swipingDidCancelOverlay:)])
        [self.delegate swipingDidCancelOverlay:self];
    self.lock = NO;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
    }
    return self;
}
@end
