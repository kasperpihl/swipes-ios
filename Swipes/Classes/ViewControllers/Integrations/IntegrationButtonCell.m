//
//  IntegrationButtonCell.m
//  Swipes
//
//  Created by demosten
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "IntegrationButtonCell.h"

static CGFloat const kHorizontalMargin = 26;
static CGFloat const kVerticalTitleMargin = 16;
static CGFloat const kVerticalLineMargin = 2;

#define kDefTitleFont KP_SEMIBOLD(12)

@interface IntegrationButtonCell ()

@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UIView* lineView;

@end

@implementation IntegrationButtonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = gray(158, 1);
        [self.contentView addSubview:_lineView];

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kHorizontalMargin, kVerticalTitleMargin, self.contentView.frame.size.width - 2 * kHorizontalMargin, self.contentView.frame.size.height)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = gray(158, 1);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = kDefTitleFont;
        [self.contentView addSubview:_titleLabel];
        
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
    NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] initWithString:[_title uppercaseString]];

    NSRange allRange = NSMakeRange(0, myString.length);
    [myString addAttribute:NSKernAttributeName value:@(1.5) range:allRange];
    self.titleLabel.attributedText = [[NSAttributedString alloc]initWithAttributedString: myString];
    [self.titleLabel sizeToFit];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.center = self.contentView.center;
    
    CGRect frame = self.titleLabel.frame;
    frame.origin.y += frame.size.height + kVerticalLineMargin;
    frame.size.height = 0.5;
    self.lineView.frame = frame;
}

@end
