//
//  UIImage+Blur.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/11/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Blur)
-(UIImage *)rn_boxblurImageWithBlur:(CGFloat)blur exclusionPath:(UIBezierPath *)exclusionPath;
@end
