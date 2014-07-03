//
//  SubtaskCell.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 22/02/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "SubtaskCell.h"
#import "KPToDo.h"
#import <QuartzCore/QuartzCore.h>


#define kTitleX CELL_LABEL_X

@interface SubtaskCell () <UITextFieldDelegate>
@property (nonatomic) UIButton *dotView;
@property (nonatomic) UIView *dotContainer;
@property (nonatomic) UIButton *addCloseButton;
@property (nonatomic) UIButton *overlayAddbutton;

@property BOOL inEditMode;
@end

@implementation SubtaskCell
-(void)setAddModeForCell:(BOOL)addModeForCell{
    _addModeForCell = addModeForCell;
    [self switchBetweenAddAndEdit:addModeForCell animated:NO];
    
}

-(void)setStrikeThrough:(BOOL)strikeThrough{
    _strikeThrough = strikeThrough;
    [self updateTitle];
}
-(void)updateTitle{
    NSDictionary* attributes;
    self.titleField.textColor = self.strikeThrough ? color(161, 163, 165, 0.7) : tcolor(TextColor);
    self.titleField.text = self.title;
    return;
    if(self.strikeThrough){
        attributes = @{
                       NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                       };
    }
    NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:self.title attributes:attributes];
    self.titleField.attributedText = attrText;
}
-(void)setModel:(KPToDo *)model{
    if(_model != model){
        _model = model;
    }
}


-(void)setTitle:(NSString *)title{
    _title = title;
    [self updateTitle];
}

