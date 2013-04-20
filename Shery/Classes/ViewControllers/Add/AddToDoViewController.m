//
//  AddToDoViewController.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 20/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "AddToDoViewController.h"

@interface AddToDoViewController ()

@end

@implementation AddToDoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
    backgroundView.backgroundColor = [UIColor whiteColor];
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 280, 44)];
    [backgroundView addSubview:textField];
    [self.view addSubview:backgroundView];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
