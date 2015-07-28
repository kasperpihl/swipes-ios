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

+ (instancetype)sharedInstance;

- (void)reset;
- (void)clearAll;

@end
