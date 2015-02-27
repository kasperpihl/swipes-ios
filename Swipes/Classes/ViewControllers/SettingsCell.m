//
//  SettingsCell.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 07/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SettingsCell.h"

#define kDefTextColor tcolor(TextColor)
#define kDefSettingFont KP_REGULAR(14)
#define kDefValueFont KP_REGULAR(12)
#define kRightLabelMargin 26
#define kRightLabelWidth 92

#define kValueLabelSidePadding 10
#define kValueLabelTopPadding 7

#define kSettingRightMargin 5
#define kValBorderWidth 2

@interface SettingsCell ()

@end

@implementation SettingsCell

-(void)setSetting:(NSString *)setting value:(NSString *)value
{
    self.settingLabel.text = setting;
    self.settingLabel.font = self.settingFont;
    self.valueLabel.text = value;
    self.valueLabel.font = self.valueFont;
    //CGSize textSize = sizeWithFont(value, self.valueFont);
    //CGRectSetSize(self.valueLabel,textSize.width+2*kValueLabelSidePadding,textSize.height + 2*kValueLabelTopPadding);
    CGRectSetSize(self.valueLabel, kRightLabelWidth, 12 + 2*kValueLabelTopPadding);
    [self setNeedsLayout];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.leftPadding = kRightLabelMargin;
        self.backgroundColor = CLEAR;
        self.contentView.backgroundColor = CLEAR;
        self.labelColor = kDefTextColor;
        self.settingFont = kDefSettingFont;
        self.valueFont = kDefValueFont;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.settingLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        CGRectSetHeight(self.settingLabel, kCellHeight);
        self.settingLabel.backgroundColor = [UIColor clearColor];
        self.settingLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        //self.settingLabel.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        self.settingLabel.font = self.settingFont;
        self.settingLabel.textColor = self.labelColor;
        [self.contentView addSubview:self.settingLabel];
        
        self.valueLabel = [[UILabel alloc] init];
        self.valueLabel.backgroundColor = tcolorR(BackgroundColor); //[UIColor clearColor];
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        //self.valueLabel.layer.borderWidth = LINE_SIZE;
        self.valueLabel.layer.cornerRadius = kCellHeight / 4;
        self.valueLabel.layer.masksToBounds = YES;
        //self.valueLabel.layer.borderColor = self.labelColor.CGColor;
        self.valueLabel.textColor = tcolorR(TextColor);
        self.valueLabel.font = self.valueFont;
        [self.contentView addSubview:self.valueLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.valueLabel.center = CGPointMake(self.bounds.size.width-kRightLabelMargin-(self.valueLabel.frame.size.width/2), kCellHeight/2);
    CGRectSetX(self.settingLabel, self.leftPadding);
    CGRectSetWidth(self.settingLabel, self.valueLabel.frame.origin.x-self.leftPadding-kSettingRightMargin);
}

@end
