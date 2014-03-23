//
//  AddPanelView.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 20/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "AddPanelView.h"
#import "KPBlurry.h"
#import "UtilityClass.h"
#import "KPAddView.h"
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


@interface AddPanelView () <AddViewDelegate,KPBlurryDelegate>
@property (nonatomic,weak) IBOutlet KPAddView *addView;
@property (nonatomic) UIButton *priorityButton;
@property (nonatomic) DotView *dotView;
@property (nonatomic) BOOL shouldRemove;
@property (nonatomic) BOOL isRotated;
@end
@implementation AddPanelView {
    BOOL _justShown;
}
-(void)blurryWillShow:(KPBlurry *)blurry{
    _justShown = YES;
    [self.addView.textField becomeFirstResponder];
}
-(void)blurryWillHide:(KPBlurry *)blurry{
    [self.addView.textField resignFirstResponder];
    
}
-(void)addView:(KPAddView *)addView enteredTrimmedText:(NSString *)trimmedText{
    if(self.addDelegate && [self.addDelegate respondsToSelector:@selector(didAddItem:priority:)])
        [self.addDelegate didAddItem:trimmedText priority:self.dotView.priority];
}
-(void)addViewPressedDoneButton:(KPAddView *)addView{
    [self.addDelegate closeAddPanel:self];
}
-(BOOL)blurryShouldClose:(KPBlurry *)blurry{
    [self.addDelegate closeAddPanel:self];
    return NO;
}
-(void)keyboardWillHide:(NSNotification*)notification{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
        CGFloat yForAdd = self.frame.size.height-self.addView.frame.size.height;
        CGRectSetY(self.addView, yForAdd);
        CGRectSetCenterY(self.priorityButton, yForAdd+self.priorityButton.frame.size.height/2);
    [UIView commitAnimations];
}
-(void)keyboardWillShow:(NSNotification*)notification{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat kbdHeight = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? keyboardFrame.size.height : keyboardFrame.size.width;
    CGFloat targetHeight = kbdHeight + self.addView.frame.size.height;
    CGFloat currentHeight = self.frame.size.height;
    if(targetHeight != currentHeight){
        CGFloat deltaY = currentHeight - targetHeight;
        CGRectSetY(self, self.frame.origin.y + deltaY);
        CGRectSetHeight(self, targetHeight);
    }
    CGFloat yForAdd = self.frame.size.height - self.addView.frame.size.height - kbdHeight;
    CGRectSetY(self.addView, yForAdd);
    CGRectSetCenterY(self.priorityButton, yForAdd + self.priorityButton.frame.size.height / 2);
    [UIView commitAnimations];
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
        [self.addView.textField resignFirstResponder];
    }
}

@end
