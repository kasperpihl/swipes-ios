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
#define TEXT_FIELD_TAG 3
#define ANIMATION_DURATION 0.25f

#define TEXT_FIELD_MARGIN_SIDES 10
#define TEXT_FIELD_MARGIN_TOP 8
#define FORM_VIEW_HEIGHT 44
#define KEYBOARD_HEIGHT 216

@interface AddPanelView () <UITextFieldDelegate>
@property (nonatomic,weak) IBOutlet UIView *backgroundView;
@property (nonatomic,weak) IBOutlet UIView *formView;
@property (nonatomic,weak) IBOutlet SLGlowingTextField *textField;
@end
@implementation AddPanelView
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(self.addDelegate && [self.addDelegate respondsToSelector:@selector(didAddItem:)])
        [self.addDelegate didAddItem:textField.text];
    textField.text = @"";
    return NO;
}
-(void)didPressClose:(id)sender{
    [self show:NO];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectSetPos(frame, 0, 0)];
        backgroundView.tag = BACKGROUND_VIEW_TAG;
        backgroundView.backgroundColor = [UtilityClass colorWithRed:125 green:125 blue:125 alpha:0.5];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = backgroundView.frame;
        [closeButton addTarget:self action:@selector(didPressClose:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:closeButton];
        [self addSubview:backgroundView];
        self.backgroundView = [self viewWithTag:BACKGROUND_VIEW_TAG];
        
        
        
        UIView *formView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, FORM_VIEW_HEIGHT)];
        formView.tag = FORM_VIEW_TAG;
        formView.backgroundColor = [UIColor whiteColor];
        SLGlowingTextField *textField = [[SLGlowingTextField alloc] initWithFrame:CGRectMake(TEXT_FIELD_MARGIN_SIDES, TEXT_FIELD_MARGIN_TOP, formView.frame.size.width-(2*TEXT_FIELD_MARGIN_SIDES), formView.frame.size.height-(2*TEXT_FIELD_MARGIN_TOP))];
        textField.tag = TEXT_FIELD_TAG;
        
        textField.borderStyle = UITextBorderStyleNone;
        textField.delegate = self;
        textField.placeholder = @"Add a new item to Today";
        [formView addSubview:textField];
        self.textField = (SLGlowingTextField*)[formView viewWithTag:TEXT_FIELD_TAG];
        [self addSubview:formView];
        self.formView = [self viewWithTag:FORM_VIEW_TAG];
    }
    
    return self;
}
-(void)show:(BOOL)show{
    void (^preblock)(void);
    void (^showBlock)(void);
    void (^completionBlock)(void);
    if(show){
        preblock = ^(void){
            self.backgroundView.alpha = 0;
            self.formView.frame = CGRectSetPos(self.formView.frame, 0, self.frame.size.height-FORM_VIEW_HEIGHT);
            [self.superview bringSubviewToFront:self];
            [self.textField becomeFirstResponder];
            
            
            
        };
        showBlock = ^(void) {
            self.backgroundView.alpha = 1;
            self.formView.frame = CGRectSetPos(self.formView.frame, 0, self.frame.size.height-KEYBOARD_HEIGHT-FORM_VIEW_HEIGHT);
        };
    }
    else{
        preblock = ^(void){
            [self.textField resignFirstResponder];
        };
        showBlock = ^(void) {
            self.formView.frame = CGRectSetPos(self.formView.frame, 0, self.frame.size.height-FORM_VIEW_HEIGHT);
            self.backgroundView.alpha = 0;
        };
        completionBlock = ^(void){
            [self.superview sendSubviewToBack:self];
            [self.addDelegate closedAddPanel:self];
        };
        
    }
    preblock();
    [UIView animateWithDuration:ANIMATION_DURATION animations:showBlock completion:^(BOOL finished) {
        if(finished){
            if(completionBlock) completionBlock();
        }
    }];

}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
}
@end
