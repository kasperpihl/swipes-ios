//
//  EvernoteIntegration.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kEnInt [EvernoteIntegration sharedInstance]
@interface EvernoteIntegration : NSObject
@property (nonatomic) BOOL isAuthenticated;
+(EvernoteIntegration*)sharedInstance;
-(void)authenticateEvernoteInViewController:(UIViewController*)viewController withBlock:(ErrorBlock)block;
@end
