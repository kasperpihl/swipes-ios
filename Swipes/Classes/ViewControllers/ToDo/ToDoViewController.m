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
#define STATUS_CELL_TAG 6
#define TAGS_LABEL_TAG 7
#define TAGS_CONTAINER_TAG 8

#define TOP_VIEW_MARGIN 60

#define LABEL_X 50

#define TITLE_HEIGHT 44
#define TITLE_TOP_MARGIN 7
#define TITLE_X 6
#define TITLE_WIDTH (320-2*TITLE_X)
#define TITLE_BOTTOM_MARGIN (TITLE_TOP_MARGIN+COLOR_SEPERATOR_HEIGHT)
#define CONTAINER_INIT_HEIGHT (TITLE_HEIGHT + TITLE_TOP_MARGIN + TITLE_BOTTOM_MARGIN)
#define TAGS_LABEL_PADDING 10
#define TAGS_LABEL_RECT CGRectMake(LABEL_X,TAGS_LABEL_PADDING,320-LABEL_X-10,500)


#import "UIViewController+KNSemiModal.h"
#import "KPAddTagPanel.h"
#import "TagHandler.h"
#import "ToDoViewController.h"
#import "HPGrowingTextView.h"
#import "ToDoHandler.h"
#import "ToDoStatusCell.h"
#import "SchedulePopup.h"
@interface ToDoViewController () <HPGrowingTextViewDelegate,MCSwipeTableViewCellDelegate,KPAddTagDelegate,KPTagDelegate>

@property (nonatomic,weak) IBOutlet HPGrowingTextView *editTitleTextView;
@property (nonatomic,weak) IBOutlet ToDoStatusCell *statusCell;
@property (nonatomic,weak) IBOutlet UIView *titleContainerView;
@property (nonatomic,weak) IBOutlet UIView *tagsContainerView;
@property (nonatomic,weak) IBOutlet UILabel *tagsLabel;
@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet UIView *containerRestView;
@property (nonatomic,weak) IBOutlet UITextView *notesView;
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
        
        ToDoStatusCell *cell = [[ToDoStatusCell alloc] initWithFrame:CGRectMake(0, 200, 320, STATUS_CELL_HEIGHT)];
        cell.delegate = self;
        CGRectSetY(cell, 200);
        cell.tag = STATUS_CELL_TAG;
        CGRectSetHeight(cell, STATUS_CELL_HEIGHT);
        [self.view addSubview:cell];
        self.statusCell = (ToDoStatusCell*)[self.view viewWithTag:STATUS_CELL_TAG];
        
        UIView *tagsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 250, 320, 40)];
        tagsContainer.tag = TAGS_CONTAINER_TAG;
        
        UIImageView *tagsImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tagbutton"]];
        tagsImage.frame = CGRectSetPos(tagsImage.frame, (LABEL_X-tagsImage.frame.size.width)/2, (tagsContainer.frame.size.height-tagsImage.frame.size.height)/2);
        tagsImage.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
        [tagsContainer addSubview:tagsImage];
        
        UILabel *tagsLabel = [[UILabel alloc] initWithFrame:TAGS_LABEL_RECT];
        tagsLabel.tag = TAGS_LABEL_TAG;
        tagsLabel.numberOfLines = 0;
        tagsLabel.font = TEXT_FIELD_FONT;
        tagsLabel.backgroundColor = [UIColor clearColor];
        tagsLabel.textColor = CELL_TAG_COLOR;
        [tagsContainer addSubview:tagsLabel];
        self.tagsLabel = (UILabel*)[tagsContainer viewWithTag:TAGS_LABEL_TAG];
        
        UIButton *tagsButton = [[UIButton alloc] initWithFrame:tagsContainer.bounds];
        tagsButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
        [tagsButton addTarget:self action:@selector(pressedTags:) forControlEvents:UIControlEventTouchUpInside];
        [tagsContainer addSubview:tagsButton];
        
        [self.view addSubview:tagsContainer];
        self.tagsContainerView = [self.view viewWithTag:TAGS_CONTAINER_TAG];
    }
    return self;
}
#pragma mark - KPAddTagDelegate
-(void)closeTagPanel:(KPAddTagPanel *)tagPanel{
    [self dismissSemiModalView];
}
-(void)tagPanel:(KPAddTagPanel *)tagPanel createdTag:(NSString *)tag{
    [TAGHANDLER addTag:tag];
}
-(void)tagPanel:(KPAddTagPanel *)tagPanel changedSize:(CGSize)size{
    NSLog(@"resized");
    [self resizeSemiView:size animated:NO];
}

