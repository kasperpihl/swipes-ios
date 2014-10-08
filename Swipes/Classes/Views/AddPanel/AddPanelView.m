//
//  AddPanelView.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 20/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "AddPanelView.h"
#import "UtilityClass.h"
#import "KPBlurry.h"
#import "KPAddView.h"

#import "NSDate-Utilities.h"
#import "KPTagList.h"
#import "DejalActivityView.h"

#import "UIView+Utilities.h"
#import "DotView.h"
#define ADD_VIEW_TAG 1
#define BACKGROUND_VIEW_TAG 2
#define PICKER_VIEW_TAG 3
#define TEXT_FIELD_TAG 4
#define DONE_EDITING_BUTTON_TAG 5
#define ANIMATION_DURATION 0.25f

#define SEPERATOR_SPACING 15

#define ADD_VIEW_HEIGHT GLOBAL_TEXTFIELD_HEIGHT
#define ADD_FIELD_HEIGHT 30

#define kAddTextStringKey @"AddTextStringKey"
#define kAddTextTimestampKey @"AddTextTimestampKey"

@interface AddPanelView () <AddViewDelegate,KPTagListAddDelegate,KPBlurryDelegate>
@property (nonatomic) UIButton *closeButton;
@property (nonatomic,weak) KPAddView *addView;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) KPTagList *tagList;


@property (nonatomic) UIButton *priorityButton;
@property (nonatomic) DotView *dotView;
@property (nonatomic) BOOL shouldRemove;
@property (nonatomic) BOOL isRotated;
@property (nonatomic) BOOL shouldUnlock;
@property (nonatomic) BOOL hasClosed;
@property (nonatomic) BOOL lock;
@end
@implementation AddPanelView {
    BOOL _justShown;
}
-(void)blurryWillShow:(KPBlurry *)blurry{
    _justShown = YES;
    self.hasClosed = NO;
    [self.addView.textField becomeFirstResponder];
}
-(void)blurryWillHide:(KPBlurry *)blurry{
    self.hasClosed = YES;
    [USER_DEFAULTS setObject:self.addView.textField.text forKey:kAddTextStringKey];
    [USER_DEFAULTS setObject:[NSDate date] forKey:kAddTextTimestampKey];
    [USER_DEFAULTS synchronize];
    [self.addView.textField resignFirstResponder];
    
}
-(void)pressedClose{
    [self.addDelegate closeAddPanel:self];
}
-(void)setTags:(NSArray *)tags{
    _tags = tags;
    [self.tagList setTags:tags andSelectedTags:nil];
    self.scrollView.contentSize = CGSizeMake(self.tagList.frame.size.width, self.tagList.frame.size.height);

    CGRectSetY(self.scrollView, -self.scrollView.frame.size.height);
}
-(void)addView:(KPAddView *)addView enteredTrimmedText:(NSString *)trimmedText{
    if(self.addDelegate && [self.addDelegate respondsToSelector:@selector(didAddItem:priority:tags:)])
        [self.addDelegate didAddItem:trimmedText priority:self.dotView.priority tags:[self.tagList getSelectedTags]];
}
-(void)addViewPressedDoneButton:(KPAddView *)addView{
    [self.addDelegate closeAddPanel:self];
}
-(BOOL)blurryShouldClose:(KPBlurry *)blurry{
    [self.addDelegate closeAddPanel:self];
    return NO;
}

