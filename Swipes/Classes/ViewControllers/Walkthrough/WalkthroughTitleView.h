//
//  WalkthroughTitleView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 27/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WalkthroughTitleView : UIView
@property (nonatomic) CGFloat maxWidth;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *subtitleLabel;
-(void)setTitle:(NSString*)title subtitle:(NSString*)subtitle;
@end
