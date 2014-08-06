//
//  WalkthroughViewController.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kActionButtonFont KP_REGULAR(20)

@class WalkthroughViewController;
@protocol WalkthroughDelegate <NSObject>
-(void)walkthrough:(WalkthroughViewController*)walkthrough didFinishSuccesfully:(BOOL)successfully;
@end
@interface WalkthroughViewController : UIViewController
@property (nonatomic,weak) id<WalkthroughDelegate> delegate;
@end
