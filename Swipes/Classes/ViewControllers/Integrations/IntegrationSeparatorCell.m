//
//  IntegrationSeparatorCell.m
//  Swipes
//
//  Created by demosten on 2/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "IntegrationSeparatorCell.h"

static CGFloat const kHorizontalMargin = 26;
static CGFloat const kVerticalMargin = 15;

@interface IntegrationSeparatorCell ()

@property (nonatomic, strong) UIView* lineView;

@end

@implementation IntegrationSeparatorCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(kHorizontalMargin, kVerticalMargin, self.contentView.frame.size.width - 2 * kHorizontalMargin, 0.5)];
        _lineView.backgroundColor = alpha(tcolor(SubTextColor), 0.5);
        _lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_lineView];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
