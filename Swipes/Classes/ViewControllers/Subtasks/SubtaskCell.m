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
#define kTitleX 46

@interface SubtaskCell () <UITextFieldDelegate>
@property (nonatomic) UIButton *dotView;
@property (nonatomic) UIButton *addCloseButton;
@property (nonatomic) UIButton *overlayAddbutton;
@end

@implementation SubtaskCell
-(void)setAddMode:(BOOL)addMode{
    if(_addMode != addMode){
        _addMode = addMode;
    }
    [self setAddMode:addMode animated:NO];
    
}

-(void)setModel:(KPToDo *)model{
    if(_model != model){
        _model = model;
    }
}


-(void)setTitle:(NSString *)title{
    self.titleField.text = title;
}
-(void)setAddMode:(BOOL)addMode animated:(BOOL)animated{
    voidBlock aniblock1;
    voidBlock comp1;
    voidBlock aniblock2;
    //self.overlayAddbutton.hidden = !addMode;
    if(addMode){
        aniblock1 = ^{
            self.dotView.transform = CGAffineTransformMakeScale(2, 2);
            self.dotView.layer.borderWidth = (float)kLineSize/4;
            self.titleField.text = @"Add new";
        };
        comp1 = ^{
            [self.dotView setImage:[UIImage imageNamed:@"subtasks_plus"] forState:UIControlStateNormal];
            self.dotView.transform = CGAffineTransformIdentity;
            CGRectSetSize(self.dotView, kAddSize, kAddSize);
            self.dotView.layer.cornerRadius = kAddSize/2;
            CGRectSetCenter(self.dotView,kTitleX/2,self.bounds.size.height/2);
        };
        aniblock2 = ^{
            self.dotView.layer.borderColor = gray(27, 1).CGColor;
        };
    }
    else{
        aniblock1 = ^{
            self.dotView.transform = CGAffineTransformMakeScale(0.5, 0.5);
            if(animated) self.titleField.text = @"";
        };
        comp1 = ^{
            [self.dotView setImage:nil forState:UIControlStateNormal];
            self.dotView.transform = CGAffineTransformIdentity;
            //self.dotView.layer.cornerRadius = kSubDotSize/2;
            CGRectSetSize(self.dotView, kSubDotSize, kSubDotSize);
            CGRectSetCenter(self.dotView,kTitleX/2,self.bounds.size.height/2);
        };
        aniblock2 = ^{
            self.dotView.layer.borderWidth = kLineSize;
            self.dotView.layer.borderColor = tcolor(TasksColor).CGColor;
            self.dotView.backgroundColor = tcolor(TasksColor);
        };
        
        
    }
    if(!animated){
        aniblock1();
        comp1();
        aniblock2();
    }
    else{
        [UIView animateWithDuration:0.5
                         animations:^{
            aniblock1();
        } completion:^(BOOL finished) {
            comp1();
            [UIView animateWithDuration:0.5 animations:^{
                aniblock2();
            }];
        }];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(self.addMode){
        if(textField.text.length == 0){
            [self setAddMode:YES animated:YES];
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
}
-(void)textFieldDidReturn:(UITextField *)textField{
    //if(self.titleField.isFirstResponder) [self.titleField resignFirstResponder];
    
    if(!self.addMode)
        [self.subtaskDelegate subtaskCell:self editedSubtask:textField.text];
}
-(void)pressedAdd{
    if(self.addMode)
        [self setAddMode:NO animated:YES];
    [self.titleField becomeFirstResponder];
}
-(void)setDotColor:(UIColor *)color{
    self.dotView.layer.borderColor = color.CGColor;
    self.dotView.backgroundColor = color;
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.contentView.backgroundColor = tcolor(BackgroundColor);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.dotView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kSubDotSize, kSubDotSize)];
        self.dotView.backgroundColor = CLEAR;
        //self.dotView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
        //self.dotView.layer.cornerRadius = kSubDotSize/2;
        //self.dotView.layer.borderWidth = kLineSize;
        
        //self.dotView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin);
        CGRectSetCenter(self.dotView,kTitleX/2,self.bounds.size.height/2);
        [self.contentView addSubview:self.dotView];
        
        self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(kTitleX, 0, 320-kTitleX, self.bounds.size.height)];
        self.titleField.backgroundColor = CLEAR;
        self.titleField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
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
        /*
        CGFloat closeButtonSize = self.bounds.size.height;
        self.addCloseButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-closeButtonSize, 0, closeButtonSize, closeButtonSize)];
        [self.addCloseButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];*/
        
        //self.overlayAddbutton.hidden = YES;
    }
    return self;
}

@end