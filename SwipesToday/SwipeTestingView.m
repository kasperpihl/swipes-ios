//
//  SwipeTestingView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 07/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "SwipeTestingView.h"

@interface SwipeTestingView () <UIGestureRecognizerDelegate>
@property CGFloat startX;
@end
@implementation SwipeTestingView
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint translation = [touch locationInView:self];
    self.startX = translation.x;

}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint translation = [touch locationInView:self];
    NSLog(@"relative: %f",translation.x-self.startX);

}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{

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
