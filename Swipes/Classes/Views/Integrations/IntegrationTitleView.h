//
//  IntegrationTitleView.h
//  Swipes
//
//  Created by demosten on 2/26/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntegrationTitleView : UIView

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) UIColor* lightColor;

- (void)setupWithTitle:(NSString *)title lightColor:(UIColor *)lightColor;
- (void)setupWithTitle:(NSString *)title;

@end
