//
//  NotesView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 03/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define BUTTON_BAR_HEIGHT (44+COLOR_SEPERATOR_HEIGHT)
#define NOTES_VIEW_TAG 1

#import "NotesView.h"
#import "UIViewController+KNSemiModal.h"
@interface NotesView ()
@property (nonatomic,weak) UITextView *notesView;
@end
@implementation NotesView

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = tbackground(TaskCellBackground);
        UIView *buttonBarContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-KEYBOARD_HEIGHT-BUTTON_BAR_HEIGHT, 320, BUTTON_BAR_HEIGHT)];
        buttonBarContainer.backgroundColor = tbackground(TagBackground);
        
        CGFloat buttonWidth = 320/2;
        
        
        UIButton *noButton = [UIButton buttonWithType:UIButtonTypeCustom];
        noButton.titleLabel.font = BUTTON_FONT;
        noButton.frame = CGRectMake(0, 0 , buttonWidth , BUTTON_HEIGHT);
        [noButton addTarget:self action:@selector(pressedCancel:) forControlEvents:UIControlEventTouchUpInside];
        [noButton setTitle:@"CANCEL" forState:UIControlStateNormal];
        [buttonBarContainer addSubview:noButton];
        
        
        UIView *buttonSpecificSeperator = [[UIView alloc] initWithFrame:CGRectMake(buttonWidth-SEPERATOR_WIDTH/2, 0, SEPERATOR_WIDTH, BUTTON_HEIGHT)];
        buttonSpecificSeperator.backgroundColor = tbackground(TaskCellBackground);
        [buttonBarContainer addSubview:buttonSpecificSeperator];
        
        UIButton *yesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        yesButton.titleLabel.font = BUTTON_FONT;
        yesButton.frame = CGRectMake(buttonWidth, 0,buttonWidth , BUTTON_HEIGHT);
        [yesButton setTitle:@"DONE" forState:UIControlStateNormal];
        [yesButton addTarget:self action:@selector(pressedDone:) forControlEvents:UIControlEventTouchUpInside];
        [buttonBarContainer addSubview:yesButton];
        
        UIView *colorBottomSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, BUTTON_BAR_HEIGHT-COLOR_SEPERATOR_HEIGHT, buttonBarContainer.frame.size.width, COLOR_SEPERATOR_HEIGHT)];
        colorBottomSeperator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        colorBottomSeperator.backgroundColor = tcolor(ColoredSeperator);
        [buttonBarContainer addSubview:colorBottomSeperator];
        
        [self addSubview:buttonBarContainer];
        
        
        UITextView *notesView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, self.frame.size.height-BUTTON_BAR_HEIGHT-KEYBOARD_HEIGHT)];
        notesView.backgroundColor = CLEAR;
        notesView.tag = NOTES_VIEW_TAG;
        notesView.font = TEXT_FIELD_FONT;
        notesView.keyboardAppearance = UIKeyboardAppearanceAlert;
        notesView.textColor = TEXT_FIELD_COLOR;
        [self addSubview:notesView];
        self.notesView = (UITextView*)[self viewWithTag:NOTES_VIEW_TAG];
        [self.notesView becomeFirstResponder];
    }
    return self;
}
-(void)pressedCancel:(id)sender{
    [self.delegate pressedCancelNotesView:self];
    if([self.notesView isFirstResponder]) [self.notesView resignFirstResponder];
}
-(void)pressedDone:(id)sender{
    if([self.notesView isFirstResponder]) [self.notesView resignFirstResponder];
    [self.delegate savedNotesView:self text:self.notesView.text];
}
-(void)setNotesText:(NSString*)notesText{
    self.notesView.text = notesText;
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
