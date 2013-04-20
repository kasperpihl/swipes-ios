//
//  AddPanelView.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 20/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "AddPanelView.h"

@implementation AddPanelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280, 60)];
        [backgroundView addSubview:textField];
        self.contentColor = [UIColor whiteColor];
        self.contentView.frame = backgroundView.frame;
        [self.contentView addSubview:backgroundView];
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