-(void)switchBetweenAddAndEdit:(BOOL)adding animated:(BOOL)animated{
    voidBlock aniblock1;
    voidBlock comp1;
    //self.overlayAddbutton.hidden = !addMode;
    if(adding){
        self.titleField.returnKeyType = UIReturnKeyDone;
        aniblock1 = ^{
            self.dotContainer.transform = CGAffineTransformMakeScale(kDotMultiplier, kDotMultiplier);
            CGRectSetCenter(self.dotContainer, kTitleX/2, self.bounds.size.height/2);
            self.titleField.text = @"Add action step";
            //self.titleField.textColor = tcolor(SubTextColor);
            self.dotView.layer.borderWidth = kLineSize/kDotMultiplier;
            self.titleField.font = EDIT_TASK_TEXT_FONT;
            self.inEditMode = YES;
            CGRectSetHeight(self.seperator, self.bounds.size.height/2);
            CGRectSetY(self.seperator, 0);
            
            
        };
        comp1 = ^{
            [self.dotView setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
            self.dotView.layer.borderWidth = 0;
            self.dotContainer.transform = CGAffineTransformIdentity;
            //self.dotView.autoresizingMask = UIViewAutoresizingNone;
            CGRectSetSize(self.dotContainer, kAddSize+2*kSubOutlineSpacing, kAddSize+2*kSubOutlineSpacing);
            CGRectSetCenter(self.dotContainer, kTitleX/2, self.bounds.size.height/2);
            self.dotContainer.layer.cornerRadius = kAddSize/2+kSubOutlineSpacing;
            //self.dotView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
            self.dotView.layer.cornerRadius = kAddSize/2;
            [self.dotView setTitle:iconString(@"editActionRoundedPlus") forState:UIControlStateNormal];
            
        };
    }
    else{
        self.titleField.returnKeyType = UIReturnKeyDone;
        aniblock1 = ^{
            [self.dotView setTitleColor:tcolor(TasksColor) forState:UIControlStateNormal];
            self.dotContainer.transform = CGAffineTransformMakeScale(kDotMultiplier/2, kDotMultiplier/2);
            CGRectSetY(self.seperator, kSubTopHack);
            self.dotView.layer.borderWidth = kLineSize;
            self.dotView.layer.borderColor = tcolor(TasksColor).CGColor;
            //self.dotView.transform = CGAffineTransformMakeScale(0.5, 0.5);
            //self.titleField.textColor = tcolor(TextColor);
            if(animated)
                self.titleField.text = @"";
            self.titleField.font = KP_LIGHT(16);
            self.inEditMode = NO;
        };
        comp1 = ^{
            
            [self.dotView setTitle:@"" forState:UIControlStateNormal];
            self.dotContainer.transform = CGAffineTransformIdentity;
            CGRectSetSize(self.dotContainer, kSubDotSize+2*kSubOutlineSpacing, kSubDotSize+2*kSubOutlineSpacing);
            self.dotView.layer.cornerRadius = kSubDotSize/2;
            self.dotContainer.layer.cornerRadius = kSubDotSize/2+kSubOutlineSpacing;
            CGRectSetCenter(self.dotContainer, kTitleX/2, self.bounds.size.height/2);
        };
    }
    if(!animated){
        aniblock1();
        if(comp1)
            comp1();
    }
    else{
        [UIView animateWithDuration:0.25f
                         animations:aniblock1
         completion:^(BOOL finished) {
            if(comp1)
                comp1();
        }];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(self.addModeForCell){
        if(textField.text.length == 0){
            //[self switchBetweenAddAndEdit:YES animated:YES];
            return YES;
        }
        else{
            [self.subtaskDelegate addedSubtask:textField.text];
            textField.text = @"";
            //[self setAddMode:YES animated:NO];
        }
        return NO;
    }
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    //if(self.titleField.isFirstResponder) [self.titleField resignFirstResponder];
    if([self.subtaskDelegate respondsToSelector:@selector(endedEditingCell:)])
        [self.subtaskDelegate endedEditingCell:self];
    if (self.addModeForCell) {
        [self switchBetweenAddAndEdit:YES animated:YES];
    }
    else
        [self.subtaskDelegate subtaskCell:self editedSubtask:textField.text];
    self.overlayAddbutton.hidden = NO;
}
- ( void )textFieldDidChange: (UITextField *)textField{
    NSString *text = textField.text;
    if(self.addModeForCell){
        self.titleField.returnKeyType = (text.length > 0) ? UIReturnKeyNext : UIReturnKeyDone;
        //[self.titleField resignFirstResponder];
        //[self.titleField becomeFirstResponder];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    self.overlayAddbutton.hidden = YES;
}

-(void)textFieldDidReturn:(UITextField *)textField{

}


-(void)pressedAdd{
    if([self.subtaskDelegate respondsToSelector:@selector(shouldStartEditingSubtaskCell:)]){
        BOOL shouldEdit = [self.subtaskDelegate shouldStartEditingSubtaskCell:self];
        if(!shouldEdit)
            return;
    }
        
    
    if(self.addModeForCell && self.inEditMode)
        [self switchBetweenAddAndEdit:NO animated:YES];
    
    
    if(self.addModeForCell && [self.subtaskDelegate respondsToSelector:@selector(startedAddingSubtaskInCell:)])
        [self.subtaskDelegate startedAddingSubtaskInCell:self];
    else if(!self.addModeForCell && [self.subtaskDelegate respondsToSelector:@selector(startedEditingSubtaskCell:)])
        [self.subtaskDelegate startedEditingSubtaskCell:self];
    [self.titleField becomeFirstResponder];
}
-(void)setDotColor:(UIColor *)color{
    self.dotView.layer.borderColor = color.CGColor;
    self.seperator.backgroundColor = alpha(color,kLineAlpha);
    //self.seperator.backgroundColor = color(161, 163, 165, 0.7);
    //self.dotView.backgroundColor = [color isEqual:tcolor(TasksColor)] ? tcolor(BackgroundColor) : color;
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.contentView.backgroundColor = tcolor(BackgroundColor);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.dotContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSubDotSize+2*kSubOutlineSpacing, kSubDotSize+2*kSubOutlineSpacing)];
        self.dotContainer.backgroundColor = tcolor(BackgroundColor);
        self.dotContainer.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
        self.dotContainer.autoresizesSubviews = YES;
        self.dotView = [[UIButton alloc] initWithFrame:CGRectMake(kSubOutlineSpacing, kSubOutlineSpacing, kSubDotSize, kSubDotSize)];
        self.dotView.backgroundColor = tcolor(BackgroundColor);
        self.dotView.layer.cornerRadius = kSubDotSize/2;
        self.dotView.layer.borderWidth = kLineSize;
        self.dotView.layer.borderColor = tcolor(BackgroundColor).CGColor;
        self.dotView.titleLabel.font = iconFont(kAddSize);
        self.dotView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
        [self.dotView setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [self.dotContainer addSubview:self.dotView];
        
        CGFloat sepWidth = 1;
        UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(kTitleX/2-sepWidth/2, 0 + kSubTopHack, sepWidth, self.bounds.size.height - 2 *kSubTopHack)];
        seperator.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        seperator.backgroundColor = alpha(tcolor(TasksColor),kLineAlpha);
        [self.contentView addSubview:seperator];
        self.seperator = seperator;
        
        [self.contentView addSubview:self.dotContainer];
        CGRectSetCenter(self.dotContainer,kTitleX/2,self.bounds.size.height/2);
        
        self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(kTitleX, 0, self.frame.size.width-kTitleX, self.bounds.size.height)];
        self.titleField.backgroundColor = CLEAR;
        self.titleField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.titleField.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        self.titleField.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.titleField.font = KP_LIGHT(16);
        self.titleField.textColor = tcolor(TextColor);
        self.titleField.delegate = self;
        [self.titleField addTarget:self
                      action:@selector(textFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
        [self.titleField addTarget:self
                      action:@selector(textFieldDidReturn:)
            forControlEvents:UIControlEventEditingDidEndOnExit];
        [self.contentView addSubview:self.titleField];
        
        self.overlayAddbutton = [[UIButton alloc] initWithFrame:self.bounds];
        self.overlayAddbutton.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
        self.overlayAddbutton.backgroundColor = CLEAR;
        [self.overlayAddbutton addTarget:self action:@selector(pressedAdd) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.overlayAddbutton];

    }
    return self;
}

@end