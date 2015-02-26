//
//  IntegrationSettingCell.m
//  Swipes
//
//  Created by demosten on 2/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "IntegrationSettingCell.h"

static CGFloat const kIconLeftMargin = 26;
static CGFloat const kIconRightMargin = 26;
static CGFloat const kIconTopMargin = 9;
static CGFloat const kIconSize = 28;
static CGFloat const kStatusSize = 10;

#define kDefTitleFont KP_REGULAR(12)
#define kDefSubtitleFont KP_REGULAR(10)

@interface IntegrationSettingCell ()

@property (nonatomic, assign) IntegrationSettingsStyle style;

@end

@implementation IntegrationSettingCell

- (id)initWithCustomStyle:(IntegrationSettingsStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = tcolor(TextColor);
        _titleLabel.font = kDefTitleFont;
        [self.contentView addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.textColor = tcolor(SubTextColor);
        _subtitleLabel.font = kDefSubtitleFont;
        [self.contentView addSubview:_subtitleLabel];
        
        _iconLabel = [[UILabel alloc] init];
        _iconLabel.backgroundColor = [UIColor clearColor];
        _iconLabel.textColor = tcolor(TextColor);
        _iconLabel.textAlignment = NSTextAlignmentCenter;
        _iconLabel.font = iconFont(kIconSize);
        [self.contentView addSubview:_iconLabel];
        
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.textColor = tcolor(TextColor);
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.font = iconFont(kStatusSize);
        [self.contentView addSubview:_statusLabel];
        
        self.customStyle = style;
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setCustomStyle:(IntegrationSettingsStyle)customStyle
{
    _style = customStyle;
    _subtitleLabel.hidden = !(_style & IntegrationSettingsStyleSubtitle);
    _iconLabel.hidden = !(_style & IntegrationSettingsStyleIcon);
    _statusLabel.hidden = !(_style & IntegrationSettingsStyleState);
}

- (IntegrationSettingsStyle)customStyle
{
    return _style;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat leftMargin = kIconLeftMargin;
    CGFloat topMargin = kIconTopMargin;
    CGFloat labelSize = self.contentView.frame.size.width - kIconLeftMargin - kIconRightMargin;
    CGFloat iconHeight = self.contentView.frame.size.height - kIconTopMargin * 2;
    
    if (_style & IntegrationSettingsStyleIcon) {
        _iconLabel.frame = CGRectMake(kIconLeftMargin, kIconTopMargin, kIconSize, iconHeight);
        leftMargin += kIconSize + kIconRightMargin;
        labelSize -= kIconSize + kIconRightMargin;
    }
    
    if (_style & IntegrationSettingsStyleState) {
        _statusLabel.frame = CGRectMake(self.contentView.frame.size.width - kIconRightMargin - kStatusSize, kIconTopMargin, kStatusSize, iconHeight);
        labelSize -= kStatusSize + 3; // 3 to not be just inside the state
    }
    
    if (_style & IntegrationSettingsStyleSubtitle) {
        iconHeight /= 2;
        _subtitleLabel.frame = CGRectMake(leftMargin, topMargin + iconHeight, labelSize, iconHeight);
        
    }

    _titleLabel.frame = CGRectMake(leftMargin, topMargin, labelSize, iconHeight);
    
}

@end
