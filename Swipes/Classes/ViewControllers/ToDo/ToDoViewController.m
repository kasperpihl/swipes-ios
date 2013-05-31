//
//  ToDoViewController.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define TITLE_TEXT_VIEW_TAG 1
#define NOTES_TEXT_VIEW_TAG 2
#define EDIT_BUTTON_TAG 3
#define DONE_BUTTON_TAG 4
#define TITLE_CONTAINER_VIEW_TAG 5

#define TOP_VIEW_MARGIN 60

#define TITLE_HEIGHT 44
#define TITLE_TOP_MARGIN 3
#define TITLE_X 6
#define TITLE_WIDTH (320-2*TITLE_X)
#define TITLE_BOTTOM_MARGIN (TITLE_TOP_MARGIN+COLOR_SEPERATOR_HEIGHT)
#define CONTAINER_INIT_HEIGHT (TITLE_HEIGHT + TITLE_TOP_MARGIN + TITLE_BOTTOM_MARGIN)

#import "UIViewController+KNSemiModal.h"
#import "ToDoViewController.h"
#import "HPGrowingTextView.h"
#import "ToDoHandler.h"
#import "ToDoCell.h"
@interface ToDoViewController () <HPGrowingTextViewDelegate>
@property (nonatomic,weak) IBOutlet UITextView *notesView;
@property (nonatomic,weak) IBOutlet UIButton *editButton;
@property (nonatomic,weak) IBOutlet UIButton *doneButton;
@property (nonatomic,weak) IBOutlet UILabel *tagLabel;
@property (nonatomic,weak) IBOutlet HPGrowingTextView *editTitleTextView;
@property (nonatomic,weak) IBOutlet UIView *titleContainerView;
@end

@implementation ToDoViewController
-(id)init{
    self = [super init];
    if(self){
        self.view.backgroundColor = EDIT_TASK_BACKGROUND;
        
        UIView *titleContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CONTAINER_INIT_HEIGHT)];
        titleContainerView.tag = TITLE_CONTAINER_VIEW_TAG;
        //titleContainerView.backgroundColor = TEXTFIELD_BACKGROUND;
        

        CGFloat buttonWidth = BUTTON_HEIGHT;
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.frame = CGRectMake(titleContainerView.frame.size.width-buttonWidth,0,buttonWidth,CONTAINER_INIT_HEIGHT-COLOR_SEPERATOR_HEIGHT);
        doneButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [doneButton setImage:[UIImage imageNamed:@"cross_button"] forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(pressedDone:) forControlEvents:UIControlEventTouchUpInside];
        [titleContainerView addSubview:doneButton];
        
        
        CGRectSetHeight(self.view,self.view.frame.size.height-TOP_VIEW_MARGIN);
        HPGrowingTextView *textView;
        textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(TITLE_X, TITLE_TOP_MARGIN, TITLE_WIDTH-buttonWidth, TITLE_HEIGHT)];
        textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        textView.tag = TITLE_TEXT_VIEW_TAG;
        textView.minNumberOfLines = 1;
        textView.maxNumberOfLines = 6;
        textView.returnKeyType = UIReturnKeyDone; //just as an example
        textView.font = TEXT_FIELD_FONT;
        textView.delegate = self;
        textView.internalTextView.keyboardAppearance = UIKeyboardAppearanceAlert;
        textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        textView.backgroundColor = [UIColor clearColor];
        textView.textColor = TEXT_FIELD_COLOR;
        [titleContainerView addSubview:textView];
        self.editTitleTextView = (HPGrowingTextView*)[titleContainerView viewWithTag:TITLE_TEXT_VIEW_TAG];
        
        UIView *colorBottomSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, CONTAINER_INIT_HEIGHT-COLOR_SEPERATOR_HEIGHT, self.view.frame.size.width, COLOR_SEPERATOR_HEIGHT)];
        colorBottomSeperator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        colorBottomSeperator.backgroundColor = SWIPES_COLOR;
        [titleContainerView addSubview:colorBottomSeperator];
        
        
        [self.view addSubview:titleContainerView];
        self.titleContainerView = [self.view viewWithTag:TITLE_CONTAINER_VIEW_TAG];
        
        ToDoCell *cell = [[ToDoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.cellType = CellTypeToday;
        cell.frame = CGRectMake(0, 200, 320, CELL_HEIGHT);
        [self.view addSubview:cell];
        /* Top Bar Section */
        //CGFloat buttonY = 0;
        //CGFloat buttonWidth = self.view.frame.size.width;
        /*UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
         editButton.titleLabel.font = BUTTON_FONT;
         editButton.frame = CGRectMake(0, buttonY , buttonWidth , BUTTON_HEIGHT);
         [editButton addTarget:self action:@selector(pressedEdit:) forControlEvents:UIControlEventTouchUpInside];
         [editButton setTitle:@"SAVE" forState:UIControlStateNormal];
         [self.view addSubview:editButton];*/
        
        /*UIView *buttonSpecificSeperator = [[UIView alloc] initWithFrame:CGRectMake(buttonWidth-SEPERATOR_WIDTH/2, buttonY, SEPERATOR_WIDTH, BUTTON_HEIGHT)];
         buttonSpecificSeperator.backgroundColor = SEGMENT_SELECTED;
         [self.view addSubview:buttonSpecificSeperator];*/
        
        /*UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
         doneButton.titleLabel.font = BUTTON_FONT;
         doneButton.frame = CGRectMake(0, buttonY,buttonWidth , BUTTON_HEIGHT);
         [doneButton setTitle:@"DONE" forState:UIControlStateNormal];
         [doneButton addTarget:self action:@selector(pressedDone:) forControlEvents:UIControlEventTouchUpInside];
         [self.view addSubview:doneButton];*/
        
        
        
        /* Edit title section */
        /* UITextField *editTitleTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, BUTTON_HEIGHT+15, self.view.frame.size.width, TEXT_FIELD_HEIGHT)];
         editTitleTextField.tag = TITLE_TEXT_FIELD_TAG;
         editTitleTextField.text = @"Testing";
         editTitleTextField.borderStyle = UITextBorderStyleRoundedRect;
         [self.view addSubview:editTitleTextField];
         self.editTitleTextField = (UITextField*)[self.view viewWithTag:TITLE_TEXT_FIELD_TAG];*/
        
        
        
        // Do any additional setup after loading the view.
    }
    return self;
}
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    [growingTextView resignFirstResponder];
    return NO;
}
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height{
    CGRectSetHeight(self.titleContainerView,height+TITLE_TOP_MARGIN+TITLE_BOTTOM_MARGIN);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
}
-(void)setModel:(KPToDo *)model{
    if(_model != model){
        _model = model;
        self.editTitleTextView.text = model.title;
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
