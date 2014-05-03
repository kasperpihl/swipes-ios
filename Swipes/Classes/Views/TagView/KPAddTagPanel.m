//
//  KPTagView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPAddTagPanel.h"
#import "KPBlurry.h"
#import "KPToolbar.h"
#import "KPAddView.h"
#import "UIView+Utilities.h"
#import "KPAlert.h"
#define BACKGROUND_VIEW_TAG 2
#define TAG_VIEW_TAG 3
#define TOOLBAR_TAG 4
#define SCROLL_VIEW_TAG 6
#define ADD_VIEW_TAG 8


#define ANIMATION_DURATION KEYBOARD_ANIMATION_DURATION


#define TOOLBAR_HEIGHT GLOBAL_TOOLBAR_HEIGHT
#define ADD_VIEW_HEIGHT GLOBAL_TEXTFIELD_HEIGHT
#define TAG_VIEW_SIDE_MARGIN 10
#define TAG_VIEW_BOTTOM_MARGIN 10


#define NUMBER_OF_BAR_BUTTONS 2

@interface KPAddTagPanel () <KPTagListResizeDelegate,KPTagListDeleteDelegate,KPBlurryDelegate,ToolbarDelegate,AddViewDelegate>
@property (nonatomic,weak) IBOutlet KPAddView *addTagView;
@property (nonatomic,weak) IBOutlet KPToolbar *toolbar;
@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet UIButton *doneEditingButton;
@property (nonatomic) BOOL isAdding;
@property (nonatomic) BOOL isRotated;
@property (nonatomic) BOOL deleteMode;
@end
@implementation KPAddTagPanel{
    BOOL _justShown;
}
-(void)setDeleteMode:(BOOL)deleteMode{
    if(_deleteMode != deleteMode){
        [self shiftToDeleteMode:deleteMode];
        _deleteMode = deleteMode;
    }
}
-(void)toolbar:(KPToolbar *)toolbar pressedItem:(NSInteger)item{
    
    if(item == 0){
        [BLURRY dismissAnimated:YES];
        [self.delegate closeTagPanel:self];
    }
    else if(item == 1){
        self.deleteMode = !self.deleteMode;
    }
    else if (item == 2) {
        if(self.deleteMode){
            self.deleteMode = NO;
        }
        else
            [self shiftToAddMode:YES];
    }
}
-(void)blurryWillShow:(KPBlurry *)blurry{
    _justShown = YES;
}
-(void)blurryWillHide:(KPBlurry *)blurry{
    if(self.isAdding) [self shiftToAddMode:NO];
}
-(void)pressedClose:(id)sender{
    [self toolbar:self.toolbar pressedItem:0];
}
- (id)initWithFrame:(CGRect)frame andTags:(NSArray*)tags
{
    self = [super initWithFrame:frame];
    if (self) {
        /* Initialize taglistview + scrolling */
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
        closeButton.frame = self.bounds;
        [closeButton addTarget:self action:@selector(pressedClose:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - TOOLBAR_HEIGHT)];
        scrollView.tag = SCROLL_VIEW_TAG;
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        KPTagList *tagView = [KPTagList tagListWithWidth:self.frame.size.width andTags:tags];
        tagView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //tagView.marginLeft = TAG_VIEW_SIDE_MARGIN;
        tagView.sorted = YES;
        //tagView.marginRight = TAG_VIEW_SIDE_MARGIN;
        tagView.emptyText = @"No tags - press the plus to add one";
        tagView.emptyLabelMarginHack = 10;
        CGRectSetY(tagView, 0);
        tagView.resizeDelegate = self;
        tagView.deleteDelegate = self;
        tagView.tag = TAG_VIEW_TAG;
        [scrollView addSubview:tagView];
        self.tagView = (KPTagList*)[scrollView viewWithTag:TAG_VIEW_TAG];
        //CGRectSetSize(self.frame, self.frame.size.width, self.tagView.frame.size.height+ADD_VIEW_HEIGHT);//
        scrollView.contentSize = CGSizeMake(tagView.frame.size.width, tagView.frame.size.height);
        scrollView.scrollEnabled = YES;
        scrollView.backgroundColor = CLEAR;
        [self addSubview:scrollView];
        self.scrollView = (UIScrollView*)[self viewWithTag:SCROLL_VIEW_TAG];

        
        
        /* Initialize toolbar */
        KPToolbar *tagToolbar = [[KPToolbar alloc] initWithFrame:CGRectMake(0, self.frame.size.height - TOOLBAR_HEIGHT, self.frame.size.width, TOOLBAR_HEIGHT)
                                                           items:nil
                                                        delegate:self];
        tagToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        tagToolbar.font = iconFont(23);
        tagToolbar.titleColor = tcolor(TextColor);
        tagToolbar.items = @[@"back",@"actionDelete",@"plus"];

        tagToolbar.tag = TOOLBAR_TAG;
        [self addSubview:tagToolbar];
        self.toolbar = (KPToolbar*)[self viewWithTag:TOOLBAR_TAG];
        
        
        /* Initialize addView */
        KPAddView *addView = [[KPAddView alloc] initWithFrame:CGRectMake(TEXT_FIELD_MARGIN_LEFT, self.bounds.size.height,
                                                                         self.bounds.size.width - TEXT_FIELD_MARGIN_LEFT, ADD_VIEW_HEIGHT)];
        addView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        addView.tag = ADD_VIEW_TAG;
        addView.userInteractionEnabled = YES;
        addView.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        addView.textField.placeholder = @"Add a new tag";
        addView.delegate = self;
        [self addSubview:addView];
        self.addTagView = (KPAddView*)[self viewWithTag:ADD_VIEW_TAG];
        self.addTagView.hidden = YES;
        [self updateTrashButton];
        
        [self tagList:tagView changedSize:self.tagView.frame.size];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}
-(void)toolbar:(KPToolbar *)toolbar editButton:(UIButton *__autoreleasing *)button forItem:(NSInteger)item{
    if(item == 1){
        [*button setTitle:iconString(@"actionDeleteFull") forState:UIControlStateHighlighted];
    }
}
-(void)updateTrashButton{
    UIButton* trashButton = (UIButton*)[self.toolbar.barButtons objectAtIndex:1];
    trashButton.enabled = !(self.tagView.numberOfTags == 0);
}
-(void)tagList:(KPTagList *)tagList triedToDeleteTag:(NSString *)tag{
    NSString *titleString = [NSString stringWithFormat:@"Delete tag: %@",tag];
    __block KPAlert *alert = [KPAlert alertWithFrame:self.bounds title:titleString message:@"This can't be undone" block:^(BOOL succeeded, NSError *error) {
        [alert removeFromSuperview];
        if(succeeded){
            [self.tagView deleteTag:tag];
            if(self.tagView.numberOfTags == 0) self.deleteMode = NO;
            [self updateTrashButton];
        }
    }];
    [self addSubview:alert];
}
-(void)tagList:(KPTagList *)tagList changedSize:(CGSize)size{
    self.scrollView.contentSize = size;
    CGFloat maxHeight = (self.bounds.size.height-2*TOOLBAR_HEIGHT);
    CGFloat height = (size.height > maxHeight) ? maxHeight : size.height;
    CGRectSetHeight(self.scrollView, height);
    // OLDCODE
    //CGRectSetY(self.scrollView, self.frame.size.height - TOOLBAR_HEIGHT - self.scrollView.frame.size.height - TAG_VIEW_BOTTOM_MARGIN);
    // NEWCODE
    NSLog(@"%f - %f",CGRectGetMinY(self.toolbar.frame),CGRectGetHeight(self.scrollView.frame));
    CGRectSetY(self.scrollView, CGRectGetMinY(self.toolbar.frame) - CGRectGetHeight(self.scrollView.frame));
}
-(void)shiftToDeleteMode:(BOOL)deleteMode{
    UIButton *plusButton = [self.toolbar.barButtons lastObject];
    [self.tagView setWobling:deleteMode];
    CGAffineTransform transform = deleteMode ? CGAffineTransformMakeRotation(radians(45)) : CGAffineTransformIdentity;
    [UIView animateWithDuration:0.2f animations:^{
        plusButton.transform = transform;
    } completion:^(BOOL finished) {
        
    }];
}
-(void)keyboardWillHide:(NSNotification*)notification{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDidStopSelector:@selector(completedHidingKeyboard)];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    self.scrollView.alpha = 1;
    self.addTagView.alpha = 0;
    CGRectSetY(self.addTagView, self.frame.size.height - self.addTagView.frame.size.height);
    
    [UIView commitAnimations];
}
-(void)completedHidingKeyboard{
    self.addTagView.hidden = YES;
    self.addTagView.alpha = 1;
}
-(void)keyboardWillShow:(NSNotification*)notification{
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat kbdHeight = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? keyboardFrame.size.height : keyboardFrame.size.width;
    self.scrollView.alpha = 0;
    CGRectSetY(self.addTagView, self.frame.size.height - self.addTagView.frame.size.height - kbdHeight);
    
    [UIView commitAnimations];
}
-(void)shiftToAddMode:(BOOL)addMode{
    if(addMode){
        self.isAdding = YES;
        self.addTagView.hidden = NO;
        self.addTagView.alpha = 1;
        CGRectSetY(self.addTagView,self.frame.size.height-self.addTagView.frame.size.height);
        [self.addTagView.textField becomeFirstResponder];
    }
    else{
        [self updateTrashButton];
        self.isAdding = NO;
        [self.addTagView.textField resignFirstResponder];
    }
}
-(void)addView:(KPAddView *)addView enteredTrimmedText:(NSString *)trimmedText{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tagPanel:createdTag:)])
        [self.delegate tagPanel:self createdTag:trimmedText];
    [self.tagView addTag:trimmedText selected:YES];
}
-(void)addViewPressedDoneButton:(KPAddView *)addView{
    [self shiftToAddMode:NO];
}
-(void)dealloc{
    clearNotify();
}

// NEWCODE
- (void)layoutSubviews
{
    [super layoutSubviews];
    // it is really complicated to recalc the new keyboard frame
    // FIXME: maybe someday we should do it anyway
    if ( _justShown ){
        _justShown = NO;
    }
    else
        [self toolbar:self.toolbar pressedItem:0];
}


@end
