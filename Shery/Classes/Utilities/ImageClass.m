//
//  ImageClass.m
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ImageClass.h"
#import <QuartzCore/QuartzCore.h>
@interface ImageClass ()
@end
@implementation ImageClass
+(UIImage *)imageWithURLString:(NSString *)urlString{
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
}
+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}
+ (UIImage*)screenshot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}
+(UIImage *)generateCroppedImage:(UIImage*)image{
    // Create a thumbnail version of the image for the event object.
    CGFloat ratio;
	CGSize size = image.size;
	CGSize croppedSize;
	CGFloat offsetX = 0.0;
	CGFloat offsetY = 0.0;
    
	// check the size of the image, we want to make it 
	// a square with sides the size of the smallest dimension
	if (size.width > size.height) {
        ratio = size.height;
		offsetX = (size.height - size.width) / 2;
	} else {
        ratio = size.width;
		offsetY = (size.width - size.height) / 2;
	}
    croppedSize = CGSizeMake(ratio, ratio);
    
	// Crop the image before resize
	CGRect clippedRect = CGRectMake(offsetX * -1, offsetY * -1, croppedSize.width, croppedSize.height);
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
	// Done cropping
    
	// Resize the image
	CGRect rect = CGRectMake(0.0, 0.0, ratio, ratio);
    
	UIGraphicsBeginImageContext(rect.size);
	[[UIImage imageWithCGImage:imageRef] drawInRect:rect];
	UIImage *picture = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
    CGImageRelease(imageRef);
	// Done Resizing
    
	return picture;
}

/*+(BOOL)imageForFile:(PFFile *)file andBlock:(ImageBlock)block{
    if(!file){
        block([UIImage imageNamed:@"emptyImage"],nil);
        return YES;
    }
    if(!file.isDataAvailable){
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            block([UIImage imageWithData:data],nil);
        }];
        return NO;
    }
    else{
        block([UIImage imageWithData:[file getData]],nil);
        return YES;
    }
}*/
+ (UIImage *)generatePhotoThumbnail:(UIImage *)image withSize:(CGFloat)ratio {
	// Create a thumbnail version of the image for the event object.
	CGSize size = image.size;
	CGSize croppedSize;
	CGFloat offsetX = 0.0;
	CGFloat offsetY = 0.0;
    
	// check the size of the image, we want to make it 
	// a square with sides the size of the smallest dimension
	if (size.width > size.height) {
		offsetX = (size.height - size.width) / 2;
		croppedSize = CGSizeMake(size.height, size.height);
	} else {
		offsetY = (size.width - size.height) / 2;
		croppedSize = CGSizeMake(size.width, size.width);
	}
    
	// Crop the image before resize
	CGRect clippedRect = CGRectMake(offsetX * -1, offsetY * -1, croppedSize.width, croppedSize.height);
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
	// Done cropping
    
	// Resize the image
	CGRect rect = CGRectMake(0.0, 0.0, ratio, ratio);
    
	UIGraphicsBeginImageContext(rect.size);
	[[UIImage imageWithCGImage:imageRef] drawInRect:rect];
	UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
    CGImageRelease(imageRef);
	// Done Resizing
    
	return thumbnail;
}
@end
