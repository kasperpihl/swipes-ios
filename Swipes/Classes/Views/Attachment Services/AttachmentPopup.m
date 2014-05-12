//
//  AttachmentPopup.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 12/05/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "AttachmentPopup.h"

@implementation AttachmentPopup
+(AttachmentPopup *)popupWithFrame:(CGRect)frame block:(AttachmentPopupBlock)block{

}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton addTarget:self action:@selector(cancelled) forControlEvents:UIControlEventTouchUpInside];
        closeButton.frame = self.bounds;
        closeButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
        [self addSubview:closeButton];
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
