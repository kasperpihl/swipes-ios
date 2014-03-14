//
//  UIView+Utilities.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 13/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (Utilities)
-(UIImage*)screenshot;
- (void)showIndicator:(BOOL)show;
- (void)makeInsetShadow;
- (void)makeInsetShadowWithRadius:(float)radius Alpha:(float)alpha;
- (void)makeInsetShadowWithRadius:(float)radius Color:(UIColor *)color Directions:(NSArray *)directions;
- (void)explainSubviews;
@end