//
//  KPImageCache.h
//  Swipes
//
//  Created by demosten on 5/25/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "JMImageCache.h"

@interface KPImageCache : JMImageCache

+ (instancetype) sharedCache;
- (void) setImage:(UIImage *)i forURL:(NSURL *)url;
- (NSString *)imagePathForURL:(NSURL *)url;

@end
