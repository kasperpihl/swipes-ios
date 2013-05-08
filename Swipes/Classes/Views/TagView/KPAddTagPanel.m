//
//  KPTagView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPAddTagPanel.h"
#import "UtilityClass.h"
#define BACKGROUND_VIEW_TAG 2
#define TAG_VIEW_TAG 3
#define TAB_BAR_VIEW_TAG 4
#define TEXT_FIELD_TAG 5
#define SCROLL_VIEW_TAG 6
#define TAG_CONTAINER_VIEW_TAG 7
#define ADD_VIEW_TAG 8
#define DONE_EDITING_BUTTON_TAG 9


#define ANIMATION_DURATION 0.25f


#define ADD_BACKGROUND_COLOR [UtilityClass colorWithRed:70 green:70 blue:70 alpha:1]

#define SEPERATOR_WIDTH 1

#define TAB_BAR_VIEW_HEIGHT 50


#define KEYBOARD_HEIGHT 216

#define NUMBER_OF_BAR_BUTTONS 2

@interface KPAddTagPanel () <UITextFieldDelegate,KPTagListResizeDelegate>
@property (nonatomic,weak) IBOutlet UIView *addTagView;
@property (nonatomic,weak) IBOutlet UIView *tagContainerView;
@property (nonatomic,weak) IBOutlet UIView *barBottomView;
@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet UIButton *doneEditingButton;
@property (nonatomic) NSInteger maxHeight;
@property (nonatomic) BOOL isRotated;
@end
@implementation KPAddTagPanel
+(KPAddTagPanel*)tagPanelWithTags:(NSArray*)tags maxHeight:(NSInteger)maxHeight{
    KPAddTagPanel *tagPanel = [[KPAddTagPanel alloc] initWithFrame:CGRectMake(0, 0, 320, maxHeight) andTags:tags andMaxHeight:maxHeight];
    
    return tagPanel;
}
-(IBAction)rotateButton
{
    NSLog( @"Rotating button" );
    
    [UIView beginAnimations:@"rotate" context:nil];
    [UIView setAnimationDuration:.25f];
    if( CGAffineTransformEqualToTransform( self.doneEditingButton.imageView.transform, CGAffineTransformIdentity ) )
    {
        self.doneEditingButton.imageView.transform = CGAffineTransformMakeRotation(3*M_PI/2);
    } else {
        self.doneEditingButton.imageView.transform = CGAffineTransformIdentity;
    }
    [UIView commitAnimations];
}
- (id)initWithFrame:(CGRect)frame andTags:(NSArray*)tags andMaxHeight:(NSInteger)maxHeight
{
    self = [super initWithFrame:frame];
    if (self) {
        self.maxHeight = maxHeight;
        /* Initialize taglistview + scrolling */
        UIView *tagContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-TAB_BAR_VIEW_HEIGHT)];
        tagContainerView.tag = TAG_CONTAINER_VIEW_TAG;
        UIView *tagContainerColorSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tagContainerView.frame.size.width, COLOR_SEPERATOR_HEIGHT)];
        tagContainerColorSeperator.backgroundColor = BAR_BOTTOM_BACKGROUND_COLOR;
        [tagContainerView addSubview:tagContainerColorSeperator];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, COLOR_SEPERATOR_HEIGHT, tagContainerView.frame.size.width, tagContainerView.frame.size.height-COLOR_SEPERATOR_HEIGHT)];
        scrollView.tag = SCROLL_VIEW_TAG;
        
        KPTagList *tagView = [KPTagList tagListWithWidth:self.frame.size.width andTags:tags];
        tagView.marginLeft = 0;
        tagView.marginRight = 0;
        tagView.emptyText = @"No tags";
        CGRectSetY(tagView.frame, 0);
        tagView.resizeDelegate = self;
        tagView.tag = TAG_VIEW_TAG;
        [scrollView addSubview:tagView];
        self.tagView = (KPTagList*)[scrollView viewWithTag:TAG_VIEW_TAG];
        //CGRectSetSize(self.frame, self.frame.size.width, self.tagView.frame.size.height+ADD_VIEW_HEIGHT);//
        scrollView.contentSize = CGSizeMake(tagView.frame.size.width, tagView.frame.size.height);
        scrollView.scrollEnabled = YES;
        [tagContainerView addSubview:scrollView];
        [self addSubview:tagContainerView];
        self.tagContainerView = [self viewWithTag:TAG_CONTAINER_VIEW_TAG];
        self.scrollView = (UIScrollView*)[self viewWithTag:SCROLL_VIEW_TAG];
        self.scrollView.backgroundColor = [UIColor blackColor];
        [self tagList:self.tagView changedSize:CGSizeMake(self.frame.size.width, self.tagView.frame.size.height)];
        CGRectSetSize(self.frame, self.frame.size.width, self.tagContainerView.frame.origin.y+self.tagContainerView.frame.size.height+TAB_BAR_VIEW_HEIGHT);
        
        
        
        /* Initialize tagbar view */
        UIView *tagBarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-TAB_BAR_VIEW_HEIGHT, self.frame.size.width, TAB_BAR_VIEW_HEIGHT)];
        tagBarView.backgroundColor = BAR_BOTTOM_BACKGROUND_COLOR;
        tagBarView.tag = TAB_BAR_VIEW_TAG;
        UIView *tagBarColorSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tagBarView.frame.size.width, COLOR_SEPERATOR_HEIGHT)];
        tagBarColorSeperator.backgroundColor = SWIPES_BLUE;
        [tagBarView addSubview:tagBarColorSeperator];
        
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addButton.frame = CGRectMake(0, COLOR_SEPERATOR_HEIGHT, tagBarView.frame.size.width/NUMBER_OF_BAR_BUTTONS, TAB_BAR_VIEW_HEIGHT-COLOR_SEPERATOR_HEIGHT);
        addButton.titleLabel.font = BUTTON_FONT;
        [addButton addTarget:self action:@selector(pressedAddButton:) forControlEvents:UIControlEventTouchUpInside];
        addButton.titleLabel.textColor = BUTTON_COLOR;
        [addButton setTitle:@"ADD" forState:UIControlStateNormal];
        [tagBarView addSubview:addButton];
        
        /*UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        editButton.frame = CGRectMake(tagBarView.frame.size.width/NUMBER_OF_BAR_BUTTONS*1, COLOR_SEPERATOR_HEIGHT, tagBarView.frame.size.width/NUMBER_OF_BAR_BUTTONS, TAB_BAR_VIEW_HEIGHT-COLOR_SEPERATOR_HEIGHT);
        editButton.titleLabel.font = BAR_BOTTON_BUTTON_FONT;
        editButton.titleLabel.textColor = [UIColor whiteColor];
        [editButton setTitle:@"EDIT" forState:UIControlStateNormal];
        [tagBarView addSubview:editButton];*/
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.frame = CGRectMake(tagBarView.frame.size.width/NUMBER_OF_BAR_BUTTONS*1, COLOR_SEPERATOR_HEIGHT, tagBarView.frame.size.width/NUMBER_OF_BAR_BUTTONS, TAB_BAR_VIEW_HEIGHT-COLOR_SEPERATOR_HEIGHT);
        doneButton.titleLabel.font = BUTTON_FONT;
        doneButton.titleLabel.textColor = BUTTON_COLOR;
        [doneButton addTarget:self action:@selector(pressedDoneButton:) forControlEvents:UIControlEventTouchUpInside];
        [doneButton setTitle:@"DONE" forState:UIControlStateNormal];
        [tagBarView addSubview:doneButton];
        
        for(NSInteger i = 1 ; i < NUMBER_OF_BAR_BUTTONS ; i++){
            UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake((tagBarView.frame.size.width/NUMBER_OF_BAR_BUTTONS*i)-(SEPERATOR_WIDTH/2), COLOR_SEPERATOR_HEIGHT, SEPERATOR_WIDTH, tagBarView.frame.size.height-COLOR_SEPERATOR_HEIGHT)];
            seperator.backgroundColor = GRAY_SEPERATOR_COLOR;
            [tagBarView addSubview:seperator];
        }
        [self addSubview:tagBarView];
        self.barBottomView = [self viewWithTag:TAB_BAR_VIEW_TAG];
        
        
        
        
        
        /* Initialize addView */
        
        UIView *addView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, TEXT_FIELD_CONTAINER_HEIGHT)];
        addView.tag = ADD_VIEW_TAG;
        addView.backgroundColor = ADD_BACKGROUND_COLOR;
        UIView *addViewColorSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, addView.frame.size.height-COLOR_SEPERATOR_HEIGHT, addView.frame.size.width, COLOR_SEPERATOR_HEIGHT)];
        addViewColorSeperator.backgroundColor = SWIPES_BLUE;
        [addView addSubview:addViewColorSeperator];
        
        
        UIButton *doneEditingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat buttonSize = addView.frame.size.height-COLOR_SEPERATOR_HEIGHT;
        doneEditingButton.tag = DONE_EDITING_BUTTON_TAG;
        doneEditingButton.imageView.clipsToBounds = NO;
        doneEditingButton.imageView.contentMode = UIViewContentModeCenter;
        doneEditingButton.frame = CGRectMake(addView.frame.size.width-buttonSize, 0, buttonSize, buttonSize);
        [doneEditingButton setBackgroundImage:[UtilityClass imageWithColor:SWIPES_BLUE] forState:UIControlStateNormal];
        [doneEditingButton setImage:[UIImage imageNamed:@"hide_keyboard_arrow"] forState:UIControlStateNormal];
        [doneEditingButton addTarget:self action:@selector(pressedDoneEditing:) forControlEvents:UIControlEventTouchUpInside];
        [addView addSubview:doneEditingButton];
        self.doneEditingButton = (UIButton*)[addView viewWithTag:DONE_EDITING_BUTTON_TAG];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(TEXT_FIELD_MARGIN_LEFT, TEXT_FIELD_MARGIN_TOP, addView.frame.size.width-TEXT_FIELD_MARGIN_LEFT-buttonSize, TEXT_FIELD_HEIGHT)];
        textField.tag = TEXT_FIELD_TAG;
        textField.font = TEXT_FIELD_FONT;
        textField.textColor = [UIColor whiteColor];
        textField.returnKeyType = UIReturnKeyNext;
        textField.keyboardAppearance = UIKeyboardAppearanceAlert;
        textField.borderStyle = UITextBorderStyleNone;
        textField.delegate = self;
        textField.placeholder = @"Type the name of the tag";
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [addView addSubview:textField];
        self.textField = (UITextField*)[addView viewWithTag:TEXT_FIELD_TAG];
        
        
        [self addSubview:addView];
        self.addTagView = [self viewWithTag:ADD_VIEW_TAG];
        
        CGRectSetSize(self.frame, self.frame.size.width, self.barBottomView.frame.origin.y+self.barBottomView.frame.size.height);
    }
    return self;
}
-(void)scrollIfNessecary{
    //CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    //[self.scrollView setContentOffset:bottomOffset animated:YES];
}
-(void)pressedAddButton:(id)sender{
    [self shiftToAddMode:YES];
}
-(void)pressedDoneButton:(id)sender{
    [self.delegate closeTagPanel:self];
}
-(void)pressedDoneEditing:(id)sender{
    [self textFieldShouldReturn:self.textField];
    [self shiftToAddMode:NO];
}
-(void)tagList:(KPTagList *)tagList changedSize:(CGSize)size{
    self.scrollView.contentSize = size;
    CGFloat height = (size.height > self.maxHeight) ? self.maxHeight : size.height;
    CGRectSetSize(self.tagContainerView.frame, self.tagContainerView.frame.size.width, height+COLOR_SEPERATOR_HEIGHT);
    CGRectSetSize(self.scrollView.frame, self.scrollView.frame.size.width, height);
}

