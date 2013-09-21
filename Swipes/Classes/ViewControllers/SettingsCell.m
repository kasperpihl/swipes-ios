//
//  SettingsCell.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 07/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kDefTextColor [UIColor whiteColor]
#define kDefSettingFont KP_REGULAR(19)
#define kDefValueFont KP_SEMIBOLD(14)
#define kRightLabelMargin 20

#define kValueLabelSidePadding 10
#define kValueLabelTopPadding 7

#define kSettingRightMargin 5
#define kValBorderWidth 2
#import "SettingsCell.h"
#import <QuartzCore/QuartzCore.h>
@interface SettingsCell ()
@property (nonatomic) UILabel *settingLabel;
@property (nonatomic) UILabel *valueLabel;
@end
@implementation SettingsCell
-(void)setSetting:(NSString *)setting value:(NSString *)value{
    self.settingLabel.text = setting;
    self.valueLabel.text = value;
    CGSize textSize = [value sizeWithFont:self.valueFont];
    CGRectSetSize(self.valueLabel,textSize.width+2*kValueLabelSidePadding,textSize.height + 2*kValueLabelTopPadding);
    self.valueLabel.center = CGPointMake(self.bounds.size.width-kRightLabelMargin-(self.valueLabel.frame.size.width/2), kCellHeight/2);
    CGRectSetX(self.settingLabel, kRightLabelMargin);
    CGRectSetWidth(self.settingLabel, self.valueLabel.frame.origin.x-kRightLabelMargin-kSettingRightMargin);
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = CLEAR;
        self.contentView.backgroundColor = CLEAR;
        self.labelColor = kDefTextColor;
        self.settingFont = kDefSettingFont;
        self.valueFont = kDefValueFont;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.settingLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        CGRectSetHeight(self.settingLabel, kCellHeight);
        self.settingLabel.backgroundColor = [UIColor clearColor];
        self.settingLabel.lineBreakMode = UILineBreakModeTailTruncation;
        //self.settingLabel.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        self.settingLabel.font = self.settingFont;
        self.settingLabel.textColor = self.labelColor;
        [self.contentView addSubview:self.settingLabel];
        
        self.valueLabel = [[UILabel alloc] init];
        self.valueLabel.backgroundColor = [UIColor clearColor];
        self.valueLabel.textAlignment = UITextAlignmentCenter;
        self.valueLabel.layer.borderWidth = 2;
        self.valueLabel.layer.borderColor = self.labelColor.CGColor;
        self.valueLabel.textColor = self.labelColor;
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

@end
