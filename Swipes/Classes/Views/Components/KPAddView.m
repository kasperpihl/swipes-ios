//
//  KPAddView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 24/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kDEFAULT_SPACING 15

#import "KPAddView.h"
@interface KPAddView () <UITextFieldDelegate>
@property (nonatomic) IBOutlet UIButton *doneEditingButton;
@property (nonatomic) BOOL isRotated;
@end
@implementation KPAddView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = CLEAR;
        self.doneEditingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        CGFloat buttonSize = self.frame.size.height;
        CGFloat buttonWidth = 44;
        self.doneEditingButton.frame = CGRectMake(self.frame.size.width - buttonWidth, 0, buttonWidth, buttonSize);
        self.doneEditingButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self.doneEditingButton setImage:[UIImage imageNamed:timageStringBW(@"backarrow_icon")] forState:UIControlStateNormal];
        [self.doneEditingButton addTarget:self action:@selector(pressedDoneEditing:) forControlEvents:UIControlEventTouchUpInside];
        
        self.doneEditingButton.imageView.clipsToBounds = NO;
        self.doneEditingButton.imageView.contentMode = UIViewContentModeCenter;
        self.doneEditingButton.imageView.transform = CGAffineTransformMakeRotation(3*M_PI/2);
        [self addSubview:self.doneEditingButton];
        
        /*UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-buttonWidth-SEPERATOR_WIDTH, kDEFAULT_SPACING, SEPERATOR_WIDTH, self.frame.size.height-(2*kDEFAULT_SPACING))];
        seperator.backgroundColor = tcolor(SeperatorColor);
        [self addSubview:seperator];
        */
        
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - buttonWidth, self.frame.size.height)];
        self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.textField.font = KP_REGULAR(18);
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textField.textColor = tcolor(TextColor);
        self.textField.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.textField.returnKeyType = UIReturnKeyNext;
        self.textField.borderStyle = UITextBorderStyleNone;
        self.textField.delegate = self;
        self.textField.placeholder = @"Add a new task";
        self.textField.userInteractionEnabled = YES;
        @try {
            [self.textField setValue:tcolor(TextColor) forKeyPath:@"_placeholderLabel.textColor"];
        }
        @catch (NSException *exception) {
            NSLog(@"excepton:%@",exception);
        }
        [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:self.textField];
    }
    return self;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *string = textField.text;
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(trimmedString.length > 0){
        self.textField.text = @"";
        [self textFieldDidChange:self.textField];
        if([self.delegate respondsToSelector:@selector(addView:enteredTrimmedText:)]) [self.delegate addView:self enteredTrimmedText:trimmedString];
    }
    return NO;
}
-(void)textFieldDidChange:(UITextField*)textField{
    NSString *string = textField.text;
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(trimmedString.length > 0){
        if(!self.isRotated){
            [self rotateButton];
            self.isRotated = YES;
        }
    }
    else{
        if(self.isRotated){
            [self rotateButton];
            self.isRotated = NO;
        }
    }
}
-(void)pressedDoneEditing:(id)sender{
    [self textFieldShouldReturn:self.textField];
    if([self.delegate respondsToSelector:@selector(addViewPressedDoneButton:)]) [self.delegate addViewPressedDoneButton:self];
}
-(IBAction)rotateButton
{
    [UIView beginAnimations:@"rotate" context:nil];
    [UIView setAnimationDuration:.25f];
    if( CGAffineTransformEqualToTransform( self.doneEditingButton.imageView.transform, CGAffineTransformMakeRotation(M_PI) ) )
    {
        self.doneEditingButton.imageView.transform = CGAffineTransformMakeRotation(3*M_PI/2);
    } else {
        self.doneEditingButton.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    }
    [UIView commitAnimations];
}
-(void)dealloc{
    self.doneEditingButton = nil;
    self.textField = nil;
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