-(void)pressedAddButtonForTagList:(KPTagList *)tagList{
    self.lock = YES;
    [UTILITY inputAlertWithTitle:@"Add New Tag" message:@"Type the name of your tag (ex. work, project or school)" placeholder:@"Add New Tag" cancel:@"Cancel" confirm:@"OK" block:^(NSString *string, NSError *error) {
        NSString *trimmedString = [string stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(trimmedString && trimmedString.length > 0){
            [self.addDelegate addPanel:self createdTag:trimmedString];
            [self.tagList addTag:trimmedString selected:YES];
        }
        
        //[self.addView.textField becomeFirstResponder];
        self.shouldUnlock = YES;
    }];
}

-(void)keyboardWillHide:(NSNotification*)notification{
    if(self.lock){
        return;
    }
    if ( !self.hasClosed )
        [self pressedClose];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
        CGRectSetY(self.scrollView, -self.scrollView.frame.size.height);
        CGFloat yForAdd = self.frame.size.height-self.addView.frame.size.height;
        CGRectSetY(self.addView, yForAdd);
        CGRectSetCenterY(self.priorityButton, yForAdd+self.priorityButton.frame.size.height/2);
    [UIView commitAnimations];
}
-(void)keyboardWillShow:(NSNotification*)notification{
    BOOL animating = YES;
    if(self.shouldUnlock && self.lock){
        self.lock = NO;
        self.shouldUnlock = NO;
        animating = NO;
    }
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat kbdHeight = keyboardFrame.size.height;
    if(OSVER == 7){
        kbdHeight = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? keyboardFrame.size.height : keyboardFrame.size.width;
    }
    CGFloat targetHeight = kbdHeight + self.addView.frame.size.height;
    CGFloat currentHeight = self.frame.size.height;
    
    CGRectSetSize(self.scrollView, self.tagList.frame.size.width, MIN(self.tagList.frame.size.height, currentHeight-targetHeight-SEPERATOR_SPACING-(OSVER >= 7 ? 20 : 0)) );
    CGRectSetY(self.scrollView, -self.scrollView.frame.size.height);
    if(animating){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
    }

    if(targetHeight != currentHeight){
        CGRectSetY(self.scrollView, currentHeight-targetHeight-self.scrollView.frame.size.height-SEPERATOR_SPACING);
        //CGFloat deltaY = currentHeight - targetHeight;
        //CGRectSetY(self, self.frame.origin.y + deltaY);
        //CGRectSetHeight(self, targetHeight);
    }
    
    CGFloat yForAdd = self.frame.size.height - self.addView.frame.size.height - kbdHeight;
    CGRectSetY(self.addView, yForAdd);
    CGRectSetCenterY(self.priorityButton, yForAdd + self.priorityButton.frame.size.height / 2);
    if (animating) {
        [UIView commitAnimations];
    }
    
}
-(void)pressedPriority{
    self.dotView.priority = !self.dotView.priority;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        UIButton *closeButton = [[UIButton alloc] initWithFrame:self.bounds];
        closeButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
        [closeButton addTarget:self action:@selector(pressedClose) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.scrollView.backgroundColor = CLEAR;
        
        self.tagList = [KPTagList tagListWithWidth:self.frame.size.width andTags:nil];
        //tagView.marginLeft = TAG_VIEW_SIDE_MARGIN;
        self.tagList.sorted = YES;
        self.tagList.addDelegate = self;
        self.tagList.addTagButton = YES;
        //tagView.marginRight = TAG_VIEW_SIDE_MARGIN;
        self.tagList.emptyText = @"";
        CGRectSetY(self.tagList, 0);
        
        [self.scrollView addSubview:self.tagList];
        self.scrollView.contentSize = CGSizeMake(self.tagList.frame.size.width, self.tagList.frame.size.height);
        self.scrollView.scrollEnabled = YES;
        
        [self addSubview:self.scrollView];
        
        
        
        
        CGFloat dotWidth = 44;
        DotView *dotView = [[DotView alloc] init];
        dotView.dotColor = tcolor(TasksColor);
        UIButton *priorityButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, dotWidth, ADD_VIEW_HEIGHT)];
        priorityButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [priorityButton addTarget:self action:@selector(pressedPriority) forControlEvents:UIControlEventTouchUpInside];
        CGRectSetCenter(dotView, dotWidth/2, ADD_VIEW_HEIGHT/2);
        
        [priorityButton addSubview:dotView];
        [self addSubview:priorityButton];
        self.priorityButton = priorityButton;
        self.dotView = dotView;

        KPAddView *addView = [[KPAddView alloc] initWithFrame:CGRectMake(dotWidth, frame.size.height - ADD_VIEW_HEIGHT, frame.size.width - dotWidth, ADD_VIEW_HEIGHT)];
        addView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        addView.tag = ADD_VIEW_TAG;
        addView.userInteractionEnabled = YES;
        addView.textField.placeholder = @"Add a new task";
        addView.delegate = self;
        
        //[self.textField setValue:TEXT_FIELD_COLOR forKeyPath:@"_placeholderLabel.textColor"];
        [self addSubview:addView];
        
        
        self.addView = (KPAddView*)[self viewWithTag:ADD_VIEW_TAG];
        //CGRectSetHeight(self, KEYBOARD_HEIGHT+self.addView.frame.size.height);

        CGFloat yForAdd = self.frame.size.height - self.addView.frame.size.height;
        CGRectSetY(self.addView, yForAdd);
        CGRectSetCenterY(self.priorityButton, yForAdd + self.priorityButton.frame.size.height / 2);
        
        NSDate *lastAdd = (NSDate *)[USER_DEFAULTS objectForKey:kAddTextTimestampKey];
        if(lastAdd && [lastAdd minutesBeforeDate:[NSDate date]] < 15){
            NSString *lastTask = [USER_DEFAULTS objectForKey:kAddTextStringKey];
            if(lastTask)
                [self.addView setText:lastTask];
        }

    }
    return self;
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
    if (_justShown) {
        _justShown = NO;
    }
    else {
        //[self pressedClose];
    }
}

@end
