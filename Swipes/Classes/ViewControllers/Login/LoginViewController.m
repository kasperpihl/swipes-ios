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
#import "SignupViewController.h"
#import "KPAlert.h"
#import "RootViewController.h"
#import "UIColor+Utilities.h"
#define SIGNUP_INDICATOR_TAG 15530
#define PRIVACY_BUTTON_TAG 16630

#define LOGIN_FIELDS_CORNER_RADIUS 5
#define LOGIN_FIELDS_WIDTH FIELDS_WIDTH
#define LOGIN_FIELDS_HEIGHT 120
#define LOGIN_FIELDS_SEPERATOR_WIDTH 194


#define LOGIN_BUTTON_Y     (10      +LOGIN_FIELDS_Y+LOGIN_FIELDS_HEIGHT)
#define FACEBOOK_BUTTON_Y  (40      +(LOGIN_BUTTON_Y+SIGNUP_BUTTONS_HEIGHT))
#define BUTTON_LABEL_SUBTRACTION 17
#define kExtraBottomSpacing 30

#define LOGIN_LOGO_Y            0
#define LOGIN_FIELDS_Y          100
#define FIELDS_WIDTH            260
#define kLoginButtonSpacing     20
#define SIGNUP_BUTTONS_HEIGHT   50

#define kButtonBorderWidth 2
#define kButtonBorderColor [UIColor whiteColor]
#define kButtonCornerRadius 5

#define kDefTextColor gray(153,1)
#define kDefBackColor gray(204,1)
#define kDefButtonFont KP_BOLD(23)
#define kDefLoginButtonsFont KP_REGULAR(20)
#define kLoginButtonColor tbackground(TaskTableGradientBackground)

@interface LoginViewController () < PFSignUpViewControllerDelegate>
@property (nonatomic,strong) IBOutlet UIView *fieldsBackground;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *signupIndicator;
@property (nonatomic,weak) IBOutlet UIButton *privacyPolicyButton;
@end

