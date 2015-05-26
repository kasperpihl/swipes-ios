//
//  KPImageCache.m
//  Swipes
//
//  Created by demosten on 5/25/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "KPImageCache.h"

static NSString *_JMImageCacheDirectory;

static inline NSString *JMImageCacheDirectory() {
    if(!_JMImageCacheDirectory) {
        _JMImageCacheDirectory = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/JMCache"] copy];
    }
    
    return _JMImageCacheDirectory;
}
inline static NSString *keyForURL(NSURL *url) {
    return [url absoluteString];
}
static inline NSString *cachePathForKey(NSString *key) {
    NSString *fileName = [NSString stringWithFormat:@"JMImageCache-%u", [key hash]];
    return [JMImageCacheDirectory() stringByAppendingPathComponent:fileName];
}

@interface JMImageCache ()

@end

static KPImageCache *_sharedCache = nil;

@implementation KPImageCache

+ (instancetype) sharedCache {
    if(!_sharedCache) {
        _sharedCache = [[KPImageCache alloc] init];
    }
    
    return _sharedCache;
}

- (void) setImage:(UIImage *)i forURL:(NSURL *)url
{
    [super setImage:i forURL:url];
    NSData* data = UIImageJPEGRepresentation(i, 1.0f);
    
    NSString *cachePath = cachePathForKey(keyForURL(url));
    NSInvocation *writeInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(writeData:toPath:)]];
    
    [writeInvocation setTarget:self];
    [writeInvocation setSelector:@selector(writeData:toPath:)];
    [writeInvocation setArgument:&data atIndex:2];
    [writeInvocation setArgument:&cachePath atIndex:3];
    
    [self performDiskWriteOperation:writeInvocation];
}

@end
