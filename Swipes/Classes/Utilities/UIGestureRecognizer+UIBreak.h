//
//  UIGestureRecognizer+UIBreak.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/11/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIGestureRecognizer (UIBreak)
- (BOOL) isGestureRecognizerInSiblings:(UIGestureRecognizer *)recognizer;
- (BOOL) isGestureRecognizerInSuperviewHierarchy:(UIGestureRecognizer *)recognizer;
@end
