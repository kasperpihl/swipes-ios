//
//  SignupViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define FIELDS_WIDTH 224
#define LOGIN_FIELDS_CORNER_RADIUS 5
#define LOGIN_FIELDS_WIDTH FIELDS_WIDTH
#define LOGIN_FIELDS_HEIGHT 90
#define LOGIN_FIELDS_SEPERATOR_WIDTH 194



#define SIGNUP_BUTTON_Y     (20      +LOGIN_FIELDS_Y+LOGIN_FIELDS_HEIGHT)
#import "SignupViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UtilityClass.h"
@interface SignupViewController ()
@property (nonatomic,strong) IBOutlet UIView *fieldsBackground;
@end

@implementation SignupViewController
-(id)init{
    self = [super init];
    if(self){
        self.fields = (PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsDismissButton | PFSignUpFieldsSignUpButton);
        self.signUpView.usernameField.placeholder = @"Email";

        
        [self.signUpView setBackgroundColor:CLEAR];
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_background"]];
        backgroundImageView.contentMode = UIViewContentModeScaleToFill;
        backgroundImageView.autoresizesSubviews = (UIViewAutoresizingFlexibleHeight);
        CGRectSetHeight(backgroundImageView, self.signUpView.frame.size.height);
        [self.signUpView insertSubview:backgroundImageView atIndex:0];
    
        [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logo.png"]]];
        
        
        
        // Add login field background
        self.fieldsBackground = [[UIView alloc] initWithFrame:CGRectMake((self.signUpView.frame.size.width-LOGIN_FIELDS_WIDTH)/2, 0, LOGIN_FIELDS_WIDTH, LOGIN_FIELDS_HEIGHT)];
        self.fieldsBackground.backgroundColor = LOGIN_FIELDS_BACKGROUND;
        self.fieldsBackground.layer.cornerRadius = LOGIN_FIELDS_CORNER_RADIUS;
        UIView *fieldsSeperator = [[UIView alloc] initWithFrame:CGRectMake((LOGIN_FIELDS_WIDTH-LOGIN_FIELDS_SEPERATOR_WIDTH)/2, (LOGIN_FIELDS_HEIGHT-SEPERATOR_WIDTH)/2, LOGIN_FIELDS_SEPERATOR_WIDTH, SEPERATOR_WIDTH)];
        fieldsSeperator.backgroundColor = LOGIN_FIELDS_SEPERATOR_COLOR;
        [self.fieldsBackground addSubview:fieldsSeperator];
        [self.signUpView insertSubview:self.fieldsBackground atIndex:1];
        
        self.signUpView.usernameField.font = LOGIN_FIELDS_FONT;
        self.signUpView.passwordField.font = LOGIN_FIELDS_FONT;
        self.signUpView.usernameField.placeholder = @"email";
        self.signUpView.passwordField.placeholder = @"password";
        self.signUpView.usernameField.textColor = LOGIN_FIELDS_TEXT_COLOR;
        self.signUpView.passwordField.textColor = LOGIN_FIELDS_TEXT_COLOR;
        self.signUpView.usernameField.returnKeyType = UIReturnKeyNext;
        CALayer *layer = self.signUpView.usernameField.layer;
        layer.shadowOpacity = 0.0;
        layer = self.signUpView.passwordField.layer;
        layer.shadowOpacity = 0.0;
        
        
        [self setupButton:self.signUpView.signUpButton];
        [self.signUpView.signUpButton setBackgroundImage:[UtilityClass imageWithColor:SIGNUP_BUTTON_BACKGROUND] forState:UIControlStateNormal];
        [self.signUpView.signUpButton setBackgroundImage:[UtilityClass imageWithColor:[UtilityClass darkerColor:SIGNUP_BUTTON_BACKGROUND]] forState:UIControlStateHighlighted];
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
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat relativeStart = (self.signUpView.frame.size.height-(SIGNUP_BUTTON_Y+SIGNUP_BUTTONS_HEIGHT))/2;
    CGFloat viewWidth = self.signUpView.frame.size.width;
    CGRectSetY(self.signUpView.logo, LOGIN_LOGO_Y+relativeStart);
    CGRectSetY(self.fieldsBackground, LOGIN_FIELDS_Y+relativeStart);
    CGRectSetY(self.signUpView.usernameField, LOGIN_FIELDS_Y+(LOGIN_FIELDS_HEIGHT/2)-self.signUpView.usernameField.frame.size.height+relativeStart);
    CGRectSetY(self.signUpView.passwordField, LOGIN_FIELDS_Y+(LOGIN_FIELDS_HEIGHT/2)+relativeStart);
    self.signUpView.signUpButton.frame = CGRectMake((viewWidth-FIELDS_WIDTH)/2,SIGNUP_BUTTON_Y+relativeStart,FIELDS_WIDTH,SIGNUP_BUTTONS_HEIGHT);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.signUpView.usernameField becomeFirstResponder];
}

@end
