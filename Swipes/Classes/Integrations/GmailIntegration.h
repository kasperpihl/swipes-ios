//
//  GmailIntegration.h
//  Swipes
//
//  Created by demosten on 1/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kGmInt [GmailIntegration sharedInstance]

@interface GmailIntegration : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, assign) BOOL isAuthenticated;

- (void)authenticateEvernoteInViewController:(UIViewController*)viewController withBlock:(ErrorBlock)block;
- (void)logout;

@end
