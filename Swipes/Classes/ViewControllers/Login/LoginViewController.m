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
#import "MYIntroductionView.h"

#define SIGNUP_INDICATOR_TAG 15530

#define LOGIN_FIELDS_CORNER_RADIUS 5
#define LOGIN_FIELDS_WIDTH FIELDS_WIDTH
#define LOGIN_FIELDS_HEIGHT 120
#define LOGIN_FIELDS_SEPERATOR_WIDTH 194


#define LOGIN_BUTTON_Y     (10      +LOGIN_FIELDS_Y+LOGIN_FIELDS_HEIGHT)
#define FACEBOOK_BUTTON_Y  (40      +(LOGIN_BUTTON_Y+SIGNUP_BUTTONS_HEIGHT))
#define SIGNUP_BUTTON_Y    (40      +(FACEBOOK_BUTTON_Y+SIGNUP_BUTTONS_HEIGHT))
#define BUTTON_LABEL_SUBTRACTION 17


@interface LoginViewController () < PFSignUpViewControllerDelegate,MYIntroductionDelegate>
@property (nonatomic,strong) IBOutlet UIView *fieldsBackground;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *signupIndicator;
@end

@implementation LoginViewController
-(id)init{
    self = [super init];
    if(self){
        SignupViewController *signupVC = [[SignupViewController alloc] init];
        signupVC.delegate = self;
        self.signUpController = signupVC;
        self.fields = (PFLogInFieldsUsernameAndPassword | PFLogInFieldsFacebook | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsPasswordForgotten | PFLogInFieldsDismissButton);
        self.facebookPermissions = @[@"email"];
        [self.logInView.dismissButton setImage:[UIImage imageNamed:@"cross_button"] forState:UIControlStateNormal];
        [self.logInView.dismissButton setImage:nil forState:UIControlStateHighlighted];
        self.logInView.dismissButton.adjustsImageWhenHighlighted = true;
        self.logInView.dismissButton.hidden = YES;
        [self.logInView setBackgroundColor:LOGIN_BACKGROUND];
        
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
        [self.logInView.passwordForgottenButton setTitleColor:LOGIN_FIELDS_BACKGROUND forState:UIControlStateNormal];
        CGRectSetWidth(self.logInView.passwordForgottenButton, [@"forgot password?" sizeWithFont:LOGIN_FIELDS_FONT].width+20);
        [self.logInView.signUpButton removeTarget:nil
                           action:NULL
                 forControlEvents:UIControlEventAllEvents];
        [self.logInView.signUpButton addTarget:self action:@selector(pressedSignUp:) forControlEvents:UIControlEventTouchUpInside];
        [self.logInView.dismissButton addTarget:self action:@selector(pressedDismiss:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
-(void)pressedDismiss:(UIButton*)sender{
    [self switchToSignup:NO animated:YES];
}
-(void)pressedSignUp:(UIButton*)sender{
    [self switchToSignup:YES animated:YES];
}
-(void)switchToSignup:(BOOL)signup animated:(BOOL)animated{
    voidBlock block;
    voidBlock completion;
    if(signup){
        self.logInView.signUpButton.hidden = YES;
        self.logInView.usernameField.hidden = YES;
        self.logInView.passwordField.hidden = YES;
        self.signUpController.signUpView.usernameField.frame = self.logInView.usernameField.frame;
        self.signUpController.signUpView.passwordField.frame = self.logInView.passwordField.frame;
        [self.logInView insertSubview:self.signUpController.signUpView.usernameField atIndex:2];
        [self.logInView insertSubview:self.signUpController.signUpView.passwordField atIndex:2];
        self.signUpController.signUpView.signUpButton.frame = self.logInView.signUpButton.frame;
        [self.logInView insertSubview:self.signUpController.signUpView.signUpButton atIndex:3];
        [self.signUpController.signUpView.usernameField becomeFirstResponder];
        self.logInView.dismissButton.alpha = 0;
        self.logInView.dismissButton.hidden = NO;
        block = ^{
            self.logInView.externalLogInLabel.alpha = 0;
            self.logInView.facebookButton.alpha = 0;
            self.logInView.logInButton.alpha = 0;
            self.logInView.signUpLabel.alpha = 0;
            self.logInView.passwordForgottenButton.alpha = 0;
            self.logInView.dismissButton.alpha = 1;
            self.signUpController.signUpView.signUpButton.frame = self.logInView.logInButton.frame;
        };
    }
    else{
        self.logInView.usernameField.hidden = NO;
        self.logInView.passwordField.hidden = NO;
        if([self.signUpController.signUpView.usernameField isFirstResponder]) [self.signUpController.signUpView.usernameField resignFirstResponder];
        else if([self.signUpController.signUpView.passwordField isFirstResponder]) [self.signUpController.signUpView.passwordField resignFirstResponder];
        [self.signUpController.signUpView.usernameField removeFromSuperview];
        [self.signUpController.signUpView.passwordField removeFromSuperview];
        block = ^{
            self.logInView.externalLogInLabel.alpha = 1;
            self.logInView.facebookButton.alpha = 1;
            self.logInView.logInButton.alpha = 1;
            self.logInView.signUpLabel.alpha = 1;
            self.logInView.passwordForgottenButton.alpha = 1;
            self.logInView.dismissButton.alpha = 0;
            self.signUpController.signUpView.signUpButton.frame = self.logInView.signUpButton.frame;
        };
        completion = ^{
            self.logInView.signUpButton.hidden = NO;
            [self.signUpController.signUpView.signUpButton removeFromSuperview];
        };
    }
    
    
    [UIView animateWithDuration:0.25f animations:block completion:^(BOOL finished) {
        if(finished && completion){
            completion();
        }
    }];
}
-(void)walkthrough{
    //STEP 1 Construct Panels
    MYIntroductionPanel *panel = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"walkthrough1"] title:@"Menu" description:@"Welcome to your powerful Menu bar! Here everything has its place. Plan and focus on your tasks today, complete them or schedule them for later."];
    
    //You may also add in a title for each panel
    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"walkthrough2"] title:@"Schedule" description:@"This is your favorite schedule! Simply swipe your tasks to the left and set them up for later. You will get reminded, when the time’s right."];
    
    MYIntroductionPanel *panel3 = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"walkthrough3"] title:@"Get started" description:@"Start swiping now. Plan your day and enjoy a productive flow!"];
    
    
    //STEP 2 Create IntroductionView
    
    /*A standard version*/
    //MYIntroductionView *introductionView = [[MYIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) headerImage:[UIImage imageNamed:@"SampleHeaderImage.png"] panels:@[panel, panel2]];
    
    
    /*A version with no header (ala "Path")*/
    //MYIntroductionView *introductionView = [[MYIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) panels:@[panel, panel2]];
    
    /*A more customized version*/
    MYIntroductionView *introductionView = [[MYIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) panels:@[panel, panel2, panel3]];
    [introductionView setBackgroundImage:[UtilityClass imageWithColor:LOGIN_BACKGROUND]];
    
    
    //Set delegate to self for callbacks (optional)
    introductionView.delegate = self;
    
    //STEP 3: Show introduction view
    [introductionView showInView:self.view];
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
        indicatorView.center = self.signUpController.signUpView.signUpButton.center;
        [self.logInView insertSubview:indicatorView atIndex:3];
    
        self.signupIndicator = (UIActivityIndicatorView*)[self.logInView viewWithTag:SIGNUP_INDICATOR_TAG];
        [self.signupIndicator startAnimating];
        self.signUpController.signUpView.signUpButton.hidden = YES;
    }
    else{
        [self.signupIndicator removeFromSuperview];
        self.signUpController.signUpView.signUpButton.hidden = NO;
    }
}
// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self showIndicator:NO];
    [self.delegate logInViewController:self didLogInUser:user];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    [self.signUpController.signUpView.usernameField becomeFirstResponder];
    [self showIndicator:NO];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat relativeStart = (self.logInView.frame.size.height-(SIGNUP_BUTTON_Y+SIGNUP_BUTTONS_HEIGHT))/2;
    if(relativeStart < 30) relativeStart = 5;
    CGFloat viewWidth = self.logInView.frame.size.width;
    [self.logInView.logInButton setTitle:@"LOG IN" forState:UIControlStateNormal];
    [self.logInView.logInButton setTitle:@"LOG IN" forState:UIControlStateHighlighted];
    self.logInView.dismissButton.frame = CGRectMake(0, 0, 44, 44);
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
    [self walkthrough];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
