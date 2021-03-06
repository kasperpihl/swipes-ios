//
//  LoginViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

#import "UtilityClass.h"
#import "KPAlert.h"
#import "AnalyticsHandler.h"

#import "WalkthroughTitleView.h"
#import "SlowHighlightIcon.h"
#import "RootViewController.h"
#import "UIColor+Utilities.h"
#import "UIImage+Blur.h"
#import "LoginViewController.h"

#define launchImageName @"MASTER_000"
#define launchImageNumber 22
#define SIGNUP_INDICATOR_TAG 15530


#define LOGIN_FIELDS_HEIGHT 104


#define LOGIN_LOGO_Y            0
#define LOGIN_FIELDS_Y          (LOGIN_LOGO_Y + valForIpad(110, 110))

#define LOGIN_BUTTON_Y     (15      +LOGIN_FIELDS_Y+LOGIN_FIELDS_HEIGHT)
#define FACEBOOK_BUTTON_Y  (15 +(LOGIN_BUTTON_Y+SIGNUP_BUTTONS_HEIGHT))
#define BUTTON_LABEL_SUBTRACTION 21
#define kExtraBottomSpacing valForScreen(10,10)
#define kScrollupButtonsVal valForScreen(100,100)
#define kLabelAddition 0
#define kContinueButtonJump 25



#define SIGNUP_BUTTONS_HEIGHT   44

#define kButtonBorderWidth 1
#define kContinueButtonColor kDefTextColor
#define kCornerRadius 7

#define kIconColor tcolor(LaterColor)//color(179, 180, 182, 1)
#define kDefFieldColor tcolorF(TextColor,ThemeDark)
#define kDefTextColor tcolorF(TextColor, ThemeLight)
#define kDefLoginButtonsFont KP_REGULAR(14)

typedef enum {
    LoginStateWelcome,
    LoginStateSignup,
    LoginStateLogin
} LoginState;

@interface LoginViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic) LoginState currentState;


@property (nonatomic,strong) UIImageView *backgroundImage;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *signupIndicator;

@property (nonatomic) UIButton *backButton;
@property (nonatomic,strong) UILabel *logoView;
@property (nonatomic,strong) WalkthroughTitleView *titleView;

@property (nonatomic,strong) UILabel *loginOrSignupLabel;
@property (nonatomic,strong) UITextField *emailField;
@property (nonatomic,strong) UITextField *passwordField;
@property (nonatomic,strong) UIButton *continueButton;
@property (nonatomic) UIButton *tryButton;
@property (nonatomic,strong) UILabel *facebookLabel;
@property (nonatomic,strong) UIButton *facebookButton;
@property (nonatomic,strong) UIButton *privacyPolicyButton;
@property (nonatomic,strong) UIButton *forgotButton;
@property (nonatomic,strong) UIButton *loginButton;

@end

@implementation LoginViewController

