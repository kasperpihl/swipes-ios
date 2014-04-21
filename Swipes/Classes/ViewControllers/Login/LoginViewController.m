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
#import "KPAlert.h"
#import <Parse/Parse.h>
#import "RootViewController.h"
#import "UIColor+Utilities.h"
#import "UIImage+Blur.h"
#define SIGNUP_INDICATOR_TAG 15530


#define kLoginOrSignupSubtraction 20
#define LOGIN_FIELDS_HEIGHT 104


#define LOGIN_BUTTON_Y     (15      +LOGIN_FIELDS_Y+LOGIN_FIELDS_HEIGHT)
#define FACEBOOK_BUTTON_Y  (valForScreen(80,100)      +(LOGIN_BUTTON_Y+SIGNUP_BUTTONS_HEIGHT))
#define BUTTON_LABEL_SUBTRACTION 20
#define kExtraBottomSpacing valForScreen(10,10)
#define kScrollupButtonsVal valForScreen(80,30)
#define kLabelAddition 0
#define kContinueButtonJump 25


#define LOGIN_LOGO_Y            valForScreen(40,60)
#define LOGIN_FIELDS_Y          valForScreen(80,100)

#define SIGNUP_BUTTONS_HEIGHT   44

#define kButtonBorderWidth 0
#define kContinueButtonColor kDefTextColor
#define kCornerRadius 2

#define kDefTextColor tcolorF(TextColor,ThemeDark)//color(179, 180, 182, 1)
#define kDefLoginButtonsFont KP_REGULAR(20)

@interface LoginViewController () <UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *signupIndicator;
@property (nonatomic,strong) UIImageView *logoView;
@property (nonatomic,strong) UILabel *loginOrSignupLabel;
@property (nonatomic,strong) UITextField *emailField;
@property (nonatomic,strong) UITextField *passwordField;
@property (nonatomic,strong) UIButton *continueButton;
@property (nonatomic,strong) UILabel *facebookLabel;
@property (nonatomic,strong) UIButton *facebookButton;
@property (nonatomic,strong) UIButton *privacyPolicyButton;
@property (nonatomic,strong) UIButton *forgotButton;
@property (nonatomic,strong) UIButton *changeButton;
@property (nonatomic) BOOL loginState;
@end

