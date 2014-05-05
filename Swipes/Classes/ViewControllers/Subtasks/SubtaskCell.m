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
#define kSubDotSize 10
#define kAddSize (kSubDotSize*2)
#define kLineSize 1.5
#define kTitleX CELL_LABEL_X

@interface SubtaskCell () <UITextFieldDelegate>
@property (nonatomic) UIButton *dotView;
@property (nonatomic) UIButton *addCloseButton;
@property (nonatomic) UIButton *overlayAddbutton;
@property (nonatomic) UIView *seperator;
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
        aniblock1 = ^{
            self.dotView.layer.borderColor = tcolor(TextColor).CGColor;
            self.titleField.text = @"Add action step";
            self.titleField.font = EDIT_TASK_TEXT_FONT;
            self.inEditMode = YES;
            CGRectSetHeight(self.seperator, self.bounds.size.height/2);
        };
    }
    else{
        aniblock1 = ^{
            self.dotView.layer.borderColor = tcolor(TasksColor).CGColor;
            //self.dotView.transform = CGAffineTransformMakeScale(0.5, 0.5);
            if(animated)
                self.titleField.text = @"";
            self.titleField.font = KP_LIGHT(16);
            self.inEditMode = NO;
        };
    }
    if(!animated){
        aniblock1();
        if(comp1)
            comp1();
    }
    else{
        [UIView animateWithDuration:0.5
                         animations:^{
            aniblock1();
        } completion:^(BOOL finished) {
            if(comp1)
                comp1();
        }];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(self.addModeForCell){
        if(textField.text.length == 0){
            [self switchBetweenAddAndEdit:YES animated:YES];
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
    NSLog(@"ended editing");
    if (self.addModeForCell) {
        [self switchBetweenAddAndEdit:YES animated:YES];
    }
    else
        [self.subtaskDelegate subtaskCell:self editedSubtask:textField.text];
}
-(void)textFieldDidReturn:(UITextField *)textField{
    
}

-(void)pressedAdd{
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
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.contentView.backgroundColor = tcolor(BackgroundColor);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.dotView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kSubDotSize, kSubDotSize)];
        self.dotView.backgroundColor = tcolor(BackgroundColor);
        self.dotView.layer.cornerRadius = kSubDotSize/2;
        self.dotView.layer.borderWidth = kLineSize;
        self.dotView.layer.borderColor = tcolor(BackgroundColor).CGColor;
        self.dotView.titleLabel.font = iconFont(kAddSize);
        self.dotView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
        //[self.dotView setTitle:@"plus" forState:UIControlStateNormal];
        //[self.dotView setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];

        
        CGFloat sepWidth = 1;
        UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(kTitleX/2-sepWidth/2, 0, sepWidth, self.bounds.size.height)];
        seperator.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        seperator.backgroundColor = alpha(tcolor(TextColor),0.5);
        [self.contentView addSubview:seperator];
        self.seperator = seperator;
        
        CGRectSetCenter(self.dotView,kTitleX/2,self.bounds.size.height/2);
        [self.contentView addSubview:self.dotView];
        
        self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(kTitleX, 0, self.frame.size.width-kTitleX, self.bounds.size.height)];
        self.titleField.backgroundColor = CLEAR;
        self.titleField.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        self.titleField.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.titleField.font = KP_LIGHT(16);
        self.titleField.textColor = tcolor(TextColor);
        self.titleField.delegate = self;
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