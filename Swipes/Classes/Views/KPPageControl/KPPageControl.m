//
//  KPPageControl.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 07/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPPageControl.h"

@interface KPPageControl (Private)
- (void) updateDots;
@end


@implementation KPPageControl


/** override to update dots */
- (void) setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    
    // update dot views
    [self updateDots];
}

/** override to update dots */
- (void) setNumberOfPages:(NSInteger)number
{
    [super setNumberOfPages:number];
    
    // update dot views
    [self updateDots];
}

/** override to update dots */
- (void) updateCurrentPageDisplay
{
    [super updateCurrentPageDisplay];
    
    // update dot views
    [self updateDots];
}

/** Override setImageNormal */
- (void) setImageNormal:(UIImage*)image
{
    _imageNormal = image;
    
    // update dot views
    [self updateDots];
}

/** Override setImageCurrent */
- (void) setImageCurrent:(UIImage*)image
{
    _imageCurrent = image;
    
    // update dot views
    [self updateDots];
}

/** Override to fix when dots are directly clicked */
- (void) endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    
    [self updateDots];
}

#pragma mark - (Private)

- (void) updateDots
{
    if(self.imageCurrent || self.imageNormal)
    {
        // Get subviews
        NSArray* dotViews = self.subviews;
        for(int i = 0; i < dotViews.count; ++i)
        {
            UIImageView* dot = [dotViews objectAtIndex:i];
            // Set image
            dot.image = (i == self.currentPage) ? self.imageCurrent : self.imageNormal;
        }
    }
}

@end