@implementation LoginViewController
-(id)init{
    self = [super init];
    if(self){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
        [self.view setBackgroundColor:kWalkthroughBackground];
        
        
        UIButton *resignButton = [[UIButton alloc] initWithFrame:self.view.bounds];
        resignButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
        [resignButton addTarget:self action:@selector(resignFields) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:resignButton];
        
        UIImageView *background = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"default-background.jpg"] rn_boxblurImageWithBlur:0.5f exclusionPath:nil]];
        background.frame = self.view.bounds;
        background.contentMode = (UIViewContentModeScaleAspectFill);// UIViewContentModeScaleAspectFill;
        background.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
        [self.view addSubview:background];
        UIView *overlay = [[UIView alloc] initWithFrame:background.bounds];
        overlay.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
        overlay.backgroundColor = gray(0,0.1);
        [self.view addSubview:overlay];
        /*self.facebookPermissions = @[@"email"];
        self.logInView.externalLogInLabel.text = @"You can also sign up with facebook";
        */
        
        self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:valForScreen(@"wt_swipes_logo",@"swipes_logo_white")]];
        CGRectSetCenterX(self.logoView, self.view.frame.size.width/2);
        [self.view addSubview:self.logoView];
        
        /*self.loginOrSignupLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        self.loginOrSignupLabel.textAlignment = NSTextAlignmentCenter;
        self.loginOrSignupLabel.textColor = tcolor(BackgroundColor);
        self.loginOrSignupLabel.font = KP_LIGHT(13);
        self.loginOrSignupLabel.backgroundColor = CLEAR;
        self.loginOrSignupLabel.text = @"Login or Register";
        [self.loginOrSignupLabel sizeToFit];
        CGRectSetWidth(self.loginOrSignupLabel, 320);
        [self.view addSubview:self.loginOrSignupLabel];*/
        
        CGFloat fieldWidth = 252.0;
        CGFloat fieldHeight = 44.0;
        CGFloat buttonWidth = 196.0f;
        CGFloat buttonHeight = SIGNUP_BUTTONS_HEIGHT;
        
        self.emailField = [[UITextField alloc] initWithFrame:CGRectMake((320-fieldWidth)/2, 0, fieldWidth, fieldHeight)];
        self.emailField.font = KP_LIGHT(16);
        self.emailField.textAlignment = NSTextAlignmentCenter;
        self.emailField.delegate = self;
        //self.emailField.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.emailField.returnKeyType = UIReturnKeyNext;
        self.emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.emailField.layer.cornerRadius = kCornerRadius;
        self.emailField.placeholder = @"email";
        self.emailField.textColor = kDefTextColor;
        UIColor *color = gray(100, 0.3);
        self.emailField.backgroundColor = color;
        
        
        self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake((320-fieldWidth)/2, 0, fieldWidth, fieldHeight)];
        //self.passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.passwordField.delegate = self;
        self.passwordField.textAlignment = NSTextAlignmentCenter;
        self.passwordField.secureTextEntry = YES;
        self.passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.passwordField.layer.cornerRadius = kCornerRadius;
        self.passwordField.font = KP_LIGHT(16);
        self.passwordField.textColor = kDefTextColor;
        self.passwordField.backgroundColor = color;
        self.passwordField.placeholder = @"password";
        
        @try {
            [self.emailField setValue:kDefTextColor
                            forKeyPath:@"_placeholderLabel.textColor"];
            [self.passwordField setValue:kDefTextColor
                                        forKeyPath:@"_placeholderLabel.textColor"];
        }
        @catch (NSException *exception) {
            
        }
        [self.view addSubview:self.emailField];
        [self.view addSubview:self.passwordField];
        
        self.continueButton = [[UIButton alloc] initWithFrame:CGRectMake((320-buttonWidth)/2, 0, buttonWidth, buttonHeight)];
        [self.continueButton setTitle:@"SIGN UP" forState:UIControlStateNormal];
        self.continueButton.backgroundColor = tcolor(DoneColor);//kDefTextColor;
        [self.continueButton addTarget:self action:@selector(pressedContinue:) forControlEvents:UIControlEventTouchUpInside];
        [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setupButton:self.continueButton];
        [self.view addSubview:self.continueButton];
        
        self.facebookLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        self.facebookLabel.font = KP_LIGHT(13);
        self.facebookLabel.textColor = kDefTextColor;
        self.facebookLabel.textAlignment = NSTextAlignmentCenter;
        
        self.facebookLabel.text = @"You can also sign up with:";
        self.facebookLabel.backgroundColor = CLEAR;
        [self.facebookLabel sizeToFit];
        CGRectSetWidth(self.facebookLabel, 320);
        [self.view addSubview:self.facebookLabel];
        
        self.facebookButton = [[UIButton alloc] initWithFrame:CGRectMake((320-buttonWidth)/2, 0, buttonWidth, buttonHeight)];
        [self setupButton:self.facebookButton];
        self.facebookButton.layer.borderWidth = 0;
        [self.facebookButton setBackgroundImage:[color(57,159,219,1) image] forState:UIControlStateNormal];
        [self.facebookButton setBackgroundImage:[[color(57,159,219,1) darker] image] forState:UIControlStateHighlighted];
        [self.facebookButton setTitle:@"FACEBOOK" forState:UIControlStateNormal];
        [self.facebookButton addTarget:self action:@selector(pressedFacebook:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.facebookButton];
        
        
        
        
        self.privacyPolicyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.privacyPolicyButton.frame = CGRectMake(0, 0, sizeWithFont(@"Privacy policy" ,LOGIN_FIELDS_FONT).width+20, fieldHeight);
        self.privacyPolicyButton.titleLabel.font = LOGIN_FIELDS_FONT;
        [self.privacyPolicyButton setTitleColor:kDefTextColor forState:UIControlStateNormal];
        [self.privacyPolicyButton setTitle:@"Privacy policy" forState:UIControlStateNormal];
        [self.privacyPolicyButton addTarget:self action:@selector(pressedPrivacy:) forControlEvents:UIControlEventTouchUpInside];
        self.privacyPolicyButton.frame = CGRectSetPos(self.privacyPolicyButton.frame, 0, self.view.frame.size.height-self.privacyPolicyButton.frame.size.height);
        
        
        [self.view addSubview:self.privacyPolicyButton];
        
        self.forgotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.forgotButton.frame = CGRectMake(0, 0, sizeWithFont(@"Forgot password?" ,LOGIN_FIELDS_FONT).width+20, fieldHeight);
        self.forgotButton.titleLabel.font = LOGIN_FIELDS_FONT;
        [self.forgotButton setTitleColor:kDefTextColor forState:UIControlStateNormal];
        [self.forgotButton setTitle:@"Forgot password?" forState:UIControlStateNormal];
        [self.forgotButton addTarget:self action:@selector(pressedForgot:) forControlEvents:UIControlEventTouchUpInside];
        self.forgotButton.frame = CGRectSetPos(self.forgotButton.frame, self.view.frame.size.width-self.forgotButton.frame.size.width, self.view.frame.size.height-self.forgotButton.frame.size.height);
        self.forgotButton.hidden = YES;
        [self.view addSubview:self.forgotButton];
        
        self.changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        NSInteger margin = 10;
        self.changeButton.frame = CGRectMake(0, 0, sizeWithFont(@"Sign up" ,LOGIN_FIELDS_FONT).width+20, fieldHeight-margin);
        self.changeButton.titleLabel.font = LOGIN_FIELDS_FONT;
        self.changeButton.layer.borderColor = kDefTextColor.CGColor;
        self.changeButton.layer.cornerRadius = 3;
        self.changeButton.layer.borderWidth = 1;
        [self.changeButton setTitleColor:kDefTextColor forState:UIControlStateNormal];
        [self.changeButton setTitle:@"Log in" forState:UIControlStateNormal];
        [self.changeButton addTarget:self action:@selector(pressedChange:) forControlEvents:UIControlEventTouchUpInside];
        self.changeButton.frame = CGRectSetPos(self.changeButton.frame, self.view.frame.size.width-self.changeButton.frame.size.width-margin/2, self.view.frame.size.height-self.changeButton.frame.size.height-margin/2);
        [self.view addSubview:self.changeButton];
        
    }
    return self;
}
-(void)resignFields{
    if([self.emailField isFirstResponder]) [self.emailField resignFirstResponder];
    else if([self.passwordField isFirstResponder]) [self.passwordField resignFirstResponder];
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSLog(@"index:%i",buttonIndex);
    if(buttonIndex == 1){
        UITextField *textField = [alertView textFieldAtIndex:0];
        if(textField.text.length > 0){
            [self showIndicator:YES onElement:self.forgotButton];
            [PFUser requestPasswordResetForEmailInBackground:[textField.text lowercaseString] block:^(BOOL succeeded, NSError *error) {
                [self showIndicator:NO onElement:self.forgotButton];
                if(succeeded){
                    [[[UIAlertView alloc] initWithTitle:@"Email sent"
                                                message:@"Follow the instructions in the email to reset your pass"
                                               delegate:nil
                                      cancelButtonTitle:@"ok"
                                      otherButtonTitles:nil] show];
                }
                else{
                    [self handleErrorFromLogin:error];
                    
                }
            }];
        }
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([textField isEqual:self.emailField]) return [self.passwordField becomeFirstResponder];
    else{
        [self pressedContinue:self.continueButton];
        return YES;
    }
}
-(BOOL)validateFields{
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    if(![UtilityClass validateEmail:email]){
        [[[UIAlertView alloc] initWithTitle:@"Please use an email"
                                    message:@"Make sure you use a real email!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
        return NO;
    }
    else if(password.length == 0){
        [[[UIAlertView alloc] initWithTitle:@"Missing password"
                                    message:@"Make sure to enter your password!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}
-(void)handleErrorFromLogin:(NSError*)error{
    if(error.code == 101){
        [[[UIAlertView alloc] initWithTitle:@"Wrong email or password."
                                    message:@"Please check your informations and try again."
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
        return;
    }
    else if(error.code == 205 || error.code == 125){
        [[[UIAlertView alloc] initWithTitle:@"Email wasn't found."
                                   message:@"We couldn't recognize the email."
                                  delegate:nil
                         cancelButtonTitle:@"ok"
                         otherButtonTitles:nil] show];
        return;
    }
    [[[UIAlertView alloc] initWithTitle:@"Something went wrong."
                                message:@"Please try again."
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    [UtilityClass sendError:error type:@"Login"];
}
-(void)pressedChange:(UIButton*)sender{
    if(!self.loginState){
        [self.changeButton setTitle:@"Sign up" forState:UIControlStateNormal];
        
        self.forgotButton.hidden = NO;
        [self.continueButton setTitle:@"LOG IN" forState:UIControlStateNormal];
        self.facebookLabel.text = @"You can also log in with:";
        CGRectSetY(self.continueButton, self.continueButton.frame.origin.y + kContinueButtonJump);
    }
    else {
        [self.changeButton setTitle:@"Log in" forState:UIControlStateNormal];
        
        self.forgotButton.hidden = YES;
        [self.continueButton setTitle:@"SIGN UP" forState:UIControlStateNormal];
        self.facebookLabel.text = @"You can also sign up with:";
        CGRectSetY(self.continueButton, self.continueButton.frame.origin.y - kContinueButtonJump);
    }
    self.loginState = !self.loginState;
}
-(void)pressedFacebook:(UIButton*)sender{
    [self showIndicator:YES onElement:sender];
    
    [PFFacebookUtils logInWithPermissions:@[@"email"] block:^(PFUser *user, NSError *error) {
        if(error){
            [self showIndicator:NO onElement:sender];
            if([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"code"] integerValue] == 190){
                if([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"error_subcode"] integerValue] == 458){
                    [self pressedFacebook:sender];
                    return;
                }
            }
            if(error.code == 2){
                [[[UIAlertView alloc] initWithTitle:@"Facebook settings"
                                            message:@"Please make sure you've allowed Swipes in Settings -> Facebook"
                                           delegate:nil
                                  cancelButtonTitle:@"ok"
                                  otherButtonTitles:nil] show];
            }
            else{
                [self handleErrorFromLogin:error];
            }
        }
        else{
            [self showIndicator:NO onElement:sender];
            [self.delegate loginViewController:self didLoginUser:user];
        }
    }];
}
-(void)pressedContinue:(UIButton*)sender{
    if(self.emailField.isFirstResponder && self.passwordField.text.length == 0) [self.passwordField becomeFirstResponder];
    else{
        if(![self validateFields]) return;
        [self resignFields];
        [self showIndicator:YES onElement:sender];
        NSString *email = [self.emailField.text lowercaseString];
        [PFCloud callFunctionInBackground:@"checkEmail" withParameters:@{@"email":email} block:^(id object, NSError *error) {
            if(error){
                [self showIndicator:NO onElement:sender];
                [self handleErrorFromLogin:error];
            }
            else if([object isEqualToNumber:@1]){
                voidBlock loginBlock = ^{
                    [PFUser logInWithUsernameInBackground:email password:self.passwordField.text block:^(PFUser *user, NSError *error) {
                        [self showIndicator:NO onElement:sender];
                        if (error) {
                            [self handleErrorFromLogin:error];
                        } else {
                            [self.delegate loginViewController:self didLoginUser:user];
                        }
                    }];
                };
                if(!self.loginState){
                    [UTILITY confirmBoxWithTitle:@"User exists" andMessage:@"Do you want to login instead?" block:^(BOOL succeeded, NSError *error) {
                        if(succeeded){
                            loginBlock();
                        }
                        else [self showIndicator:NO onElement:sender];
                    }];
                }
                else loginBlock();
            }
            else{
                voidBlock signUpBlock = ^{
                    PFUser *user = [PFUser user];
                    user.username = email;
                    user.password = self.passwordField.text;
                    user.email = email;
                    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [self showIndicator:NO onElement:sender];
                        if (!error) {
                            [self.delegate loginViewController:self didLoginUser:user];
                        } else {
                            [self handleErrorFromLogin:error];
                        }
                    }];
                };
                NSString *title = self.loginState ? @"User doesn't exist" : @"New user";
                NSString *message = self.loginState ? @"Do you want to sign up instead?" : [NSString stringWithFormat:@"Do you want to sign up with: %@",email];
                [UTILITY confirmBoxWithTitle:title andMessage:message block:^(BOOL succeeded, NSError *error) {
                    if(succeeded){
                        signUpBlock();
                    }
                    else [self showIndicator:NO onElement:sender];
                }];
            }
        }];
    }
}
-(void)pressedForgot:(UIButton*)sender{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reset password" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset", nil];
    alertView.delegate = self;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    alertView.title = @"Reset password";
    textField.placeholder = @"Email";
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    if(self.emailField.text.length > 0) textField.text = self.emailField.text;
    [alertView show];
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
        CGRectSetY(self.view, -kScrollupButtonsVal);
    }];
}
-(void)keyboardWillHide{
    [UIView animateWithDuration:0.25f animations:^{
        CGRectSetY(self.view, 0);
    }];
    
}

-(void)showIndicator:(BOOL)show onElement:(UIView*)element{
    if(show){
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.tag = SIGNUP_INDICATOR_TAG;
        indicatorView.center = element.center;
        [self.view addSubview:indicatorView];
    
        self.signupIndicator = (UIActivityIndicatorView*)[self.view viewWithTag:SIGNUP_INDICATOR_TAG];
        [self.signupIndicator startAnimating];
        element.hidden = YES;
    }
    else{
        [self.signupIndicator removeFromSuperview];
        self.signupIndicator = nil;
        element.hidden = NO;
    }
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat relativeStart = (self.view.frame.size.height-(FACEBOOK_BUTTON_Y+SIGNUP_BUTTONS_HEIGHT))/2-kExtraBottomSpacing;
    if(relativeStart < 30) relativeStart = 20;

    CGRectSetY(self.logoView, LOGIN_LOGO_Y);

    CGFloat fieldHeight = LOGIN_FIELDS_HEIGHT/2;

    CGRectSetY(self.emailField, LOGIN_FIELDS_Y+(fieldHeight-self.emailField.frame.size.height)/2+relativeStart);
    CGRectSetY(self.passwordField, LOGIN_FIELDS_Y+(LOGIN_FIELDS_HEIGHT/2)+(fieldHeight-self.passwordField.frame.size.height)/2+relativeStart);
    //CGRectSetY(self.loginOrSignupLabel, self.emailField.frame.origin.y-kLoginOrSignupSubtraction);
    CGRectSetX(self.forgotButton, CGRectGetMaxX(self.passwordField.frame)-self.forgotButton.frame.size.width);
    CGRectSetY(self.forgotButton, CGRectGetMaxY(self.passwordField.frame) + kLabelAddition);
    NSInteger loginY = self.loginState ? LOGIN_BUTTON_Y + kContinueButtonJump : LOGIN_BUTTON_Y;
    CGRectSetY(self.continueButton, loginY+relativeStart);
    CGRectSetY(self.facebookLabel,FACEBOOK_BUTTON_Y-BUTTON_LABEL_SUBTRACTION+relativeStart);
    CGRectSetY(self.facebookButton,FACEBOOK_BUTTON_Y+relativeStart);
    
}
-(void)setupButton:(UIButton*)button{
    [button.titleLabel setFont:kDefLoginButtonsFont];
    button.layer.cornerRadius = kCornerRadius;
    button.layer.borderColor = kContinueButtonColor.CGColor;
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
    //[ROOT_CONTROLLER walkthrough];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
