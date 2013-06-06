//
//  LoginViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "LoginViewController.h"
#import "UtilityClass.h"
#import <QuartzCore/QuartzCore.h>




#define LOGIN_FIELDS_CORNER_RADIUS 5
#define LOGIN_FIELDS_WIDTH FIELDS_WIDTH
#define LOGIN_FIELDS_HEIGHT 120
#define LOGIN_FIELDS_SEPERATOR_WIDTH 194


#define LOGIN_BUTTON_Y     (10      +LOGIN_FIELDS_Y+LOGIN_FIELDS_HEIGHT)
#define FACEBOOK_BUTTON_Y  (40      +(LOGIN_BUTTON_Y+SIGNUP_BUTTONS_HEIGHT))
#define SIGNUP_BUTTON_Y    (40      +(FACEBOOK_BUTTON_Y+SIGNUP_BUTTONS_HEIGHT))
#define BUTTON_LABEL_SUBTRACTION 16



@interface LoginViewController ()
@property (nonatomic,strong) IBOutlet UIView *fieldsBackground;
@end

@implementation LoginViewController
-(id)init{
    self = [super init];
    if(self){
        
        self.fields = (PFLogInFieldsUsernameAndPassword | PFLogInFieldsFacebook | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsPasswordForgotten);
        self.facebookPermissions = @[@"email"];
        
        [self.logInView setBackgroundColor:SEGMENT_BACKGROUND];
        
        /*UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_background"]];
        backgroundImageView.contentMode = UIViewContentModeScaleToFill;
        backgroundImageView.autoresizesSubviews = (UIViewAutoresizingFlexibleHeight);
        CGRectSetHeight(backgroundImageView, self.logInView.frame.size.height);
        [self.logInView insertSubview:backgroundImageView atIndex:0];*/
        
        [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logo.png"]]];
        
        // Add login field background
        self.fieldsBackground = [[UIView alloc] initWithFrame:CGRectMake((self.logInView.frame.size.width-LOGIN_FIELDS_WIDTH)/2, 0, LOGIN_FIELDS_WIDTH, LOGIN_FIELDS_HEIGHT)];
        self.fieldsBackground.backgroundColor = LOGIN_FIELDS_BACKGROUND;
        self.fieldsBackground.layer.cornerRadius = LOGIN_FIELDS_CORNER_RADIUS;
        UIView *fieldsSeperator = [[UIView alloc] initWithFrame:CGRectMake((LOGIN_FIELDS_WIDTH-LOGIN_FIELDS_SEPERATOR_WIDTH)/2, (LOGIN_FIELDS_HEIGHT-SEPERATOR_WIDTH)/2, LOGIN_FIELDS_SEPERATOR_WIDTH, SEPERATOR_WIDTH)];
        fieldsSeperator.backgroundColor = LOGIN_FIELDS_SEPERATOR_COLOR;
        [self.fieldsBackground addSubview:fieldsSeperator];
        [self.logInView insertSubview:self.fieldsBackground atIndex:1];
        
        self.logInView.usernameField.font = LOGIN_FIELDS_FONT;
        self.logInView.passwordField.font = LOGIN_FIELDS_FONT;
        self.logInView.usernameField.placeholder = @"email";
        self.logInView.passwordField.placeholder = @"password";
        self.logInView.usernameField.textColor = LOGIN_FIELDS_TEXT_COLOR;
        self.logInView.passwordField.textColor = LOGIN_FIELDS_TEXT_COLOR;
        self.logInView.usernameField.returnKeyType = UIReturnKeyNext;
        CALayer *layer = self.logInView.usernameField.layer;
        layer.shadowOpacity = 0.0;
        layer = self.logInView.passwordField.layer;
        layer.shadowOpacity = 0.0;
        
        
        [self setupButton:self.logInView.logInButton];
        [self.logInView.logInButton setBackgroundImage:[UtilityClass imageWithColor:LOGIN_BUTTON_BACKGROUND] forState:UIControlStateNormal];
        [self.logInView.logInButton setBackgroundImage:[UtilityClass imageWithColor:[UtilityClass darkerColor:LOGIN_BUTTON_BACKGROUND]] forState:UIControlStateHighlighted];
        
        
        self.logInView.externalLogInLabel.font = LOGIN_LABEL_ABOVE_FONT;
        self.logInView.externalLogInLabel.textColor = LOGIN_LABEL_ABOVE_COLOR;
        [self.logInView.externalLogInLabel setShadowOffset:CGSizeZero];
        [self setupButton:self.logInView.facebookButton];
        [self.logInView.facebookButton setBackgroundImage:[UtilityClass imageWithColor:color(57,159,219,1)] forState:UIControlStateNormal];
        [self.logInView.facebookButton setBackgroundImage:[UtilityClass imageWithColor:[UtilityClass darkerColor:color(57,159,219,1)]] forState:UIControlStateHighlighted];
        [self.logInView.facebookButton setTitle:@"FACEBOOK" forState:UIControlStateNormal];
        
        
        self.logInView.signUpLabel.font = LOGIN_LABEL_ABOVE_FONT;
        self.logInView.signUpLabel.textColor = LOGIN_LABEL_ABOVE_COLOR;
        [self.logInView.signUpLabel setShadowOffset:CGSizeZero];
        [self setupButton:self.logInView.signUpButton];
        [self.logInView.signUpButton setBackgroundImage:[UtilityClass imageWithColor:SIGNUP_BUTTON_BACKGROUND] forState:UIControlStateNormal];
        [self.logInView.signUpButton setBackgroundImage:[UtilityClass imageWithColor:[UtilityClass darkerColor:SIGNUP_BUTTON_BACKGROUND]] forState:UIControlStateHighlighted];
        [self.logInView.signUpButton setTitle:@"SIGN UP" forState:UIControlStateNormal];
        
        
        [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
        [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage new] forState:UIControlStateHighlighted];
        [self.logInView.passwordForgottenButton setTitle:@"forgot password?" forState:UIControlStateNormal];
        self.logInView.passwordForgottenButton.titleLabel.font = LOGIN_FIELDS_FONT;
        [self.logInView.passwordForgottenButton setTitleColor:LOGIN_BUTTON_BACKGROUND forState:UIControlStateNormal];
        CGRectSetWidth(self.logInView.passwordForgottenButton, [@"forgot password?" sizeWithFont:LOGIN_FIELDS_FONT].width+20);
        
        
    }
    return self;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat relativeStart = (self.logInView.frame.size.height-(SIGNUP_BUTTON_Y+SIGNUP_BUTTONS_HEIGHT))/2;
    CGFloat viewWidth = self.logInView.frame.size.width;
    [self.logInView.logInButton setTitle:@"LOG IN" forState:UIControlStateNormal];
    [self.logInView.logInButton setTitle:@"LOG IN" forState:UIControlStateHighlighted];
    
    CGRectSetY(self.logInView.logo, LOGIN_LOGO_Y+relativeStart);
    CGRectSetY(self.fieldsBackground, LOGIN_FIELDS_Y+relativeStart);
    CGFloat fieldHeight = LOGIN_FIELDS_HEIGHT/2;
    CGRectSetY(self.logInView.usernameField, LOGIN_FIELDS_Y+(fieldHeight-self.logInView.usernameField.frame.size.height)/2+relativeStart);
    CGRectSetY(self.logInView.passwordField, LOGIN_FIELDS_Y+(LOGIN_FIELDS_HEIGHT/2)+(fieldHeight-self.logInView.passwordField.frame.size.height)/2+relativeStart);
    
    self.logInView.logInButton.frame = CGRectMake((viewWidth-FIELDS_WIDTH)/2,LOGIN_BUTTON_Y+relativeStart,FIELDS_WIDTH,SIGNUP_BUTTONS_HEIGHT);
    self.logInView.facebookButton.frame = CGRectMake((viewWidth-FIELDS_WIDTH)/2,FACEBOOK_BUTTON_Y+relativeStart,FIELDS_WIDTH,SIGNUP_BUTTONS_HEIGHT);
    CGRectSetY(self.logInView.externalLogInLabel,FACEBOOK_BUTTON_Y-BUTTON_LABEL_SUBTRACTION+relativeStart);
    self.logInView.signUpButton.frame = CGRectMake((viewWidth-FIELDS_WIDTH)/2,SIGNUP_BUTTON_Y+relativeStart,FIELDS_WIDTH,SIGNUP_BUTTONS_HEIGHT);
    CGRectSetY(self.logInView.signUpLabel, SIGNUP_BUTTON_Y-BUTTON_LABEL_SUBTRACTION+relativeStart);
    
    UIButton *forPassBtn = self.logInView.passwordForgottenButton;
    CGRectSetHeight(forPassBtn, 38);
    forPassBtn.frame = CGRectSetPos(forPassBtn.frame, self.logInView.frame.size.width-forPassBtn.frame.size.width, self.logInView.frame.size.height-forPassBtn.frame.size.height);
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    }
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
