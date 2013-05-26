//
//  ToDoViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define TITLE_TEXT_FIELD_TAG 1
#define NOTES_TEXT_VIEW_TAG 2
#define EDIT_BUTTON_TAG 3
#define DONE_BUTTON_TAG 4

#import "UIViewController+KNSemiModal.h"
#import "ToDoViewController.h"
#import "ToDoHandler.h"
@interface ToDoViewController ()
@property (nonatomic,weak) IBOutlet UITextField *editTitleTextField;
@property (nonatomic,weak) IBOutlet UITextView *notesView;
@property (nonatomic,weak) IBOutlet UIButton *editButton;
@property (nonatomic,weak) IBOutlet UIButton *doneButton;
@property (nonatomic,weak) IBOutlet UILabel *tagLabel;

@end

@implementation ToDoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    /* Top Bar Section */
    CGFloat buttonY = 0;
    CGFloat buttonWidth = self.view.frame.size.width;
    /*UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.titleLabel.font = BUTTON_FONT;
    editButton.frame = CGRectMake(0, buttonY , buttonWidth , BUTTON_HEIGHT);
    [editButton addTarget:self action:@selector(pressedEdit:) forControlEvents:UIControlEventTouchUpInside];
    [editButton setTitle:@"SAVE" forState:UIControlStateNormal];
    [self.view addSubview:editButton];*/
    
    /*UIView *buttonSpecificSeperator = [[UIView alloc] initWithFrame:CGRectMake(buttonWidth-SEPERATOR_WIDTH/2, buttonY, SEPERATOR_WIDTH, BUTTON_HEIGHT)];
    buttonSpecificSeperator.backgroundColor = SEGMENT_SELECTED;
    [self.view addSubview:buttonSpecificSeperator];*/
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.titleLabel.font = BUTTON_FONT;
    doneButton.frame = CGRectMake(0, buttonY,buttonWidth , BUTTON_HEIGHT);
    [doneButton setTitle:@"DONE" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(pressedDone:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneButton];
    
    UIView *colorBottomSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, BUTTON_HEIGHT, self.view.frame.size.width, COLOR_SEPERATOR_HEIGHT)];
    colorBottomSeperator.backgroundColor = SWIPES_COLOR;
    [self.view addSubview:colorBottomSeperator];
    self.view.backgroundColor = EDIT_TASK_BACKGROUND;
    
    /* Edit title section */
    UITextField *editTitleTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, BUTTON_HEIGHT+15, self.view.frame.size.width, TEXT_FIELD_HEIGHT)];
    editTitleTextField.tag = TITLE_TEXT_FIELD_TAG;
    editTitleTextField.text = @"Testing";
    editTitleTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:editTitleTextField];
    self.editTitleTextField = (UITextField*)[self.view viewWithTag:TITLE_TEXT_FIELD_TAG];
    
    
        
	// Do any additional setup after loading the view.
}
-(void)setModel:(KPToDo *)model{
    if(_model != model){
        _model = model;
    }
}
-(void)layout{
    
}
-(void)pressedDone:(id)sender{
    [self dismissSemiModalView];
}
-(void)pressedEdit:(id)sender{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
