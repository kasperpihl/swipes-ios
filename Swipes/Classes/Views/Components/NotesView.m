//
//  NotesView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 03/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kTitleHeight 50
#define kTitleTopPadding 1
#define kTextBottomPadding 15
#define kContentSpacingLeft 10
#define kContentSpacingRight 25


#import "NotesView.h"
#import "KPToolbar.h"
#import "KPBlurry.h"
#import "KPAlert.h"
@interface NotesView () <KPBlurryDelegate,UITextViewDelegate>
@property (nonatomic,strong) UITextView *notesView;
@property (nonatomic,strong) UIButton *backbutton;
@property (nonatomic) NSString *originalString;
@end
@implementation NotesView
-(void)blurryWillShow:(KPBlurry *)blurry{
    [self.notesView becomeFirstResponder];
}
-(void)blurryWillHide:(KPBlurry *)blurry{
    if([self.notesView isFirstResponder]) [self.notesView resignFirstResponder];
}
- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = tcolor(BackgroundColor);
        
        
        UITextView *notesView = [[UITextView alloc] initWithFrame:CGRectMake(kContentSpacingLeft, 0, self.frame.size.width - kContentSpacingLeft - kContentSpacingRight, self.bounds.size.height)];
        notesView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        notesView.backgroundColor = CLEAR;
        notesView.font = NOTES_VIEW_FONT;
        notesView.keyboardAppearance = UIKeyboardAppearanceAlert;
        notesView.textColor = tcolor(TextColor);
        notesView.delegate = self;
        [self addSubview:notesView];
        self.notesView = notesView;
        
        UIButton *backbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        backbutton.frame = CGRectMake(self.frame.size.width - 44, self.frame.size.height - 44, 44, 44);
        backbutton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [backbutton setImage:[UIImage imageNamed:timageStringBW(@"backarrow_icon")] forState:UIControlStateNormal];
        backbutton.transform = CGAffineTransformMakeRotation(M_PI);
        [backbutton addTarget:self action:@selector(pressedBack:) forControlEvents:UIControlEventTouchUpInside];
        //self.toolbar.backgroundColor = tcolor(MenuBackground);
        self.backbutton = backbutton;
        [self addSubview:self.backbutton];
        
        
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
-(void)textViewDidChange:(UITextView *)textView{
    if([textView.text hasSuffix:@"\n"] && self.notesView.contentSize.height > self.notesView.bounds.size.height) {
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            CGPoint bottomOffset = CGPointMake(0, self.notesView.contentSize.height - self.notesView.bounds.size.height);
            [self.notesView setContentOffset:bottomOffset animated:NO];
        });
    }
}
-(void)pressedBack:(UIButton*)backButton{
    [self.delegate savedNotesView:self text:self.notesView.text];
}
-(void)setNotesText:(NSString*)notesText title:(NSString *)title{
    self.notesView.text = notesText;
    //self.titleLabel.text = title;
}
-(void)keyboardWillHide:(NSNotification*)notification{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    CGRectSetY(self.backbutton, self.frame.size.height-self.backbutton.frame.size.height);
    [UIView commitAnimations];
}
-(void)keyboardWillShow:(NSNotification*)notification{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"notif:%@",notification);
    CGRectSetY(self.backbutton, self.frame.size.height-self.backbutton.frame.size.height-keyboardFrame.size.height);
    CGRectSetHeight(self.notesView, self.frame.size.height-keyboardFrame.size.height-kTextBottomPadding);
    [UIView commitAnimations];
}

-(void)dealloc{
    self.backbutton = nil;
    self.notesView = nil;
    clearNotify();
}

@end
