//
//  AddPanelView.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 20/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "AddPanelView.h"

#import "UtilityClass.h"
#import "DAKeyboardControl.h"
#define FORM_VIEW_TAG 1
#define BACKGROUND_VIEW_TAG 2
#define PICKER_VIEW_TAG 3
#define TEXT_FIELD_TAG 4
#define DONE_EDITING_BUTTON_TAG 5
#define ANIMATION_DURATION 0.25f

#define TEXT_FIELD_COLOR [UIColor whiteColor]

#define KEYBOARD_HEIGHT 216

@interface AddPanelView () <UITextFieldDelegate>
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *string = textField.text;
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(trimmedString.length > 0){
        [self textFieldDidChange:self.textField];
        if(self.addDelegate && [self.addDelegate respondsToSelector:@selector(didAddItem:)])
        [self.addDelegate didAddItem:textField.text];
        textField.text = @"";
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
-(void)didPressClose:(id)sender{
    [self show:NO];
}
-(void)setForwardDatasource:(NSObject<KPPickerViewDataSource> *)forwardDatasource{
    _forwardDatasource = forwardDatasource;
    [self.pickerView setDataSource:forwardDatasource];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UIView *formView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, TEXT_FIELD_CONTAINER_HEIGHT)];
        formView.tag = FORM_VIEW_TAG;
        formView.userInteractionEnabled = YES;
        formView.backgroundColor = TEXTFIELD_BACKGROUND;
        UIView *textFieldColorSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, formView.frame.size.height-COLOR_SEPERATOR_HEIGHT, formView.frame.size.width, COLOR_SEPERATOR_HEIGHT)];
        textFieldColorSeperator.backgroundColor = SWIPES_BLUE;
        [formView addSubview:textFieldColorSeperator];
        
        UIButton *doneEditingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneEditingButton.tag = DONE_EDITING_BUTTON_TAG;
        CGFloat buttonSize = formView.frame.size.height-COLOR_SEPERATOR_HEIGHT;
        doneEditingButton.frame = CGRectMake(formView.frame.size.width-buttonSize, 0, buttonSize, buttonSize);
        [doneEditingButton setBackgroundImage:[UtilityClass imageWithColor:SWIPES_BLUE] forState:UIControlStateNormal];
        [doneEditingButton setImage:[UIImage imageNamed:@"hide_keyboard_arrow"] forState:UIControlStateNormal];
        [doneEditingButton addTarget:self action:@selector(pressedDoneEditing:) forControlEvents:UIControlEventTouchUpInside];
        
        doneEditingButton.imageView.clipsToBounds = NO;
        doneEditingButton.imageView.contentMode = UIViewContentModeCenter;
        [formView addSubview:doneEditingButton];
        self.doneEditingButton = (UIButton*)[formView viewWithTag:DONE_EDITING_BUTTON_TAG];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(TEXT_FIELD_MARGIN_LEFT, TEXT_FIELD_MARGIN_TOP, formView.frame.size.width-TEXT_FIELD_MARGIN_LEFT-buttonSize, TEXT_FIELD_HEIGHT)];
        textField.tag = TEXT_FIELD_TAG;
        textField.font = TEXT_FIELD_FONT;
        textField.textColor = TEXT_FIELD_COLOR;
        textField.keyboardAppearance = UIKeyboardAppearanceAlert;
        textField.returnKeyType = UIReturnKeyNext;
        textField.borderStyle = UITextBorderStyleNone;
        textField.delegate = self;
        textField.userInteractionEnabled = YES;
        textField.placeholder = @"Add a new task";
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [formView addSubview:textField];
        self.textField = (UITextField*)[formView viewWithTag:TEXT_FIELD_TAG];
        [self addSubview:formView];
        
        
        
        
        self.formView = (UIImageView*)[self viewWithTag:FORM_VIEW_TAG];
        CGRectSetSize(self.frame, self.frame.size.width, KEYBOARD_HEIGHT+self.formView.frame.size.height);
    }
    return self;
}
-(void)pressedDoneEditing:(id)sender{
    [self textFieldShouldReturn:self.textField];
    [self.addDelegate closeAddPanel:self];
}
-(void)show:(BOOL)show{
    if(show){
        [self.textField becomeFirstResponder];
    }
    else [self.textField resignFirstResponder];
    

}
@end
