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
@implementation KPAddTagPanel
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
        else [self shiftToAddMode:YES];
    }
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
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-TOOLBAR_HEIGHT)];
        scrollView.tag = SCROLL_VIEW_TAG;
        
        KPTagList *tagView = [KPTagList tagListWithWidth:self.frame.size.width andTags:tags];
        tagView.marginLeft = TAG_VIEW_SIDE_MARGIN;
        tagView.sorted = YES;
        tagView.marginRight = TAG_VIEW_SIDE_MARGIN;
        tagView.emptyText = @"No tags - press the plus to add one";
        tagView.emptyLabelMarginHack = 10;
        tagView.tagColor = tbackground(MenuBackground);
        CGRectSetY(tagView, 0);
        tagView.resizeDelegate = self;
        tagView.deleteDelegate = self;
        tagView.tag = TAG_VIEW_TAG;
        [scrollView addSubview:tagView];
        self.tagView = (KPTagList*)[scrollView viewWithTag:TAG_VIEW_TAG];
        //CGRectSetSize(self.frame, self.frame.size.width, self.tagView.frame.size.height+ADD_VIEW_HEIGHT);//
        scrollView.contentSize = CGSizeMake(tagView.frame.size.width, tagView.frame.size.height);
        scrollView.scrollEnabled = YES;
        
        [self addSubview:scrollView];
        self.scrollView = (UIScrollView*)[self viewWithTag:SCROLL_VIEW_TAG];
        [self tagList:tagView changedSize:CGSizeMake(self.frame.size.width, tagView.frame.size.height)];
        
        
        /* Initialize toolbar */
        KPToolbar *tagToolbar = [[KPToolbar alloc] initWithFrame:CGRectMake(0, self.frame.size.height-TOOLBAR_HEIGHT, self.frame.size.width, TOOLBAR_HEIGHT) items:@[@"toolbar_back_icon",@"toolbar_trashcan_icon",@"toolbar_plus_icon"]];
        tagToolbar.delegate = self;
        tagToolbar.tag = TOOLBAR_TAG;
        [self addSubview:tagToolbar];
        self.toolbar = (KPToolbar*)[self viewWithTag:TOOLBAR_TAG];
        
        
        /* Initialize addView */
        KPAddView *addView = [[KPAddView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, ADD_VIEW_HEIGHT)];
        addView.tag = ADD_VIEW_TAG;
        addView.userInteractionEnabled = YES;
        addView.backgroundColor = tbackground(MenuBackground);
        addView.textField.placeholder = @"Add a new tag";
        addView.delegate = self;
        [self addSubview:addView];
        self.addTagView = (KPAddView*)[self viewWithTag:ADD_VIEW_TAG];
        self.addTagView.hidden = YES;
        [self updateTrashButton];
    }
    return self;
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
    CGRectSetY(self.scrollView, self.frame.size.height - TOOLBAR_HEIGHT - self.scrollView.frame.size.height - TAG_VIEW_BOTTOM_MARGIN);
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
-(void)shiftToAddMode:(BOOL)addMode{
    if(addMode){
        self.isAdding = YES;
        [self.addTagView.textField becomeFirstResponder];
        self.addTagView.hidden = NO;
        CGRectSetY(self.addTagView,self.frame.size.height-self.addTagView.frame.size.height);
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.scrollView.alpha = 0;
            CGRectSetY(self.addTagView,self.frame.size.height-self.addTagView.frame.size.height-KEYBOARD_HEIGHT);
        } completion:^(BOOL finished) {
        }];
    }
    else{
        [self updateTrashButton];
        self.isAdding = NO;
        [self.addTagView.textField resignFirstResponder];
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.scrollView.alpha = 1;
            self.addTagView.alpha = 0;
            CGRectSetY(self.addTagView,self.frame.size.height-self.addTagView.frame.size.height);
        } completion:^(BOOL finished) {
            if(finished){
                self.addTagView.hidden = YES;
                self.addTagView.alpha = 1;
            }
        }];
    }
}
-(void)addView:(KPAddView *)addView enteredTrimmedText:(NSString *)trimmedText{
    if(self.delegate && [self.delegate respondsToSelector:@selector(tagPanel:createdTag:)])
        [self.delegate tagPanel:self createdTag:trimmedText];
    [self.tagView addTag:trimmedText selected:YES];
}
-(void)addViewPressedDoneButton:(KPAddView *)addView{
    [self shiftToAddMode:NO];
}
@end
