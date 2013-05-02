//
//  ToDoViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ToDoViewController.h"

@interface ToDoViewController ()
@property (nonatomic,weak) IBOutlet UITextField *editTitleTextField;
@property (nonatomic,weak) IBOutlet UITextView *notesView;
@end

@implementation ToDoViewController

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
