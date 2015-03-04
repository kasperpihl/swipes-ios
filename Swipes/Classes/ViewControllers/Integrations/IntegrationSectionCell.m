//
//  IntegrationSectionCell.m
//  Swipes
//
//  Created by demosten on 2/26/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "IntegrationSectionCell.h"

static CGFloat const kHorizontalMargin = 26;
static CGFloat const kVerticalTitleMargin = 16;
static CGFloat const kVerticalLineMargin = 33;

#define kDefTitleFont KP_SEMIBOLD(10)

@interface IntegrationSectionCell ()

@property (nonatomic, strong) UIView* lineView;
@property (nonatomic, strong) UILabel* titleLabel;

@end

@implementation IntegrationSectionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kHorizontalMargin, kVerticalTitleMargin, self.contentView.frame.size.width - 2 * kHorizontalMargin, 15)];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = tcolor(TextColor);
        _titleLabel.font = kDefTitleFont;
        [self.contentView addSubview:_titleLabel];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(kHorizontalMargin, kVerticalLineMargin, self.contentView.frame.size.width - 2 * kHorizontalMargin, 0.5)];
        _lineView.backgroundColor = gray(158, 1);
        _lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_lineView];
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (_title)
            [self setupTitle];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    if (_titleLabel) {
        [self setupTitle];
    }
}

- (void)setupTitle
{
    NSMutableAttributedString *myString = [[NSMutableAttributedString alloc]initWithString:[_title uppercaseString]];
    [myString addAttribute:NSKernAttributeName value:@(1.5) range:NSMakeRange(0, myString.length)];
    self.titleLabel.attributedText = [[NSAttributedString alloc]initWithAttributedString: myString];
}

@end
