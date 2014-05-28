//
//  SyncLabel.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 27/05/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#import "SyncLabel.h"
#import <QuartzCore/QuartzCore.h>
#define kLeftSpacingIcon 5
#define kTopSpacing (OSVER >= 7 ? -2 : 2)
#define kIconSize 10
#define kCornerRadius 3

@interface SyncLabel ()
@property (nonatomic) UILabel *syncIcon;
@end


@implementation SyncLabel
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializer];
    }
    return self;
}
- ( void )initializer{
    
    self.titleLabel.font = KP_SEMIBOLD(kIconSize);
    self.layer.cornerRadius = kCornerRadius;
    self.syncIcon = iconLabel(@"editSyncIcon", kIconSize);
    self.titleLabel.textColor = tcolor(BackgroundColor);
    self.backgroundColor = tcolor(TextColor);
    self.syncIcon.textColor = tcolor(BackgroundColor);
    self.titleEdgeInsets = UIEdgeInsetsMake(kTopSpacing, kIconSize + 2*kLeftSpacingIcon, kTopSpacing, kLeftSpacingIcon);
    [self addSubview:self.syncIcon];
}
- ( void )setTitle:(NSString*)title{
    _title = title;
    [self setTitle:title forState:UIControlStateNormal];
    [self sizeToFit];
    CGSize s = self.frame.size;
    CGRectSetSize(self, s.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right,
                      s.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom);
    CGRectSetCenter(self.syncIcon, kLeftSpacingIcon + self.syncIcon.frame.size.width/2, self.frame.size.height/2);
    //self.syncIcon.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
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
