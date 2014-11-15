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
#import "UtilityClass.h"
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

@interface KPAddTagPanel () <KPTagListResizeDelegate,KPTagListDeleteDelegate, KPBlurryDelegate,ToolbarDelegate>
@property (nonatomic,weak) IBOutlet KPToolbar *toolbar;
@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet UIButton *doneEditingButton;
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
        tagToolbar.items = @[@"back",@"actionDelete"];//,@"plus"];

        tagToolbar.tag = TOOLBAR_TAG;
        [self addSubview:tagToolbar];
        self.toolbar = (KPToolbar*)[self viewWithTag:TOOLBAR_TAG];
        
        
        [self updateTrashButton];
        
        [self tagList:tagView changedSize:self.tagView.frame.size];
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
    NSLog(@"tried to delete");

    NSString *titleString = [NSString stringWithFormat:@"Delete tag: %@",tag];
    [UTILITY confirmBoxWithTitle:titleString andMessage:@"This can't be undone" block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [self.tagView deleteTag:tag];
            if(self.tagView.numberOfTags == 0) self.deleteMode = NO;
            [self updateTrashButton];
        }
    }];
}

-(void)tagList:(KPTagList *)tagList changedSize:(CGSize)size{
    self.scrollView.contentSize = size;
    CGFloat maxHeight = (self.bounds.size.height-2*TOOLBAR_HEIGHT);
    CGFloat height = (size.height > maxHeight) ? maxHeight : size.height;
    CGRectSetHeight(self.scrollView, height);
    CGRectSetY(self.scrollView, CGRectGetMinY(self.toolbar.frame) - CGRectGetHeight(self.scrollView.frame));
}

-(void)shiftToDeleteMode:(BOOL)deleteMode{
    UIButton *plusButton = [self.toolbar.barButtons lastObject];
    if(deleteMode){
        [plusButton setTitle:@"plus" forState:UIControlStateNormal];
        [plusButton setTitle:@"plus" forState:UIControlStateHighlighted];
    }
    else{
        [plusButton setTitle:@"actionDelete" forState:UIControlStateNormal];
        [plusButton setTitle:@"actionDeleteFull" forState:UIControlStateHighlighted];
    }
    
    CGAffineTransform transform = deleteMode ? CGAffineTransformMakeRotation(radians(45)) : CGAffineTransformIdentity;
    plusButton.transform = transform;
    [self.tagView setWobling:deleteMode];
    
}


-(void)dealloc{
    clearNotify();
}



@end