-(void)shiftToAddMode:(BOOL)addMode{
    if(addMode){
        [UIView animateWithDuration:0.2 animations:^{
            CGRectSetY(self.tagContainerView.frame, self.barBottomView.frame.origin.y);
            //self.barBottomView.hidden = YES;
        } completion:^(BOOL finished) {
            if(finished){
                self.tagContainerView.hidden = YES;
                CGFloat newHeight = KEYBOARD_HEIGHT + self.addTagView.frame.size.height;
                if([self.delegate respondsToSelector:@selector(tagPanel:changedSize:)]) [self.delegate tagPanel:self changedSize:CGSizeMake(self.frame.size.width,newHeight)];
                CGRectSetY(self.barBottomView.frame, self.frame.size.height-self.barBottomView.frame.size.height);
                CGRectSetY(self.addTagView.frame, self.frame.size.height);
                self.addTagView.hidden = NO;
                [self.textField becomeFirstResponder];
                [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                    CGRectSetY(self.addTagView.frame, 0);
                    
                    
                }];
            }
        }];
    }
    else{
        [self.textField resignFirstResponder];
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            CGRectSetY(self.addTagView.frame, self.frame.size.height);
        } completion:^(BOOL finished) {
            if(finished){
                self.addTagView.hidden = YES;
                
                self.tagContainerView.hidden = NO;
                CGPoint topOffset = CGPointMake(0, 0);
                [self.scrollView setContentOffset:topOffset animated:NO];
                CGFloat newHeight = self.tagContainerView.frame.size.height + self.barBottomView.frame.size.height;
                 if([self.delegate respondsToSelector:@selector(tagPanel:changedSize:)]) [self.delegate tagPanel:self changedSize:CGSizeMake(self.frame.size.width,newHeight)];
                
                CGRectSetY(self.barBottomView.frame, self.frame.size.height-self.barBottomView.frame.size.height);
                CGRectSetY(self.tagContainerView.frame, self.barBottomView.frame.origin.y);
                [UIView animateWithDuration:0.2 animations:^{
                    CGRectSetY(self.tagContainerView.frame, 0);
                    //CGRectSetY(self.addTagView.frame, 0);
                    
                    
                } completion:^(BOOL finished) {
                    [self scrollIfNessecary];
                }];
            }
        }];
    }
}
-(void)textFieldDidChange:(UITextField*)textField{
    NSString *string = textField.text;
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(trimmedString.length > 0){
        if(!self.isRotated){
            [self rotateButton];
            self.isRotated = YES;
        }
    }
    else{
        if(self.isRotated){
            [self rotateButton];
            self.isRotated = NO;
        }
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *string = textField.text;
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(trimmedString.length > 0){
                if(self.delegate && [self.delegate respondsToSelector:@selector(tagPanel:createdTag:)])
            [self.delegate tagPanel:self createdTag:trimmedString];
        [self.tagView addTag:trimmedString selected:YES];
        textField.text = @"";
        [self textFieldDidChange:self.textField];

        /*[textField resignFirstResponder];
        [self shiftToAddMode:NO];*/
        return YES;
        
    }
    return NO;
}


@end
