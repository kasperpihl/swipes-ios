//
//  LoginViewController.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/PFUser.h>
@class LoginViewController;
@protocol LoginViewControllerDelegate
-(void)loginViewController:(LoginViewController*)viewController didLoginUser:(PFUser*)user;
@end
@interface LoginViewController : UIViewController
@property (nonatomic,weak) NSObject<LoginViewControllerDelegate> *delegate;
@end
