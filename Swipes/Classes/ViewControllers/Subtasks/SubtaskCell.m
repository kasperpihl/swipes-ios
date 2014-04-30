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
#define kSubDotSize 8
#define kAddSize (kSubDotSize*2)
#define kLineSize 2
#define kTitleX CELL_LABEL_X

@interface SubtaskCell () <UITextFieldDelegate>
@property (nonatomic) UIButton *dotView;
@property (nonatomic) UIButton *addCloseButton;
@property (nonatomic) UIButton *overlayAddbutton;
@property BOOL inEditMode;
@end

@implementation SubtaskCell
-(void)setAddModeForCell:(BOOL)addModeForCell{
    if(_addModeForCell != addModeForCell){
        _addModeForCell = addModeForCell;
    }
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
            self.dotView.backgroundColor = tcolor(TextColor);
            self.titleField.text = @"Add action step";
            self.titleField.font = KP_REGULAR(12);
            self.inEditMode = YES;
        };
    }
    else{
        aniblock1 = ^{
            self.dotView.backgroundColor = tcolor(TasksColor);
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
    if (self.addModeForCell) {
        [self switchBetweenAddAndEdit:YES animated:YES];
    }
}
-(void)textFieldDidReturn:(UITextField *)textField{
    //if(self.titleField.isFirstResponder) [self.titleField resignFirstResponder];
    
    if(!self.addModeForCell)
        [self.subtaskDelegate subtaskCell:self editedSubtask:textField.text];
}
-(void)pressedAdd{
    if(self.addModeForCell && self.inEditMode)
        [self switchBetweenAddAndEdit:NO animated:YES];
    [self.titleField becomeFirstResponder];
}
-(void)setDotColor:(UIColor *)color{
    self.dotView.backgroundColor = color;
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.contentView.backgroundColor = tcolor(BackgroundColor);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.dotView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kSubDotSize, kSubDotSize)];
        self.dotView.backgroundColor = CLEAR;
        self.dotView.titleLabel.font = iconFont(kAddSize);
        self.dotView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
        //[self.dotView setTitle:@"plus" forState:UIControlStateNormal];
        //[self.dotView setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];

        
        CGRectSetCenter(self.dotView,kTitleX/2,self.bounds.size.height/2);
        [self.contentView addSubview:self.dotView];
        
        self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(kTitleX, 0, self.frame.size.width-kTitleX, self.bounds.size.height)];
        self.titleField.backgroundColor = CLEAR;
        self.titleField.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
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