//
//  AddPanelView.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 20/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "AddPanelView.h"
#define POP_Y 100
#define POP_HEIGHT 100
#define POP_WIDTH 280
#define TEXT_Y 10
@interface AddPanelView () <UITextFieldDelegate>
@end
@implementation AddPanelView
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(self.addDelegate && [self.addDelegate respondsToSelector:@selector(didAddItem:)])
        [self.addDelegate didAddItem:textField.text];
    textField.text = @"";
    return NO;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.margin = UIEdgeInsetsMake(POP_Y, (320-POP_WIDTH)/2, self.frame.size.height-POP_HEIGHT-POP_Y, (320-POP_WIDTH)/2);
        self.padding = UIEdgeInsetsMake(10, 10, 10, 10);
        self.shouldBounce = NO;
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, TEXT_Y, POP_WIDTH-(2*10), 30.0)];
        textField.delegate = self;
        textField.returnKeyType = UIReturnKeyNext;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        self.contentColor = [UIColor whiteColor];
        [self.contentView addSubview:textField];
        [textField becomeFirstResponder];
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
