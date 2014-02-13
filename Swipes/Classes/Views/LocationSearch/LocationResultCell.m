//
//  LocationResultCell.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 13/02/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "LocationResultCell.h"

@implementation LocationResultCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = CLEAR;
        self.contentView.backgroundColor = CLEAR;
        self.textLabel.textColor = tcolor(TextColor);
        self.textLabel.font = KP_REGULAR(15);
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
