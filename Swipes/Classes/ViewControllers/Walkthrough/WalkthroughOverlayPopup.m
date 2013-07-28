//
//  WalkthroughOverlayPopup.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 28/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "WalkthroughOverlayPopup.h"
@interface WalkthroughOverlayPopup ()
@property (nonatomic) UIBezierPath *punchedOutPath;
@end
@implementation WalkthroughOverlayPopup

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        self.punchedOutPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(50, 50, 100, 100)];
        self.alpha = 0.8;
    }
    return self;
}

@end
