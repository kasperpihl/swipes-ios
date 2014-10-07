//
//  SwipeTestingView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 07/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SwipeTestingView;
@protocol SwipingOverlayViewDelegate <NSObject>
-(void)swipingDidStartOverlay:(SwipeTestingView*)overlay;

@end
@interface SwipeTestingView : UIView

@end
