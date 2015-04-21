//
//  MenuCell.m
//  Swipes
//
//  Created by demosten on 4/20/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "MenuCell.h"

@interface MenuCell ()

@property (nonatomic, weak) IBOutlet UILabel* arrowLabel;

@end

@implementation MenuCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect f = CGRectMake(46, 9, self.contentView.frame.size.width - 82, 22);
    _mainLabel.frame = f;
    
    f = CGRectMake(self.contentView.frame.size.width - 25 , 9, 15, 22);
    _arrowLabel.frame = f;
}

@end
