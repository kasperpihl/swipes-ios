//
//  LocationResultCell.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 13/02/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#define kTextX  30
#define kTextRightPadding 10

#define kIconHack 2

#import "LocationResultCell.h"
@interface LocationResultCell ()
@property (nonatomic) UILabel *resultLabel;
@end
@implementation LocationResultCell
-(void)setResultText:(NSString *)resultText{
    self.resultLabel.text = resultText;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = CLEAR;
        self.contentView.backgroundColor = CLEAR;
        self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextX, 0, self.bounds.size.width-kTextX-kTextRightPadding, self.bounds.size.height)];
        self.resultLabel.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
        self.resultLabel.textColor = tcolorF(TextColor,ThemeDark);
        self.resultLabel.backgroundColor = CLEAR;
        self.resultLabel.font = KP_REGULAR(15);
        [self.contentView addSubview:self.resultLabel];
        
        UIImageView *locationIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:timageStringBW(@"edit_location_icon")]];
        locationIcon.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
        CGRectSetCenterY(locationIcon, self.bounds.size.height/2);
        CGRectSetCenterX(locationIcon, kTextX/2+kIconHack);
        [self.contentView addSubview:locationIcon];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)dealloc{
    self.resultLabel = nil;
}
@end
