//
//  SignupViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.


#import "SignupViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UtilityClass.h"
#import "UIColor+Utilities.h"
@interface SignupViewController ()
@end

@implementation SignupViewController
-(id)init{
    self = [super init];
    if(self){
        self.fields = (PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsDismissButton | PFSignUpFieldsSignUpButton);
        self.signUpView.usernameField.font = LOGIN_FIELDS_FONT;
        self.signUpView.passwordField.font = LOGIN_FIELDS_FONT;
        self.signUpView.usernameField.placeholder = @"email";
        self.signUpView.usernameField.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.signUpView.passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.signUpView.passwordField.placeholder = @"password";
        self.signUpView.usernameField.textColor = LOGIN_FIELDS_TEXT_COLOR;
        self.signUpView.passwordField.textColor = LOGIN_FIELDS_TEXT_COLOR;
        self.signUpView.usernameField.returnKeyType = UIReturnKeyNext;
        CALayer *layer = self.signUpView.usernameField.layer;
        layer.shadowOpacity = 0.0;
        layer = self.signUpView.passwordField.layer;
        layer.shadowOpacity = 0.0;
        [self setupButton:self.signUpView.signUpButton];
        [self.signUpView.signUpButton setBackgroundImage:[tcolor(DoneColor) image] forState:UIControlStateNormal];
        [self.signUpView.signUpButton setBackgroundImage:[[tcolor(DoneColor) darker] image] forState:UIControlStateHighlighted];
        [self.signUpView.signUpButton setTitle:@"SIGN UP" forState:UIControlStateNormal];
    }
    return self;
}
-(void)setupButton:(UIButton*)button{
    [button setBackgroundImage:nil forState:UIControlStateHighlighted];
    [button.titleLabel setFont:SIGNUP_BUTTON_FONT];
    [button setImage:[UIImage new] forState:UIControlStateNormal];
    [button setImage:nil forState:UIControlStateHighlighted];
    [button.titleLabel setShadowOffset:CGSizeZero];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

@end