-(id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
        
        self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%i.jpg",launchImageName,0]]];
        [self.backgroundImage setFrame:self.view.bounds];
        self.backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
        /*NSMutableArray *animationImages = [NSMutableArray array];
        for(NSInteger i = 0 ; i < launchImageNumber ; i++){
            [animationImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%@%li.jpg",launchImageName,(long)i]]];
        }
        NSArray *reversedImages = [[animationImages reverseObjectEnumerator] allObjects];
        [animationImages addObjectsFromArray:reversedImages];
        self.backgroundImage.animationImages = animationImages;*/
        self.backgroundImage.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.backgroundImage setAnimationDuration:4.5];
        [self.backgroundImage startAnimating];
        [self.view addSubview:self.backgroundImage];

        
        UIButton *resignButton = [[UIButton alloc] initWithFrame:self.view.bounds];
        resignButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [resignButton addTarget:self action:@selector(resignFields) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:resignButton];
        
        self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, SIGNUP_BUTTONS_HEIGHT, SIGNUP_BUTTONS_HEIGHT)];
        self.backButton.titleLabel.font = iconFont(23);
        [self.backButton setTitle:iconString(@"back") forState:UIControlStateNormal];
        [self.backButton setTitleColor:kDefTextColor forState:UIControlStateNormal];
        [self.backButton addTarget:self action:@selector(pressedBack:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.backButton];
        self.logoView = iconLabel(@"logo", 60);
        self.logoView.center = CGPointMake(self.view.center.x, self.logoView.center.y);
        self.logoView.contentMode = UIViewContentModeCenter;
        self.logoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self.logoView setTextColor:kIconColor];
        [self.view addSubview:self.logoView];
        
        self.titleView = [[WalkthroughTitleView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
        self.titleView.spacing = 5;
        self.titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.titleView.titleLabel.font = KP_BOLD(17);
        self.titleView.subtitleLabel.font = KP_REGULAR(12);
        self.titleView.titleLabel.textColor = kDefTextColor;
        self.titleView.subtitleLabel.textColor = kDefTextColor;
        [self.titleView setTitle:NSLocalizedString(@"Focus. Swipe. Achieve.", nil) subtitle:NSLocalizedString(@"Task List made for High Achievers", nil)];
        [self.view addSubview:self.titleView];
        
        self.loginOrSignupLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        self.loginOrSignupLabel.textAlignment = NSTextAlignmentCenter;
        self.loginOrSignupLabel.textColor = kDefTextColor;
        self.loginOrSignupLabel.font = KP_REGULAR(14);
        self.loginOrSignupLabel.backgroundColor = CLEAR;
        self.loginOrSignupLabel.text = NSLocalizedString(@"You can register with email", nil);
        [self.loginOrSignupLabel sizeToFit];
        CGRectSetWidth(self.loginOrSignupLabel, self.view.frame.size.width);
        self.loginOrSignupLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:self.loginOrSignupLabel];
        
        CGFloat fieldWidth = 252.0;
        CGFloat fieldMargin = (self.view.frame.size.width - fieldWidth) / 2;
        CGFloat fieldHeight = 44.0;
        CGFloat buttonWidth = 160.0f;
        CGFloat buttonMargin = (self.view.frame.size.width - buttonWidth) / 2;
        CGFloat buttonHeight = SIGNUP_BUTTONS_HEIGHT;

        self.emailField = [[UITextField alloc] initWithFrame:CGRectMake(fieldMargin, 0, self.view.frame.size.width - fieldMargin * 2, fieldHeight)];
        self.emailField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        self.emailField.font = KP_REGULAR(16);

        self.emailField.textAlignment = NSTextAlignmentCenter;
        self.emailField.delegate = self;
        //self.emailField.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.emailField.returnKeyType = UIReturnKeyNext;
        self.emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.emailField.layer.cornerRadius = kCornerRadius;
        self.emailField.placeholder = NSLocalizedString(@"email", nil);
        self.emailField.textColor = kDefFieldColor;
        UIColor *color = gray(55, 0.5);
        self.emailField.backgroundColor = color;
        
        
        self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(fieldMargin, 0, self.view.frame.size.width - fieldMargin * 2, fieldHeight)];
        //self.passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.passwordField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        self.passwordField.delegate = self;
        self.passwordField.textAlignment = NSTextAlignmentCenter;
        self.passwordField.secureTextEntry = YES;
        self.passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.passwordField.layer.cornerRadius = kCornerRadius;
        self.passwordField.font = KP_REGULAR(16);
        self.passwordField.textColor = kDefFieldColor;
        self.passwordField.backgroundColor = color;
        self.passwordField.placeholder = NSLocalizedString(@"password", nil);
        
        @try {
            [self.emailField setValue:kDefFieldColor
                            forKeyPath:@"_placeholderLabel.textColor"];
            [self.passwordField setValue:kDefFieldColor
                                        forKeyPath:@"_placeholderLabel.textColor"];
        }
        @catch (NSException *exception) {
            
        }
        [self.view addSubview:self.emailField];
        [self.view addSubview:self.passwordField];
        
        
        UIColor *conColor = kIconColor;//  color(255, 190, 97, 1);//color(24, 188, 241, 1);
        self.continueButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
        self.continueButton.frame = CGRectMake(buttonMargin, 0, self.view.frame.size.width - buttonMargin * 2, buttonHeight);
        self.continueButton.layer.cornerRadius = kCornerRadius;
        self.continueButton.layer.borderColor = conColor.CGColor;
        self.continueButton.layer.borderWidth = kButtonBorderWidth;
        self.continueButton.backgroundColor = CLEAR;
        self.continueButton.layer.masksToBounds = YES;
        self.continueButton.titleLabel.font = kDefLoginButtonsFont;
        [self.continueButton setTitleColor:tcolorF(TextColor,ThemeDark) forState:UIControlStateNormal];
        [self.continueButton setTitle:[NSLocalizedString(@"Create Account", nil) uppercaseString] forState:UIControlStateNormal];
        [self.continueButton  setBackgroundImage:[conColor image] forState:UIControlStateNormal];
        [self.continueButton  setBackgroundImage:[alpha(conColor, 0) image] forState:UIControlStateHighlighted];
        [self.continueButton setTitleColor:conColor forState:UIControlStateHighlighted];
        [self.continueButton addTarget:self action:@selector(pressedContinue:) forControlEvents:UIControlEventTouchUpInside];
        self.continueButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:self.continueButton];
        
        
        //UIColor *tryColor = tcolorF(TextColor, ThemeDark); //color(255, 190, 97, 1)
        self.tryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.tryButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        self.tryButton.backgroundColor = CLEAR;
        self.tryButton.titleLabel.font = LOGIN_FIELDS_FONT;
        
        [self.tryButton setTitleColor:kDefTextColor forState:UIControlStateNormal];
        NSString *title = [USER_DEFAULTS boolForKey:isTryingString] ? NSLocalizedString(@"Keep trying Swipes", nil) : NSLocalizedString(@"Try out", nil);
        [self.tryButton setTitle:title forState:UIControlStateNormal];
        [self.tryButton addTarget:self action:@selector(pressedTryButton:) forControlEvents:UIControlEventTouchUpInside];
        self.tryButton.frame = CGRectMake(0, 0, sizeWithFont(title ,LOGIN_FIELDS_FONT).width + 36, fieldHeight);
        self.tryButton.frame = CGRectSetPos(self.tryButton.frame, 0, self.view.frame.size.height-self.tryButton.frame.size.height);
        [self.view addSubview:self.tryButton];
        
        /*
        self.continueButton = [[UIButton alloc] initWithFrame:CGRectMake((320-buttonWidth)/2, 0, buttonWidth, buttonHeight)];
        [self.continueButton setTitle:@"Create Account" forState:UIControlStateNormal];
        self.continueButton.backgroundColor = tcolor(DoneColor);//kDefTextColor;
        [self.continueButton addTarget:self action:@selector(pressedContinue:) forControlEvents:UIControlEventTouchUpInside];
        [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setupButton:self.continueButton];*/

        
        self.facebookLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        self.facebookLabel.font = KP_REGULAR(14);
        self.facebookLabel.textColor = kDefTextColor;
        self.facebookLabel.textAlignment = NSTextAlignmentCenter;
        
        self.facebookLabel.text = NSLocalizedString(@"Or register with Facebook", nil);
        self.facebookLabel.backgroundColor = CLEAR;
        [self.facebookLabel sizeToFit];
        CGRectSetWidth(self.facebookLabel, self.view.frame.size.width);
        self.facebookLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:self.facebookLabel];
        
        self.facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonMargin, 0, self.view.frame.size.width - buttonMargin * 2, buttonHeight)];
        [self setupButton:self.facebookButton];
        self.facebookButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        self.facebookButton.layer.borderWidth = 0;
        [self.facebookButton setBackgroundImage:[color(57,159,219,1) image] forState:UIControlStateNormal];
        [self.facebookButton setBackgroundImage:[[color(57,159,219,1) darker] image] forState:UIControlStateHighlighted];
        [self.facebookButton setTitle:@"FACEBOOK" forState:UIControlStateNormal];
        [self.facebookButton addTarget:self action:@selector(pressedFacebook:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.facebookButton];
        
        
        
        
        self.privacyPolicyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.privacyPolicyButton.frame = CGRectMake(0, 0, sizeWithFont(NSLocalizedString(@"Policies", nil) ,LOGIN_FIELDS_FONT).width + 20, fieldHeight);
        self.privacyPolicyButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        self.privacyPolicyButton.titleLabel.font = LOGIN_FIELDS_FONT;
        [self.privacyPolicyButton setTitleColor:kDefTextColor forState:UIControlStateNormal];
        [self.privacyPolicyButton setTitle:NSLocalizedString(@"Policies", nil) forState:UIControlStateNormal];
        [self.privacyPolicyButton addTarget:self action:@selector(pressedPrivacy:) forControlEvents:UIControlEventTouchUpInside];
        self.privacyPolicyButton.frame = CGRectSetPos(self.privacyPolicyButton.frame, 0, self.view.frame.size.height-self.privacyPolicyButton.frame.size.height);
        
        
        [self.view addSubview:self.privacyPolicyButton];
        
        self.forgotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.forgotButton.frame = CGRectMake(0, 0, sizeWithFont(NSLocalizedString(@"Forgot password?", nil) ,LOGIN_FIELDS_FONT).width+20, fieldHeight);
        self.forgotButton.titleLabel.font = LOGIN_FIELDS_FONT;
        [self.forgotButton setTitleColor:kDefTextColor forState:UIControlStateNormal];
        [self.forgotButton setTitle:NSLocalizedString(@"Forgot password?", nil) forState:UIControlStateNormal];
        [self.forgotButton addTarget:self action:@selector(pressedForgot:) forControlEvents:UIControlEventTouchUpInside];
        self.forgotButton.frame = CGRectSetPos(self.forgotButton.frame, self.view.frame.size.width-self.forgotButton.frame.size.width, self.view.frame.size.height-self.forgotButton.frame.size.height);
        self.forgotButton.hidden = YES;
        [self.view addSubview:self.forgotButton];
        
        self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        NSInteger margin = 10;
        UIFont *loginFont = KP_BOLD(16);
        self.loginButton.frame = CGRectMake(0, 0, sizeWithFont(NSLocalizedString(@"Sign up", nil) ,loginFont).width+20, fieldHeight - margin);
        self.loginButton.titleLabel.font = loginFont;
        [self.loginButton setTitleColor:kDefTextColor forState:UIControlStateNormal];
        [self.loginButton setTitle:NSLocalizedString(@"Log in", nil) forState:UIControlStateNormal];
        [self.loginButton addTarget:self action:@selector(pressedChange:) forControlEvents:UIControlEventTouchUpInside];
        self.loginButton.frame = CGRectSetPos(self.loginButton.frame, self.view.frame.size.width-self.loginButton.frame.size.width-margin/2, self.view.frame.size.height-self.loginButton.frame.size.height-margin/2);
        [self.view addSubview:self.loginButton];
        self.loginButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self setCurrentState:LoginStateWelcome animated:NO];
    }
    return self;
}

