//
//  URLHandler.h
//  Swipes
//
//  Created by demosten on 7/28/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLHandler : NSObject

+ (instancetype)sharedInstance;
- (BOOL)handleURL:(NSURL *)url;

@end
