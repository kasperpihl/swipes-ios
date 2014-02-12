//
//  WalkthroughTitleView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 27/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define WALK_HEADER_FONT KP_SEMIBOLD(20)
#define WALK_SUBHEADER_FONT KP_LIGHT(16)
#define WALK_COLOR  tcolor(BackgroundColor)
#define kDefMaxWidth 260
#define kDefTitleSpacing 13
#import "WalkthroughTitleView.h"
@interface WalkthroughTitleView ()
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *subtitleLabel;
@end
@implementation WalkthroughTitleView
-(void)setTitle:(NSString *)title subtitle:(NSString *)subtitle{
    CGRectSetSize(self.titleLabel, self.maxWidth, 500);
    CGRectSetSize(self.subtitleLabel, self.maxWidth, 500);
    self.titleLabel.text = title;
    self.subtitleLabel.text = subtitle;
    [self.titleLabel sizeToFit];
    [self.subtitleLabel sizeToFit];
    self.titleLabel.frame = CGRectSetPos(self.titleLabel.frame, (self.frame.size.width-self.titleLabel.frame.size.width)/2, 0);
    self.subtitleLabel.frame = CGRectSetPos(self.subtitleLabel.frame, (self.frame.size.width-self.subtitleLabel.frame.size.width)/2, self.titleLabel.frame.size.height + kDefTitleSpacing);
    
    CGRectSetHeight(self, self.subtitleLabel.frame.origin.y + self.subtitleLabel.frame.size.height);
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.maxWidth = kDefMaxWidth;
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = WALK_COLOR;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.backgroundColor = CLEAR;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.font = WALK_HEADER_FONT;
        [self addSubview:self.titleLabel];
        self.subtitleLabel = [[UILabel alloc] init];
        self.subtitleLabel.numberOfLines = 0;
        self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
        self.subtitleLabel.backgroundColor = CLEAR;
        self.subtitleLabel.textColor = WALK_COLOR;
        self.subtitleLabel.font = WALK_SUBHEADER_FONT;
        [self addSubview:self.subtitleLabel];
    }
    return self;
}
-(void)dealloc{
    self.titleLabel = nil;
    self.subtitleLabel = nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
