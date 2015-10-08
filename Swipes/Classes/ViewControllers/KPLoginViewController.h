//
//  KPLoginViewController.h
//  Swipes
//
//  Created by demosten on 10/6/15.
//  Copyright © 2015 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KPLoginViewController;

@protocol KPLoginViewControllerDelegate <NSObject>

-(void)loginViewController:(KPLoginViewController *)viewController error:(NSError*)error;

@end

@interface KPLoginViewController : UIViewController

@property (nonatomic, weak) id<KPLoginViewControllerDelegate> delegate;

@end

