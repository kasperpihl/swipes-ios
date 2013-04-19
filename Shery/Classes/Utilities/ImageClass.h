//
//  ImageClass.h
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ImageClass : NSObject
+ (UIImage*)screenshot;
+(UIImage *)imageWithURLString:(NSString *)urlString;
+(UIImage *)generateCroppedImage:(UIImage*)image;
+ (UIImage *) imageWithView:(UIView *)view;
+ (UIImage *)generatePhotoThumbnail:(UIImage *)image withSize:(CGFloat)ratio;
//-(BOOL)imageForFile:(PFFile *)file andBlock:(ImageBlock)block;
@end
