//
//  UpgradeViewController.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 09/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UpgradeViewController;
@protocol UpgradeViewControllerDelegate
-(void)closedUpgradeViewController:(UpgradeViewController*)viewController;
@end
@interface UpgradeViewController : UIViewController
@property (nonatomic,weak) NSObject<UpgradeViewControllerDelegate>* delegate;
@end
