//
//  SpotlightHandler.h
//  Swipes
//
//  Created by demosten on 7/28/15.
//  Copyright © 2015 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SPOTLIGHT [SpotlightHandler sharedInstance]

@interface SpotlightHandler : NSObject

+ (instancetype _Null_unspecified)sharedInstance;

- (void)resetWithCompletionHandler:(void (^ __nullable)(NSError * __nullable error))completionHandler;
- (void)clearAllWithCompletionHandler:(void (^ __nullable)(NSError * __nullable error))completionHandler;
- (void)restoreUserActivity:(NSUserActivity * __nullable)userActivity;

@end
