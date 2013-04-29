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
#define ANIMATION_DURATION 0.25f

#define ADD_VIEW_HEIGHT 41
#define TEXT_FIELD_FONT [UIFont fontWithName:@"HelveticaNeue" size:16]
#define TEXT_FIELD_MARGIN_SIDES 60
#define TEXT_FIELD_MARGIN_BOTTOM 8
#define TEXT_FIELD_HEIGHT 30
#define KEYBOARD_HEIGHT 216
@interface KPAddTagPanel () <UITextFieldDelegate>
@property (nonatomic,weak) IBOutlet UIView *backgroundView;
@property (nonatomic,weak) IBOutlet UIView *addTagView;
@property (nonatomic,weak) IBOutlet UITextField *textField;
@end
@implementation KPAddTagPanel
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.tag = BACKGROUND_VIEW_TAG;
        backgroundView.backgroundColor = [UtilityClass colorWithRed:125 green:125 blue:125 alpha:0.1];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = backgroundView.frame;
        [closeButton addTarget:self action:@selector(didPressClose:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:closeButton];
        [self addSubview:backgroundView];
        self.backgroundView = [self viewWithTag:BACKGROUND_VIEW_TAG];
        
        
        KPTagList *tagView = [KPTagList tagListWithWidth:self.frame.size.width];
        CGRectSetY(tagView.frame, self.frame.size.height);
        tagView.tag = TAG_VIEW_TAG;
        [self addSubview:tagView];
        self.tagView = (KPTagList*)[self viewWithTag:TAG_VIEW_TAG];
        
        UIView *addTagView = [[UIView alloc] initWithFrame:CGRectMake(0, tagView.frame.origin.y+tagView.frame.size.height, self.frame.size.width, ADD_VIEW_HEIGHT)];
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
        self.textField = (UITextField*)[addTagView viewWithTag:TEXT_FIELD_TAG];
        [self addSubview:addTagView];
        self.addTagView = [self viewWithTag:ADD_VIEW_TAG];
        notify(UIKeyboardWillShowNotification, keyboardWillShow:);
    }
    return self;
}
-(void)keyboardWillShow:(id)sender{
    self.textField.placeholder = @"Type in the tag";
    [self shiftToAddMode:YES];
}
-(void)shiftToAddMode:(BOOL)addMode{
    void (^showBlock)(void);
    showBlock = ^(void) {
        CGRectSetY(self.tagView.frame,self.tagView.frame.origin.y-KEYBOARD_HEIGHT);
        CGRectSetY(self.addTagView.frame, self.addTagView.frame.origin.y - KEYBOARD_HEIGHT);
    };
    if(!addMode){
        showBlock = ^(void) {
            CGRectSetY(self.tagView.frame,self.tagView.frame.origin.y + KEYBOARD_HEIGHT);
            CGRectSetY(self.addTagView.frame, self.addTagView.frame.origin.y + KEYBOARD_HEIGHT);
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
-(void)didPressClose:(id)sender{
    [self show:NO];
}
-(void)show:(BOOL)show{
    void (^showBlock)(void);
    void (^completionBlock)(void);
    showBlock = ^(void) {
        CGRectSetY(self.tagView.frame,self.frame.size.height-self.tagView.frame.size.height-ADD_VIEW_HEIGHT);
        CGRectSetY(self.addTagView.frame, self.frame.size.height-ADD_VIEW_HEIGHT);
        self.backgroundView.alpha = 1;
    };
    if(!show){
        showBlock = ^(void){
            CGRectSetY(self.tagView.frame,self.frame.size.height);
            CGRectSetY(self.addTagView.frame, self.frame.size.height+self.tagView.frame.size.height);
            self.backgroundView.alpha = 0;
        };
        completionBlock = ^(void){
            if([self.delegate respondsToSelector:@selector(tagPanel:closedWithSelectedTags:)]){
                [self.delegate tagPanel:self closedWithSelectedTags:self.tagView.selectedTags];
            }
            [self removeFromSuperview];
        };
    }
    
    //preblock();
    [UIView animateWithDuration:ANIMATION_DURATION animations:showBlock completion:^(BOOL finished) {
        if(finished){
            if(completionBlock) completionBlock();
        }
    }];
    
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
