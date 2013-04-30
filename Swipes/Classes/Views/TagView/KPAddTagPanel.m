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
#define ADD_VIEW_TAG 4
#define TEXT_FIELD_TAG 5
#define SCROLL_VIEW_TAG 6
#define DONE_EDITING_TAG 7
#define ANIMATION_DURATION 0.25f

#define ADD_VIEW_HEIGHT 41
#define TEXT_FIELD_FONT [UIFont fontWithName:@"HelveticaNeue" size:16]
#define TEXT_FIELD_MARGIN_SIDES 60
#define TEXT_FIELD_MARGIN_BOTTOM 8
#define TEXT_FIELD_HEIGHT 30
#define KEYBOARD_HEIGHT 216
@interface KPAddTagPanel () <UITextFieldDelegate,KPTagListResizeDelegate>
@property (nonatomic,weak) IBOutlet UIView *addTagView;
@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet UIButton *doneEditingButton;
@property (nonatomic) NSInteger maxHeight;
@end
@implementation KPAddTagPanel
+(KPAddTagPanel*)tagPanelWithTags:(NSArray*)tags maxHeight:(NSInteger)maxHeight{
    KPAddTagPanel *tagPanel = [[KPAddTagPanel alloc] initWithFrame:CGRectMake(0, 0, 320, maxHeight) andTags:tags];
    tagPanel.maxHeight = maxHeight;
    return tagPanel;
}
- (id)initWithFrame:(CGRect)frame andTags:(NSArray*)tags
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-ADD_VIEW_HEIGHT)];
        scrollView.tag = SCROLL_VIEW_TAG;
        KPTagList *tagView = [KPTagList tagListWithWidth:self.frame.size.width andTags:tags];
        CGRectSetY(tagView.frame, 0);
        tagView.resizeDelegate = self;
        tagView.tag = TAG_VIEW_TAG;
        [scrollView addSubview:tagView];
        self.tagView = (KPTagList*)[scrollView viewWithTag:TAG_VIEW_TAG];
        //CGRectSetSize(self.frame, self.frame.size.width, self.tagView.frame.size.height+ADD_VIEW_HEIGHT);//
        scrollView.contentSize = CGSizeMake(tagView.frame.size.width, tagView.frame.size.height);
        scrollView.scrollEnabled = YES;
        [self addSubview:scrollView];
        self.scrollView = (UIScrollView*)[self viewWithTag:SCROLL_VIEW_TAG];
        
        
        UIView *addTagView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-ADD_VIEW_HEIGHT, self.frame.size.width, ADD_VIEW_HEIGHT)];
        addTagView.backgroundColor = [UIColor whiteColor];
        addTagView.tag = ADD_VIEW_TAG;
        
        
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(TEXT_FIELD_MARGIN_SIDES, ADD_VIEW_HEIGHT-TEXT_FIELD_MARGIN_BOTTOM-TEXT_FIELD_HEIGHT, addTagView.frame.size.width-(2*TEXT_FIELD_MARGIN_SIDES), TEXT_FIELD_HEIGHT)];
        textField.tag = TEXT_FIELD_TAG;
        textField.font = TEXT_FIELD_FONT;
        textField.returnKeyType = UIReturnKeyNext;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.delegate = self;
        textField.placeholder = @"Click to add a new tag";
        [addTagView addSubview:textField];
        
        UIButton *doneEditingButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        doneEditingButton.frame = CGRectMake(self.frame.size.width-TEXT_FIELD_MARGIN_SIDES+5, 0, 50, 40);
        [doneEditingButton setTitle:@"Done" forState:UIControlStateNormal];
        doneEditingButton.tag = DONE_EDITING_TAG;
        doneEditingButton.hidden = YES;
        [doneEditingButton addTarget:self action:@selector(pressedDoneEditing:) forControlEvents:UIControlEventTouchUpInside];
        [addTagView addSubview:doneEditingButton];
        self.doneEditingButton = (UIButton*)[addTagView viewWithTag:DONE_EDITING_TAG];
        
        self.textField = (UITextField*)[addTagView viewWithTag:TEXT_FIELD_TAG];
        [self addSubview:addTagView];
        self.addTagView = [self viewWithTag:ADD_VIEW_TAG];
        CGRectSetSize(self.frame, self.frame.size.width, self.addTagView.frame.origin.y+self.addTagView.frame.size.height);
        notify(UIKeyboardWillShowNotification, keyboardWillShow:);
        notify(UIKeyboardWillHideNotification, keyboardWillHide:);
    }
    return self;
}
-(void)pressedDoneEditing:(id)sender{
    [self.textField resignFirstResponder];
}
-(void)tagList:(KPTagList *)tagList changedSize:(CGSize)size{
    CGFloat tagViewHeight = self.tagView.frame.size.height;
    CGRectSetSize(self.frame, self.frame.size.width, tagViewHeight+ADD_VIEW_HEIGHT);
    CGRectSetY(self.addTagView.frame, self.frame.size.height-ADD_VIEW_HEIGHT);
    if(self.isShowingKeyboard) CGRectSetSize(self.frame, self.frame.size.width, self.frame.size.height+KEYBOARD_HEIGHT);
    if([self.delegate respondsToSelector:@selector(tagPanel:changedSize:)]) [self.delegate tagPanel:self changedSize:CGSizeMake(self.frame.size.width, self.frame.size.height)];
}
-(void)keyboardWillHide:(id)sender{
 /*   self.isShowingKeyboard = NO;
    self.textField.placeholder = @"Click to add a new tag";
    if([self.delegate respondsToSelector:@selector(tagPanel:changedSize:)]) [self.delegate tagPanel:self changedSize:CGSizeMake(self.frame.size.width, self.frame.size.height-KEYBOARD_HEIGHT)];*/
    [self shiftToAddMode:NO];
}
-(void)keyboardWillShow:(id)sender{
    /*self.isShowingKeyboard = YES;
    self.textField.placeholder = @"Type in the tag";
    if([self.delegate respondsToSelector:@selector(tagPanel:changedSize:)]) [self.delegate tagPanel:self changedSize:CGSizeMake(self.frame.size.width, self.frame.size.height+KEYBOARD_HEIGHT)];*/
    [self shiftToAddMode:YES];
}
-(void)shiftToAddMode:(BOOL)addMode{
    void (^showBlock)(void);
    showBlock = ^(void) {
//        CGRectSetY(self.scrollView.frame,self.scrollView.frame.origin.y-KEYBOARD_HEIGHT);
        CGRectSetSize(self.scrollView.frame, self.scrollView.frame.size.width, self.scrollView.frame.size.height-KEYBOARD_HEIGHT);
        /*CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
        [self.scrollView setContentOffset:bottomOffset animated:YES];*/
        CGRectSetY(self.addTagView.frame, self.addTagView.frame.origin.y - KEYBOARD_HEIGHT);
        self.textField.placeholder = @"Type in the tag";
        self.doneEditingButton.hidden = NO;
    };
    if(!addMode){
        showBlock = ^(void) {
            CGRectSetSize(self.scrollView.frame, self.scrollView.frame.size.width, self.scrollView.frame.size.height+KEYBOARD_HEIGHT);
            CGRectSetY(self.addTagView.frame, self.addTagView.frame.origin.y + KEYBOARD_HEIGHT);
            self.textField.placeholder = @"Click to add a new tag";
            self.doneEditingButton.hidden = YES;
        };
    }
    [UIView animateWithDuration:ANIMATION_DURATION animations:showBlock completion:^(BOOL finished) {
        
    }];
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
        /*[textField resignFirstResponder];
        [self shiftToAddMode:NO];*/
        return YES;
        
    }
    return NO;
}
-(void)dealloc{
    clearNotify();
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
