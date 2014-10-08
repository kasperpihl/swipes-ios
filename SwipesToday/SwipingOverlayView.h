//
//  SwipeTestingView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 07/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SwipingOverlayView;
@protocol SwipingOverlayViewDelegate <NSObject>
-(void)swipingDidStartOverlay:(SwipingOverlayView*)overlay;
-(void)swipingDidCancelOverlay:(SwipingOverlayView*)overlay;
-(void)swipingOverlay:(SwipingOverlayView*)overlay didMoveDistance:(CGPoint)point relative:(CGPoint)relative;
-(void)swipingOverlay:(SwipingOverlayView*)overlay didEndWithDistance:(CGPoint)point relative:(CGPoint)relative;
-(void)didTapSwipingOverlay:(SwipingOverlayView*)overlay;
@end
@interface SwipingOverlayView : UIButton
@property (nonatomic,weak) NSObject<SwipingOverlayViewDelegate> *delegate;
@end
