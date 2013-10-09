//
//  SlowHighlightIcon.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 08/10/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "SlowHighlightIcon.h"

@implementation SlowHighlightIcon
-(void)setHighlighted:(BOOL)highlighted{
    [UIView transitionWithView:self.imageView
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ [self.imageView setHighlighted:highlighted]; }
                    completion:nil];
}
@end
