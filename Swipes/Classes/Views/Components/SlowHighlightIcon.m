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
    if(highlighted != self.highlighted){
        [UIView transitionWithView:self
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ [super setHighlighted:highlighted]; }
                    completion:nil];
    }
}
@end
