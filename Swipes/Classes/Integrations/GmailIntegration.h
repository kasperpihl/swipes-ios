//
//  GmailIntegration.h
//  Swipes
//
//  Created by demosten on 1/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GmailIntegration : NSObject

- (void)authenticateEvernoteInViewController:(UIViewController*)viewController withBlock:(ErrorBlock)block;

- (void)logout;

@end
