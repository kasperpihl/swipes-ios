//
//  IntegrationSettingCell.h
//  Swipes
//
//  Created by demosten on 2/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, IntegrationSettingsStyle) {
    IntegrationSettingsStyleDefaultMask     = 0,
    IntegrationSettingsStyleSubtitle        = 1 << 0,
    IntegrationSettingsStyleIcon            = 1 << 1,
    IntegrationSettingsStyleState           = 1 << 2,
};


@interface IntegrationSettingCell : UITableViewCell

- (id)initWithCustomStyle:(IntegrationSettingsStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* subtitleLabel;
@property (nonatomic, strong) UILabel* iconLabel;
@property (nonatomic, strong) UILabel* statusLabel;
@property (nonatomic, assign) IntegrationSettingsStyle customStyle;

@end
