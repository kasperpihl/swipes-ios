//
//  UIGestureRecognizer+UIBreak.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/11/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "UIGestureRecognizer+UIBreak.h"

@implementation UIGestureRecognizer (UIBreak)
- (BOOL) isGestureRecognizerInSiblings:(UIGestureRecognizer *)recognizer{
    UIView *superview = self.view.superview;
    NSUInteger index = [superview.subviews indexOfObject:self.view];
    if (index != NSNotFound){
        for (int i = 0; i < index; i++){
            UIView *sibling = superview.subviews[i];
            for (UIGestureRecognizer *viewRecognizer in sibling.gestureRecognizers){
                if (recognizer == viewRecognizer){
                    return YES;
                }
            }
        }
    }
    return NO;
}
- (BOOL) isGestureRecognizerInSuperviewHierarchy:(UIGestureRecognizer *)recognizer{
    if (!recognizer) return NO;
    if (!self.view) return NO;
    //Check siblings
    UIView *superview = self.view;
    while (YES) {
        superview = superview.superview;
        if (!superview) return NO;
        for (UIGestureRecognizer *viewRecognizer in superview.gestureRecognizers){
            if (recognizer == viewRecognizer){
                return YES;
            }
        }
    }
}
@end
