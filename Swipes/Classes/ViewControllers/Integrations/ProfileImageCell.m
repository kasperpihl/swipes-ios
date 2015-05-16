//
//  ProfileImageCell.m
//  Swipes
//
//  Created by demosten
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "ProfileImageCell.h"

static CGFloat const kHorizontalMargin = 20;
static CGFloat const kVerticalMargin = 4;
static CGFloat const kPictureSize = 100;

@interface ProfileImageCell ()

@property (nonatomic, strong) UIImageView* shellImageView;
@property (nonatomic, strong) UIImageView* pictureImageView;

@end

@implementation ProfileImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _pictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kPictureSize, kPictureSize)];
        _pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_pictureImageView];

        _shellImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_shellImageView];
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    UIImage* ourShellImage = [UIImage imageNamed:(ThemeDark == THEMER.currentTheme) ? @"profile_form_dark" : @"profile_form_light"];
    
    _shellImageView.image = ourShellImage;
    [_shellImageView sizeToFit];
    
    _pictureImageView.image = _image;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _shellImageView.center = self.contentView.center;
    
    CGRect frame = _pictureImageView.frame;
    frame.origin.x = _shellImageView.frame.origin.x + kHorizontalMargin;
    frame.origin.y = _shellImageView.frame.origin.y + kVerticalMargin;
    _pictureImageView.frame = frame;
}

@end
