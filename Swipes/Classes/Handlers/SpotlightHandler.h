//
//  SpotlightHandler.h
//  Swipes
//
//  Created by demosten on 7/28/15.
//  Copyright © 2015 Pihl IT. All rights reserved.
//

#ifdef __IPHONE_9_0

#import <Foundation/Foundation.h>

#define SPOTLIGHT [SpotlightHandler sharedInstance]

@interface SpotlightHandler : NSObject

+ (instancetype)sharedInstance;

- (void)resetWithCompletionHandler:(void (^ __nullable)(NSError * __nullable error))completionHandler;
- (void)clearAllWithCompletionHandler:(void (^ __nullable)(NSError * __nullable error))completionHandler;
- (void)restoreUserActivity:(NSUserActivity * __nullable)userActivity;

@end

#endif