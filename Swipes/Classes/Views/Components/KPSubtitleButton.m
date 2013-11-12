//
//  KPSubtitleLabel.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 09/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPSubtitleButton.h"
@interface KPSubtitleButton ()
@end
@implementation KPSubtitleButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.subtitleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        CGRectSetHeight(self.subtitleLabel, self.bounds.size.height);
        self.subtitleLabel.backgroundColor = CLEAR;
        self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
        self.subtitleLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.subtitleLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
