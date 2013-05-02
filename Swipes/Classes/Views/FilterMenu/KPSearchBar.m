//
//  KPSearchBar.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 02/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPSearchBar.h"

@implementation KPSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)layoutSubviews {
    UITextField *searchField;
    NSUInteger numViews = [self.subviews count];
    for(int i = 0; i < numViews; i++) {
        if([[self.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) { //conform?
            searchField = [self.subviews objectAtIndex:i];
        }
    }
    if(!(searchField == nil)) {
        //searchField.textColor = [UIColor whiteColor];
        //[searchField setBackground: [UIImage imageNamed:@"buscador.png"] ];
        //[searchField setBorderStyle:UITextBorderStyleNone];
    }
    
    [super layoutSubviews];
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
