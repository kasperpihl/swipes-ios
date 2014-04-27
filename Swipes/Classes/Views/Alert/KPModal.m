//
//  KPModal.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 22/04/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "KPModal.h"

@implementation KPModal

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 240)];
        //self.frame = contentView.bounds;
        contentView.center = self.center;
        contentView.layer.cornerRadius = 10;
        contentView.layer.masksToBounds = YES;
        self.contentView = contentView;
        [self addSubview:self.contentView];
    }
    return self;

}
-(void)setContentSize:(CGSize)contentSize{
    CGRectSetSize(self.contentView,contentSize.width,contentSize.height);
    self.contentView.center = self.center;
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