@implementation LoginViewController
-(id)init{
    self = [super init];
    if(self){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
        SignupViewController *signupVC = [[SignupViewController alloc] init];
        signupVC.delegate = self;
        self.signUpController = signupVC;
        self.fields = (PFLogInFieldsUsernameAndPassword | PFLogInFieldsFacebook | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsPasswordForgotten);
        self.facebookPermissions = @[@"email"];
        self.logInView.externalLogInLabel.text = @"You can also sign up with facebook";
        [self.logInView setBackgroundColor:kDefBackColor];

        
        [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wt_swipes_logo"]]];
        //self.logInView.logo.alpha = 0.5;
        // Add login field background
        self.fieldsBackground = [[UIView alloc] initWithFrame:CGRectMake((self.logInView.frame.size.width-LOGIN_FIELDS_WIDTH)/2, 0, LOGIN_FIELDS_WIDTH, LOGIN_FIELDS_HEIGHT)];
        UIView *fieldsSeperator = [[UIView alloc] initWithFrame:CGRectMake((LOGIN_FIELDS_WIDTH-LOGIN_FIELDS_SEPERATOR_WIDTH)/2, (LOGIN_FIELDS_HEIGHT-SEPERATOR_WIDTH)/2, LOGIN_FIELDS_SEPERATOR_WIDTH, SEPERATOR_WIDTH)];
        fieldsSeperator.backgroundColor = LOGIN_FIELDS_BACKGROUND;
        [self.fieldsBackground addSubview:fieldsSeperator];
        [self.logInView insertSubview:self.fieldsBackground atIndex:1];
        
        @try {
            [self.logInView.usernameField setValue:LOGIN_FIELDS_BACKGROUND
                            forKeyPath:@"_placeholderLabel.textColor"];
            [self.logInView.passwordField setValue:LOGIN_FIELDS_BACKGROUND
                                        forKeyPath:@"_placeholderLabel.textColor"];
        }
        @catch (NSException *exception) {
            
        }
        
        self.logInView.usernameField.font = KP_SEMIBOLD(15);
        self.logInView.usernameField.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.logInView.passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.logInView.passwordField.font = KP_SEMIBOLD(15);
        self.logInView.usernameField.placeholder = @"email";
        self.logInView.passwordField.placeholder = @"password";
        self.logInView.usernameField.textColor = LOGIN_FIELDS_BACKGROUND;
        self.logInView.passwordField.textColor = LOGIN_FIELDS_BACKGROUND;
        self.logInView.usernameField.returnKeyType = UIReturnKeyNext;
        CALayer *layer = self.logInView.usernameField.layer;
        layer.shadowOpacity = 0.0;
        layer = self.logInView.passwordField.layer;
        layer.shadowOpacity = 0.0;
        
        [self setupButton:self.logInView.logInButton];
        [self.logInView.logInButton setBackgroundImage:[tbackground(TaskTableGradientBackground) image] forState:UIControlStateNormal];
        [self.logInView.logInButton setBackgroundImage:[[tbackground(TaskTableGradientBackground) darker] image] forState:UIControlStateHighlighted];
        
        
        self.logInView.externalLogInLabel.font = LOGIN_LABEL_ABOVE_FONT;
        self.logInView.externalLogInLabel.textColor = LOGIN_FIELDS_BACKGROUND;
        [self.logInView.externalLogInLabel setShadowOffset:CGSizeZero];
        [self setupButton:self.logInView.facebookButton];
        [self.logInView.facebookButton setBackgroundImage:[color(57,159,219,1) image] forState:UIControlStateNormal];
        [self.logInView.facebookButton setBackgroundImage:[[color(57,159,219,1) darker] image] forState:UIControlStateHighlighted];
        [self.logInView.facebookButton setTitle:@"FACEBOOK" forState:UIControlStateNormal];
        
        
        self.logInView.signUpLabel.hidden = YES;
        [self setupButton:self.logInView.signUpButton];
        [self.logInView.signUpButton setBackgroundImage:[tbackground(TaskTableGradientBackground) image] forState:UIControlStateNormal];
        [self.logInView.signUpButton setBackgroundImage:[[tbackground(TaskTableGradientBackground) darker] image] forState:UIControlStateHighlighted];
        [self.logInView.signUpButton setTitle:@"SIGN UP" forState:UIControlStateNormal];
        
        
        
        [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
        [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage new] forState:UIControlStateHighlighted];
        [self.logInView.passwordForgottenButton setTitle:@"forgot password?" forState:UIControlStateNormal];
        self.logInView.passwordForgottenButton.titleLabel.font = LOGIN_FIELDS_FONT;
        [self.logInView.passwordForgottenButton setTitleColor:LOGIN_FIELDS_BACKGROUND forState:UIControlStateNormal];
        CGRectSetWidth(self.logInView.passwordForgottenButton, [@"forgot password?" sizeWithFont:LOGIN_FIELDS_FONT].width+20);
        
        UIButton *privacyPolicyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        privacyPolicyButton.frame = CGRectMake(0, 0, [@"Privacy policy" sizeWithFont:LOGIN_FIELDS_FONT].width+20, self.logInView.passwordForgottenButton.frame.size.height);
        privacyPolicyButton.titleLabel.font = LOGIN_FIELDS_FONT;
        [privacyPolicyButton setTitleColor:LOGIN_FIELDS_BACKGROUND forState:UIControlStateNormal];
        [privacyPolicyButton setTitle:@"Privacy policy" forState:UIControlStateNormal];
        [privacyPolicyButton addTarget:self action:@selector(pressedPrivacy:) forControlEvents:UIControlEventTouchUpInside];
        self.privacyPolicyButton = privacyPolicyButton;
        [self.logInView addSubview:privacyPolicyButton];
        
        [self.logInView.signUpButton removeTarget:nil
                           action:NULL
                 forControlEvents:UIControlEventAllEvents];
        [self.logInView.signUpButton addTarget:self action:@selector(pressedSignUp:) forControlEvents:UIControlEventTouchUpInside];
        [self.logInView.dismissButton addTarget:self action:@selector(pressedDismiss:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([textField isEqual:self.logInView.usernameField]) return [super textFieldShouldReturn:textField];
    else{
        [self pressedSignUp:self.logInView.signUpButton];
        return YES;
    }
}
-(void)pressedSignUp:(UIButton*)sender{
    //[self switchToSignup:YES animated:YES];
    self.signUpController.signUpView.usernameField.text = self.logInView.usernameField.text;
    self.signUpController.signUpView.passwordField.text = self.logInView.passwordField.text;
    [self.signUpController.signUpView.signUpButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}
-(void)pressedPrivacy:(UIButton*)sender{
    [UTILITY confirmBoxWithTitle:@"Privacy policy" andMessage:@"Do you want to open our privacy policy?" block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://swipesapp.com/privacypolicy.pdf"]];
        }
    }];
}
-(void)keyboardWillShow{
    [UIView animateWithDuration:0.25f animations:^{
        CGRectSetY(self.logInView, -30);
    }];
}
-(void)keyboardWillHide{
    [UIView animateWithDuration:0.25f animations:^{
        CGRectSetY(self.logInView, 0);
    }];
}
#pragma mark - PFSignUpViewControllerDelegate
// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if([key isEqualToString:@"username"]){
            if(![UtilityClass validateEmail:field]){
                [[[UIAlertView alloc] initWithTitle:@"Please use an email"
                                            message:@"Make sure you use a real email!"
                                           delegate:nil
                                  cancelButtonTitle:@"ok"
                                  otherButtonTitles:nil] show];
                return NO;
            }
        }
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    if(informationComplete){
        if([self.signUpController.signUpView.usernameField isFirstResponder]) [self.signUpController.signUpView.usernameField resignFirstResponder];
        else if([self.signUpController.signUpView.passwordField isFirstResponder]) [self.signUpController.signUpView.passwordField resignFirstResponder];
        [self showIndicator:YES];
    }
    return informationComplete;
}

-(void)showIndicator:(BOOL)show{
    if(show){
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicatorView.tag = SIGNUP_INDICATOR_TAG;
        indicatorView.center = self.logInView.signUpButton.center;
        [self.logInView insertSubview:indicatorView atIndex:3];
    
        self.signupIndicator = (UIActivityIndicatorView*)[self.logInView viewWithTag:SIGNUP_INDICATOR_TAG];
        [self.signupIndicator startAnimating];
        self.logInView.signUpButton.hidden = YES;
    }
    else{
        [self.signupIndicator removeFromSuperview];
        self.logInView.signUpButton.hidden = NO;
    }
}
// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self showIndicator:NO];
    [self.delegate logInViewController:self didLogInUser:user];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"error:%@",error);
    [self.signUpController.signUpView.usernameField becomeFirstResponder];
    [self showIndicator:NO];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat relativeStart = (self.logInView.frame.size.height-(FACEBOOK_BUTTON_Y+SIGNUP_BUTTONS_HEIGHT))/2-kExtraBottomSpacing;
    if(relativeStart < 30) relativeStart = 5;
    CGFloat viewWidth = self.logInView.frame.size.width;
    [self.logInView.logInButton setTitle:@"LOG IN" forState:UIControlStateNormal];
    [self.logInView.logInButton setTitle:@"LOG IN" forState:UIControlStateHighlighted];

    CGRectSetY(self.logInView.logo, LOGIN_LOGO_Y+relativeStart);
    CGRectSetY(self.fieldsBackground, LOGIN_FIELDS_Y+relativeStart);
    CGFloat fieldHeight = LOGIN_FIELDS_HEIGHT/2;
    CGRectSetY(self.logInView.usernameField, LOGIN_FIELDS_Y+(fieldHeight-self.logInView.usernameField.frame.size.height)/2+relativeStart);
    CGRectSetY(self.logInView.passwordField, LOGIN_FIELDS_Y+(LOGIN_FIELDS_HEIGHT/2)+(fieldHeight-self.logInView.passwordField.frame.size.height)/2+relativeStart);
    
    CGFloat logSignButtonWidth = (FIELDS_WIDTH/2) - (kLoginButtonSpacing/2);
    
    self.logInView.logInButton.frame = CGRectMake((viewWidth-FIELDS_WIDTH)/2,LOGIN_BUTTON_Y+relativeStart,logSignButtonWidth,SIGNUP_BUTTONS_HEIGHT);
    self.logInView.facebookButton.frame = CGRectMake((viewWidth-FIELDS_WIDTH)/2,FACEBOOK_BUTTON_Y+relativeStart,FIELDS_WIDTH,SIGNUP_BUTTONS_HEIGHT);
    CGRectSetY(self.logInView.externalLogInLabel,FACEBOOK_BUTTON_Y-BUTTON_LABEL_SUBTRACTION+relativeStart);
    self.logInView.signUpButton.frame = CGRectMake((viewWidth-FIELDS_WIDTH)/2 + logSignButtonWidth + kLoginButtonSpacing,LOGIN_BUTTON_Y+relativeStart,logSignButtonWidth,SIGNUP_BUTTONS_HEIGHT);
    
    UIButton *forPassBtn = self.logInView.passwordForgottenButton;
    CGRectSetHeight(forPassBtn, 38);
    forPassBtn.frame = CGRectSetPos(forPassBtn.frame, self.logInView.frame.size.width-forPassBtn.frame.size.width, self.logInView.frame.size.height-forPassBtn.frame.size.height);
    
    UIButton *privacyBtn = self.privacyPolicyButton;
    CGRectSetHeight(privacyBtn, 38);
    privacyBtn.frame = CGRectSetPos(privacyBtn.frame, 0, self.logInView.frame.size.height-privacyBtn.frame.size.height);
}
-(void)setupButton:(UIButton*)button{
    [button setBackgroundImage:nil forState:UIControlStateHighlighted];
    [button.titleLabel setFont:kDefLoginButtonsFont];
    [button setImage:[UIImage new] forState:UIControlStateNormal];
    [button setImage:nil forState:UIControlStateHighlighted];
    [button.titleLabel setShadowOffset:CGSizeZero];
    button.layer.cornerRadius = kButtonCornerRadius;
    button.layer.borderColor = kButtonBorderColor.CGColor;
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = kButtonBorderWidth;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [ROOT_CONTROLLER walkthrough];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
