//
//  MenuButton.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 06/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuButton : UIButton
-(id)initWithFrame:(CGRect)frame title:(NSString*)title image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage;
@property (nonatomic) UIColor *lampColor;
@property (nonatomic) UIImageView *iconImageView;
@end
