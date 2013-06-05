//
//  SignupViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "SignupViewController.h"

@interface SignupViewController ()

@end

@implementation SignupViewController
-(id)init{
    self = [super init];
    if(self){
        self.fields = (PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsDismissButton | PFSignUpFieldsSignUpButton);
        self.signUpView.usernameField.placeholder = @"Email";
        //[self.signUpView setBackgroundColor:TABLE_CELL_BACKGROUND];
        [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logo.png"]]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