-(void)resignFields
{
    if (self.emailField.isFirstResponder)
        [self.emailField resignFirstResponder];
    else if (self.passwordField.isFirstResponder)
        [self.passwordField resignFirstResponder];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    DLog(@"index:%li",(long)buttonIndex);
    if(buttonIndex == 1){
        UITextField *textField = [alertView textFieldAtIndex:0];
        if(textField.text.length > 0){
            [self showIndicator:YES onElement:self.forgotButton];
            [PFUser requestPasswordResetForEmailInBackground:[textField.text lowercaseString] block:^(BOOL succeeded, NSError *error) {
                [self showIndicator:NO onElement:self.forgotButton];
                if(succeeded){
                    [UTILITY alertWithTitle:NSLocalizedString(@"Email sent", nil) andMessage:NSLocalizedString(@"Follow the instructions in the email to reset your pass", nil)];
                }
                else{
                    [self handleErrorFromLogin:error];
                    
                }
            }];
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField isEqual:self.emailField])
        return [self.passwordField becomeFirstResponder];
    else {
        return [self pressedContinue:self.continueButton];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.continueButton.hidden = NO;
    self.backButton.hidden = YES;
    self.passwordField.hidden = NO;
    self.facebookButton.hidden = YES;
    self.logoView.hidden = YES;
    self.facebookLabel.hidden = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (!self.emailField.isFirstResponder && !self.passwordField.isFirstResponder) {
        self.logoView.hidden = NO;
        self.continueButton.hidden = YES;
        self.backButton.hidden = NO;
        self.facebookButton.hidden = NO;
        if (self.currentState != LoginStateLogin)
            self.passwordField.hidden = YES;
        self.facebookLabel.hidden = NO;
    }
}

-(BOOL)areValidFields
{
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    if(![UtilityClass validateEmail:email]){
        return NO;
    }
    else if (password.length == 0){
        return NO;
    }
    return YES;
}

-(BOOL)validateFields{
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    if(![UtilityClass validateEmail:email]){
        [UTILITY alertWithTitle:NSLocalizedString(@"Please use an email", nil) andMessage:NSLocalizedString(@"Make sure you use a real email!", nil)];
        return NO;
    }
    else if(password.length == 0){
        [UTILITY alertWithTitle:NSLocalizedString(@"Missing password", nil) andMessage:NSLocalizedString(@"Make sure to enter your password!", nil)];
        return NO;
    }
    return YES;
}

-(void)handleErrorFromLogin:(NSError*)error{
    [self resignFields];
    [self keyboardWillHide];
    
    if (error.code == 101){
        [UTILITY alertWithTitle:NSLocalizedString(@"Wrong email or password.", nil) andMessage:NSLocalizedString(@"Please check your informations and try again.", nil)];
        return;
    }
    else if(error.code == 205 || error.code == 125){
        [UTILITY alertWithTitle:NSLocalizedString(@"Email wasn't found.", nil) andMessage:NSLocalizedString(@"We couldn't recognize the email.", nil)];
        return;
    }
    
    NSString* errorMessage = NSLocalizedString(@"Please try again.", nil);
    if ([error respondsToSelector:@selector(fberrorUserMessage)] && error.fberrorUserMessage) {
        errorMessage = [errorMessage stringByAppendingString:[NSString stringWithFormat:@" (%@)", error.fberrorUserMessage]];
    }
    else if (error.localizedDescription) {
        errorMessage = [errorMessage stringByAppendingString:[NSString stringWithFormat:@" (%@)", error.localizedDescription]];
    }
//    else if (error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"message"]) {
//        errorMessage = [errorMessage stringByAppendingString:[NSString stringWithFormat:@" (%@)", error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"message"]]];
//    }
    
    [UTILITY alertWithTitle:NSLocalizedString(@"Something went wrong.", nil) andMessage:errorMessage];
    [UtilityClass sendError:error type:@"Login" attachment:@{@"message": errorMessage}];
}
-(void)setCurrentState:(LoginState)currentState animated:(BOOL)animated
{
    _currentState = currentState;
    BOOL doesRequireFields = (currentState != LoginStateWelcome);
    self.backButton.hidden = !doesRequireFields;
    self.passwordField.hidden = (currentState != LoginStateLogin);
    self.emailField.hidden = !doesRequireFields;
    self.forgotButton.hidden = (currentState != LoginStateLogin);
    self.facebookButton.hidden = !doesRequireFields;
    self.privacyPolicyButton.hidden = !doesRequireFields;
    self.facebookLabel.hidden = !doesRequireFields;
    self.loginOrSignupLabel.hidden = !doesRequireFields;
    
    //self.logoView.hidden = doesRequireFields;
    self.titleView.hidden = doesRequireFields;
    self.tryButton.hidden = doesRequireFields;
    self.continueButton.hidden = doesRequireFields;
    
    [self.loginButton setTitle:(self.currentState == LoginStateLogin ? NSLocalizedString(@"Sign up", nil) : NSLocalizedString(@"Log in", nil)) forState:UIControlStateNormal];
    switch (currentState) {
        case LoginStateWelcome:
            [self.continueButton setTitle:[NSLocalizedString(@"Create Account", nil) uppercaseString] forState:UIControlStateNormal];
            break;
        case LoginStateLogin:
            self.loginOrSignupLabel.text = NSLocalizedString(@"You can log in with email", nil);
            self.facebookLabel.text = NSLocalizedString(@"Or log in with Facebook", nil);
            [self.continueButton setTitle:[NSLocalizedString(@"Log in", nil) uppercaseString] forState:UIControlStateNormal];
            break;
        case LoginStateSignup:
            self.loginOrSignupLabel.text = NSLocalizedString(@"You can register with email", nil);
            self.facebookLabel.text = NSLocalizedString(@"Or register with Facebook", nil);
            [self.continueButton setTitle:[NSLocalizedString(@"Register", nil) uppercaseString] forState:UIControlStateNormal];
            break;
    }
    [self.view setNeedsLayout];
}

-(void)setCurrentState:(LoginState)currentState{
    [self setCurrentState:currentState animated:NO];
}

-(void)pressedBack:(UIButton*)sender{
    [self setCurrentState:LoginStateWelcome];
}

-(void)pressedChange:(UIButton*)sender{
    [self resignFields];
    [self setCurrentState:(self.currentState == LoginStateLogin) ? LoginStateSignup : LoginStateLogin];
}

-(void)pressedFacebook:(UIButton*)sender{
    [self showIndicator:YES onElement:sender];
    
    [PFFacebookUtils logInWithPermissions:@[@"email"] block:^(PFUser *user, NSError *error) {
        [self showIndicator:NO onElement:sender];
        if(error){
            if([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"code"] integerValue] == 190){
                if([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"error_subcode"] integerValue] == 458){
                    [self pressedFacebook:sender];
                    return;
                }
            }
            if(error.code == 2){
                [UTILITY alertWithTitle:NSLocalizedString(@"Facebook settings", nil) andMessage:NSLocalizedString(@"Please make sure you've allowed Swipes in Settings -> Facebook", nil)];
            }
            else{
                [self handleErrorFromLogin:error];
            }
            [PFUser logOut]; // new code, try to actively logout in order to detach FB from Parse
        }
        else{
            [self.delegate loginViewController:self didLoginUser:user];
        }
    }];
}
-(BOOL)pressedContinue:(UIButton*)sender{
    if (self.currentState == LoginStateWelcome) {
        [self setCurrentState:LoginStateSignup animated:NO];
        return YES;
    }
    if (self.emailField.isFirstResponder && self.passwordField.text.length == 0)
        [self.passwordField becomeFirstResponder];
    else{
        self.emailField.text = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(![self areValidFields]) {
            [self resignFields];
            [self validateFields];
            return NO;
        }
        [self showIndicator:YES onElement:sender];
        NSString *email = [self.emailField.text lowercaseString];
        [PFCloud callFunctionInBackground:@"checkEmail" withParameters:@{@"email":email} block:^(id object, NSError *error) {
            if(error){
                [self showIndicator:NO onElement:sender];
                [self handleErrorFromLogin:error];
            }
            else if([object isEqualToNumber:@1]){
                [PFUser logInWithUsernameInBackground:email password:self.passwordField.text block:^(PFUser *user, NSError *error) {
                    [self showIndicator:NO onElement:sender];
                    if (error) {
                        [self handleErrorFromLogin:error];
                    } else {
                        [self resignFields];
                        [self.delegate loginViewController:self didLoginUser:user];
                    }
                }];
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
                            [self resignFields];
                            [self.delegate loginViewController:self didLoginUser:user];
                        } else {
                            [self handleErrorFromLogin:error];
                        }
                    }];
                };
                NSString *title = NSLocalizedString(@"New user", nil);
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Do you want to sign up with: %@", nil),email];
                [UTILITY confirmBoxWithTitle:title andMessage:message block:^(BOOL succeeded, NSError *error) {
                    if(succeeded){
                        signUpBlock();
                    }
                    else
                        [self showIndicator:NO onElement:sender];
                }];
            }
        }];
    }
    return YES;
}
-(void)pressedTryButton:(UIButton*)sender{
    [ROOT_CONTROLLER tryoutapp];
}
-(void)pressedForgot:(UIButton*)sender{
    DLog(@"for: %@",self.emailField.text);
    [UTILITY inputAlertWithTitle:NSLocalizedString(@"Reset password", nil) message:nil pretext:self.emailField.text placeholder:[NSLocalizedString(@"email", nil) capitalizedString] cancel:[NSLocalizedString(@"cancel", nil) capitalizedString] confirm:[NSLocalizedString(@"reset", nil) capitalizedString] block:^(NSString *string, NSError *error) {
        if(string.length == 0)
            return;
        [self showIndicator:YES onElement:self.forgotButton];
        [PFUser requestPasswordResetForEmailInBackground:[string lowercaseString] block:^(BOOL succeeded, NSError *error) {
            [self showIndicator:NO onElement:self.forgotButton];
            if(succeeded){
                [UTILITY alertWithTitle:NSLocalizedString(@"Email sent", nil) andMessage:NSLocalizedString(@"Follow the instructions in the email to reset your pass", nil)];
            }
            else{
                [self handleErrorFromLogin:error];
                
            }
        }];
    }];
}
-(void)pressedPrivacy:(UIButton*)sender{
    [UTILITY confirmBoxWithTitle:NSLocalizedString(@"Policies", nil) andMessage:NSLocalizedString(@"Read through our 'Privacy Policy' and 'Terms and Conditions'.", nil) block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://swipesapp.com/policies.pdf"]];
        }
    }];
}
-(void)keyboardWillShow{
    self.continueButton.hidden = NO;
    self.backButton.hidden = YES;
    self.passwordField.hidden = NO;
    self.facebookButton.hidden = YES;
    self.logoView.hidden = YES;
    self.facebookLabel.hidden = YES;
    [UIView animateWithDuration:0.25f animations:^{
        CGRectSetY(self.view, -kScrollupButtonsVal);
    }];
}
-(void)keyboardWillHide{
    self.logoView.hidden = NO;
    self.continueButton.hidden = YES;
    self.backButton.hidden = NO;
    self.facebookButton.hidden = NO;
    if(self.currentState != LoginStateLogin)
        self.passwordField.hidden = YES;
    self.facebookLabel.hidden = NO;
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
    if (relativeStart < 30)
        relativeStart = 20;

    CGRectSetY(self.logoView, relativeStart );
    CGRectSetY(self.titleView, CGRectGetMaxY(self.logoView.frame) + 50);
    CGFloat fieldHeight = LOGIN_FIELDS_HEIGHT/2;

    CGRectSetY(self.emailField, LOGIN_FIELDS_Y+(fieldHeight-self.emailField.frame.size.height)/2+relativeStart);
    CGRectSetY(self.passwordField, LOGIN_FIELDS_Y+(LOGIN_FIELDS_HEIGHT/2)+(fieldHeight-self.passwordField.frame.size.height)/2+relativeStart);
    CGRectSetY(self.loginOrSignupLabel, self.emailField.frame.origin.y-BUTTON_LABEL_SUBTRACTION);
    CGRectSetX(self.forgotButton, CGRectGetMaxX(self.passwordField.frame)-self.forgotButton.frame.size.width);
    CGRectSetY(self.forgotButton, CGRectGetMaxY(self.passwordField.frame) + kLabelAddition);
    NSInteger loginY = (self.currentState == LoginStateLogin) ? LOGIN_BUTTON_Y + kContinueButtonJump : LOGIN_BUTTON_Y;
    if(self.currentState == LoginStateWelcome){
        CGFloat titleMaxY = CGRectGetMaxY(self.titleView.frame);
        //CGFloat remainingSpace = self.view.frame.size.height - titleMaxY - 10*kExtraBottomSpacing;
        //CGFloat spacingBetween = 30;
        CGFloat firstY = titleMaxY + 50;
        CGRectSetY(self.continueButton, firstY);
        //CGRectSetY(self.tryButton,CGRectGetMaxY(self.continueButton.frame) + spacingBetween);
    }
    else CGRectSetY(self.continueButton, loginY+relativeStart);
    
    if(self.currentState == LoginStateLogin){
        CGRectSetY(self.facebookButton,FACEBOOK_BUTTON_Y+relativeStart);
    }
    else
        CGRectSetY(self.facebookButton, CGRectGetMaxY(self.emailField.frame) + 60);
    CGRectSetY(self.facebookLabel,self.facebookButton.frame.origin.y-BUTTON_LABEL_SUBTRACTION);
    
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
    [ANALYTICS pushView:@"Login"];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.backgroundImage stopAnimating];
    self.backgroundImage.animationImages = nil;
    // Dispose of any resources that can be recreated.
}

@end
