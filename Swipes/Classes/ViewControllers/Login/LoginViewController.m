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
@interface LoginViewController ()
@end

@implementation LoginViewController
-(id)init{
    self = [super init];
    if(self){
        
        self.fields = (PFLogInFieldsUsernameAndPassword | PFLogInFieldsFacebook | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsPasswordForgotten);
        self.facebookPermissions = @[@"email"];
        self.logInView.usernameField.placeholder = @"Email";
        
        [self setupButton:self.logInView.logInButton];
        [self.logInView.logInButton setBackgroundImage:[UtilityClass imageWithColor:color(58,67,79,1)] forState:UIControlStateNormal];
        NSLog(@"%@",self.logInView.passwordForgottenButton);
        
        [self setupButton:self.logInView.facebookButton];
        [self.logInView.facebookButton setBackgroundImage:[UtilityClass imageWithColor:color(57,159,219,1)] forState:UIControlStateNormal];
        [self.logInView.facebookButton setTitle:@"FACEBOOK" forState:UIControlStateNormal];
        
        [self setupButton:self.logInView.signUpButton];
        [self.logInView.signUpButton setBackgroundImage:[UtilityClass imageWithColor:color(63,186,141,1)] forState:UIControlStateNormal];
        [self.logInView.signUpButton setTitle:@"SIGN UP" forState:UIControlStateNormal];
        
        
        self.logInView.usernameField.returnKeyType = UIReturnKeyNext;
        //[self.logInView setBackgroundColor:TABLE_CELL_BACKGROUND];
        
        

    
        [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logo.png"]]];
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.logInView.logInButton.hidden = YES;
    [self.logInView.logInButton setTitle:@"LOG IN" forState:UIControlStateNormal];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
