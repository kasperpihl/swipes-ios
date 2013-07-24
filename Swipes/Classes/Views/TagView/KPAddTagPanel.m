//
//  KPTagView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPAddTagPanel.h"
#import "UtilityClass.h"
#import "KPBlurry.h"
#import "KPToolbar.h"
#define BACKGROUND_VIEW_TAG 2
#define TAG_VIEW_TAG 3
#define TOOLBAR_TAG 4
#define TEXT_FIELD_TAG 5
#define SCROLL_VIEW_TAG 6
#define ADD_VIEW_TAG 8
#define DONE_EDITING_BUTTON_TAG 9


#define ANIMATION_DURATION 0.25f


#define TOOLBAR_HEIGHT 60
#define TAG_VIEW_SIDE_MARGIN 10
#define TAG_VIEW_BOTTOM_MARGIN 25

#define KEYBOARD_HEIGHT 216

#define NUMBER_OF_BAR_BUTTONS 2

@interface KPAddTagPanel () <UITextFieldDelegate,KPTagListResizeDelegate,KPTagDelegate,KPBlurryDelegate,ToolbarDelegate>
@property (nonatomic,weak) IBOutlet UIView *addTagView;
@property (nonatomic,weak) IBOutlet UIView *tagContainerView;
@property (nonatomic,weak) IBOutlet KPToolbar *toolbar;
@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet UIButton *doneEditingButton;
@property (nonatomic) BOOL isAdding;
@property (nonatomic) NSInteger maxHeight;
@property (nonatomic) BOOL isRotated;
@end
@implementation KPAddTagPanel
+(KPAddTagPanel*)tagPanelWithTags:(NSArray*)tags maxHeight:(NSInteger)maxHeight{
    KPAddTagPanel *tagPanel = [[KPAddTagPanel alloc] initWithFrame:CGRectMake(0, 0, 320, maxHeight) andTags:tags andMaxHeight:maxHeight];
    
    return tagPanel;
}
-(void)toolbar:(KPToolbar *)toolbar pressedItem:(NSInteger)item{
    
    if(item == 0){
        [BLURRY dismissAnimated:YES];
        [self.delegate closeTagPanel:self];
    }
    else if(item == 1){
        
    }
    else if (item == 2) {
        [self shiftToAddMode:YES];
    }
}
-(void)pressedClose:(id)sender{
    [self toolbar:self.toolbar pressedItem:0];
}
-(IBAction)rotateButton
{
    NSLog( @"Rotating button");
    
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
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
        closeButton.frame = self.bounds;
        [closeButton addTarget:self action:@selector(pressedClose:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-TOOLBAR_HEIGHT)];
        scrollView.tag = SCROLL_VIEW_TAG;
        
        KPTagList *tagView = [KPTagList tagListWithWidth:self.frame.size.width andTags:tags];
        tagView.marginLeft = TAG_VIEW_SIDE_MARGIN;
        tagView.enableEdit = YES;
        tagView.marginRight = TAG_VIEW_SIDE_MARGIN;
        tagView.emptyText = @"No tags - press the plus to add one";
        tagView.emptyLabelMarginHack = 10;
        tagView.tagColor = tbackground(MenuBackground);
        CGRectSetY(tagView, 0);
        tagView.resizeDelegate = self;
        tagView.tag = TAG_VIEW_TAG;
        [scrollView addSubview:tagView];
        self.tagView = (KPTagList*)[scrollView viewWithTag:TAG_VIEW_TAG];
        //CGRectSetSize(self.frame, self.frame.size.width, self.tagView.frame.size.height+ADD_VIEW_HEIGHT);//
        scrollView.contentSize = CGSizeMake(tagView.frame.size.width, tagView.frame.size.height);
        scrollView.scrollEnabled = YES;
        
        [self addSubview:scrollView];
        self.scrollView = (UIScrollView*)[self viewWithTag:SCROLL_VIEW_TAG];
        [self tagList:self.tagView changedSize:CGSizeMake(self.frame.size.width, self.tagView.frame.size.height)];
        
        
        /* Initialize tagbar view */
        KPToolbar *tagToolbar = [[KPToolbar alloc] initWithFrame:CGRectMake(0, self.frame.size.height-TOOLBAR_HEIGHT, self.frame.size.width, TOOLBAR_HEIGHT) items:@[@"toolbar_back_icon",@"toolbar_trashcan_icon",@"toolbar_plus_icon"]];
        tagToolbar.backgroundColor = tbackground(TagBarBackground);
        tagToolbar.delegate = self;
        tagToolbar.tag = TOOLBAR_TAG;
        [self addSubview:tagToolbar];
        self.toolbar = (KPToolbar*)[self viewWithTag:TOOLBAR_TAG];
        /* Initialize addView */
        
        UIView *addView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, TEXT_FIELD_CONTAINER_HEIGHT)];
        addView.tag = ADD_VIEW_TAG;
        addView.backgroundColor = tbackground(SearchDrawerBackground);
        
        UIButton *doneEditingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat buttonSize = addView.frame.size.height;
        doneEditingButton.tag = DONE_EDITING_BUTTON_TAG;
        doneEditingButton.imageView.clipsToBounds = NO;
        doneEditingButton.imageView.contentMode = UIViewContentModeCenter;
        doneEditingButton.frame = CGRectMake(addView.frame.size.width-buttonSize, 0, buttonSize, buttonSize);
        [doneEditingButton setImage:[UIImage imageNamed:@"hide_keyboard_arrow"] forState:UIControlStateNormal];
        [doneEditingButton addTarget:self action:@selector(pressedDoneEditing:) forControlEvents:UIControlEventTouchUpInside];
        [addView addSubview:doneEditingButton];
        self.doneEditingButton = (UIButton*)[addView viewWithTag:DONE_EDITING_BUTTON_TAG];

        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(TEXT_FIELD_MARGIN_LEFT, TEXT_FIELD_MARGIN_TOP, addView.frame.size.width-TEXT_FIELD_MARGIN_LEFT-buttonSize, TEXT_FIELD_HEIGHT)];
        textField.tag = TEXT_FIELD_TAG;
        textField.font = TEXT_FIELD_FONT;
        textField.textColor = tcolor(SearchDrawerColor);
        textField.returnKeyType = UIReturnKeyNext;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.keyboardAppearance = UIKeyboardAppearanceAlert;
        textField.borderStyle = UITextBorderStyleNone;
        textField.delegate = self;
        textField.placeholder = @"Add a tag";
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [addView addSubview:textField];
        self.textField = (UITextField*)[addView viewWithTag:TEXT_FIELD_TAG];
        //[self.textField setValue:TEXT_FIELD_COLOR forKeyPath:@"_placeholderLabel.textColor"];
        [self addSubview:addView];
        self.addTagView = [self viewWithTag:ADD_VIEW_TAG];
        self.addTagView.hidden = YES;
        //CGRectSetHeight(self, self.barBottomView.frame.origin.y+self.barBottomView.frame.size.height);
    }
    return self;
}
-(void)pressedDoneEditing:(id)sender{
    [self textFieldShouldReturn:self.textField];
    [self shiftToAddMode:NO];
}
-(void)tagList:(KPTagList *)tagList changedSize:(CGSize)size{
    self.scrollView.contentSize = size;
    CGFloat height = (size.height > self.maxHeight) ? self.maxHeight : size.height;
    CGRectSetHeight(self.scrollView, height);
    CGRectSetY(self.scrollView, self.frame.size.height - TOOLBAR_HEIGHT - self.scrollView.frame.size.height - TAG_VIEW_BOTTOM_MARGIN);
}

-(void)shiftToAddMode:(BOOL)addMode{
    if(addMode){
        self.isAdding = YES;
        
        [self.textField becomeFirstResponder];
        self.addTagView.hidden = NO;
        CGRectSetY(self.addTagView,self.frame.size.height-self.addTagView.frame.size.height);
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.scrollView.alpha = 0;
            CGRectSetY(self.addTagView,self.frame.size.height-self.addTagView.frame.size.height-KEYBOARD_HEIGHT);
        } completion:^(BOOL finished) {
        }];
    }
    else{
        self.isAdding = NO;
        [self.textField resignFirstResponder];
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.scrollView.alpha = 1;
            CGRectSetY(self.addTagView,self.frame.size.height-self.addTagView.frame.size.height);
        } completion:^(BOOL finished) {
            if(finished){
                self.addTagView.hidden = YES;
            }
        }];
    }
}
-(void)textFieldDidChange:(UITextField*)textField{
    NSString *trimmedString = trim(textField.text);
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
    NSString *trimmedString = trim(textField.text);
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