#pragma mark - KPTagDelegate
-(NSArray *)selectedTagsForTagList:(KPTagList *)tagList{
    NSArray *selectedTags = [TAGHANDLER selectedTagsForToDos:@[self.model]];
    return selectedTags;
}
-(NSArray *)tagsForTagList:(KPTagList *)tagList{
    NSArray *allTags = [TAGHANDLER allTags];
    return allTags;
}
-(void)tagList:(KPTagList *)tagList selectedTag:(NSString *)tag{
    [TAGHANDLER updateTags:@[tag] remove:NO toDos:@[self.model]];
    [self updateBackground];
}
-(void)tagList:(KPTagList *)tagList deselectedTag:(NSString *)tag{
    [TAGHANDLER updateTags:@[tag] remove:YES toDos:@[self.model]];
    [self updateBackground];
}
-(void)pressedTags:(id)sender{
    KPAddTagPanel *tagView = [[KPAddTagPanel alloc] initWithFrame:CGRectMake(0, 0, 320, 450) andTags:[TAGHANDLER allTags] andMaxHeight:320];
    tagView.delegate = self;
    tagView.tagView.tagDelegate = self;
    [self presentSemiView:tagView withOptions:@{KNSemiModalOptionKeys.animationDuration:@0.25f,KNSemiModalOptionKeys.shadowOpacity:@0.0f} completion:^{
        [tagView scrollIfNessecary];
    }];
}
-(void)swipeTableViewCell:(ToDoStatusCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode{
    CellType targetCellType = [TODOHANDLER cellTypeForCell:[self.model cellTypeForTodo] state:state];
    NSArray *toDosArray = @[self.model];
    switch (targetCellType) {
        case CellTypeSchedule:{
            [SchedulePopup showInView:self.view withBlock:^(KPScheduleButtons button, NSDate *date) {
                if(button == KPScheduleButtonCancel){
                }
                else{
                    [TODOHANDLER scheduleToDos:toDosArray forDate:date];
                    [self updateCell];
                }
            }];
            return;
        }
        case CellTypeToday:
            [TODOHANDLER scheduleToDos:toDosArray forDate:[NSDate date]];
            break;
        case CellTypeDone:
            [TODOHANDLER completeToDos:toDosArray];
            break;
        case CellTypeNone:
            return;
    }
    [self updateCell];
}
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    [growingTextView resignFirstResponder];
    return NO;
}
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height{
    CGFloat titleHeight = height+TITLE_TOP_MARGIN+TITLE_BOTTOM_MARGIN;
    CGRectSetHeight(self.titleContainerView,titleHeight);
    CGRectSetY(self.statusCell, titleHeight);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
}
-(void)updateCell{
    self.statusCell.cellType = [self.model cellTypeForTodo];
    [self.statusCell setTitleString:[self.model readableTitleForStatus]];
}
-(void)updateTags{
    self.tagsLabel.frame = TAGS_LABEL_RECT;
    NSString *tagsString = [self.model stringifyTags];
    if(!tagsString || tagsString.length == 0) tagsString = @"No Tags";
    self.tagsLabel.text = [NSString stringWithFormat:@"%@, %@, %@, %@, %@",tagsString,tagsString,tagsString,tagsString,tagsString];
    [self.tagsLabel sizeToFit];

    CGFloat containerHeight = self.tagsLabel.frame.size.height + 2*TAGS_LABEL_PADDING;
    CGRectSetHeight(self.tagsContainerView, containerHeight);
}
-(void)setModel:(KPToDo *)model{
    if(_model != model){
        _model = model;
        self.editTitleTextView.text = model.title;
        [self updateCell];
        [self updateTags];
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
