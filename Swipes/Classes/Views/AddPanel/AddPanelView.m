//
//  AddPanelView.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 20/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "AddPanelView.h"
#import "KPBlurry.h"
#import "UtilityClass.h"
#define FORM_VIEW_TAG 1
#define BACKGROUND_VIEW_TAG 2
#define PICKER_VIEW_TAG 3
#define TEXT_FIELD_TAG 4
#define DONE_EDITING_BUTTON_TAG 5
#define ANIMATION_DURATION 0.25f

#define SEPERATOR_SPACING 15

#define ADD_VIEW_HEIGHT 70
#define ADD_FIELD_HEIGHT 30


@interface AddPanelView () <UITextFieldDelegate,KPBlurryDelegate>
@property (nonatomic,weak) IBOutlet UIView *backgroundView;
@property (nonatomic,weak) IBOutlet KPPickerView *pickerView;
@property (nonatomic,weak) IBOutlet UIImageView *formView;
@property (nonatomic,weak) IBOutlet UIButton *doneEditingButton;
@property (nonatomic,weak) IBOutlet UITextField *textField;
@property (nonatomic) BOOL shouldRemove;
@property (nonatomic) BOOL isRotated;
@end
@implementation AddPanelView
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
-(void)blurryWillShow:(KPBlurry *)blurry{
    [self.textField becomeFirstResponder];
    [UIView animateWithDuration:0.25f animations:^{
        CGRectSetY(self.formView, self.frame.size.height-self.formView.frame.size.height-KEYBOARD_HEIGHT);
    }];
}
-(void)blurryWillHide:(KPBlurry *)blurry{
    [self.textField resignFirstResponder];
    [UIView animateWithDuration:0.25f animations:^{
        CGRectSetY(self.formView, self.frame.size.height-self.formView.frame.size.height);
    }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *string = textField.text;
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(trimmedString.length > 0){
        if(self.addDelegate && [self.addDelegate respondsToSelector:@selector(didAddItem:)])
        [self.addDelegate didAddItem:textField.text];
        textField.text = @"";
        [self textFieldDidChange:self.textField];
    }
    return NO;
}
-(IBAction)rotateButton
{
    NSLog( @"Rotating button" );
    
    [UIView beginAnimations:@"rotate" context:nil];
    [UIView setAnimationDuration:.25f];
    if( CGAffineTransformEqualToTransform( self.doneEditingButton.imageView.transform, CGAffineTransformIdentity ) )
    {
        self.doneEditingButton.imageView.transform = CGAffineTransformMakeRotation(3*M_PI/2);
    } else {
        self.doneEditingButton.imageView.transform = CGAffineTransformIdentity;
    }
    [UIView commitAnimations];
}
-(BOOL)blurryShouldClose:(KPBlurry *)blurry{
    [self.addDelegate closeAddPanel:self];
    return NO;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *formView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, ADD_VIEW_HEIGHT)];
        formView.tag = FORM_VIEW_TAG;
        formView.userInteractionEnabled = YES;
        formView.backgroundColor = tbackground(MenuBackground);
        
        
        
        UIButton *doneEditingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneEditingButton.tag = DONE_EDITING_BUTTON_TAG;
        
        CGFloat buttonSize = formView.frame.size.height;
        CGFloat buttonWidth = buttonSize;
        doneEditingButton.frame = CGRectMake(formView.frame.size.width-buttonWidth, 0, buttonWidth, buttonSize);
        [doneEditingButton setImage:[UIImage imageNamed:@"hide_keyboard_arrow"] forState:UIControlStateNormal];
        [doneEditingButton addTarget:self action:@selector(pressedDoneEditing:) forControlEvents:UIControlEventTouchUpInside];
        
        doneEditingButton.imageView.clipsToBounds = NO;
        doneEditingButton.imageView.contentMode = UIViewContentModeCenter;
        [formView addSubview:doneEditingButton];
        self.doneEditingButton = (UIButton*)[formView viewWithTag:DONE_EDITING_BUTTON_TAG];
        
        UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(formView.frame.size.width-buttonWidth-SEPERATOR_WIDTH, SEPERATOR_SPACING, SEPERATOR_WIDTH, formView.frame.size.height-(2*SEPERATOR_SPACING))];
        seperator.backgroundColor = tcolor(SearchDrawerColor);
        [formView addSubview:seperator];
        
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(TEXT_FIELD_MARGIN_LEFT, 25, formView.frame.size.width-TEXT_FIELD_MARGIN_LEFT-buttonWidth, ADD_FIELD_HEIGHT)];
        textField.tag = TEXT_FIELD_TAG;
        textField.font = TEXT_FIELD_FONT;
        
        textField.textColor = tcolor(TextFieldColor);
        textField.keyboardAppearance = UIKeyboardAppearanceAlert;
        textField.returnKeyType = UIReturnKeyNext;
        textField.borderStyle = UITextBorderStyleNone;
        textField.delegate = self;
        textField.userInteractionEnabled = YES;
        textField.placeholder = @"Add a new task";
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [formView addSubview:textField];
        self.textField = (UITextField*)[formView viewWithTag:TEXT_FIELD_TAG];
        //[self.textField setValue:TEXT_FIELD_COLOR forKeyPath:@"_placeholderLabel.textColor"];
        [self addSubview:formView];
        
        
        self.formView = (UIImageView*)[self viewWithTag:FORM_VIEW_TAG];
        CGRectSetHeight(self, KEYBOARD_HEIGHT+self.formView.frame.size.height);
        CGRectSetY(self.formView, self.frame.size.height-self.formView.frame.size.height);
    }
    return self;
}
-(void)pressedDoneEditing:(id)sender{
    [self textFieldShouldReturn:self.textField];
    [self.addDelegate closeAddPanel:self];
}
@end
