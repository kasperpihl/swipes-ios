//
//  SearchTopMenu.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 10/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "SlowHighlightIcon.h"
#import "SearchTopMenu.h"

@interface SearchTopMenu () <UITextFieldDelegate>
@end

@implementation SearchTopMenu
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = CLEAR;
        CGFloat topY = 4;//kTopY;
        UIView *gradientBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, topY)];
        gradientBackground.backgroundColor = CLEAR;
        CAGradientLayer *agradient = [CAGradientLayer layer];
        agradient.frame = gradientBackground.bounds;
        gradientBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        agradient.colors = @[(id)alpha(tcolor(TextColor),0.0f).CGColor,(id)alpha(tcolor(TextColor),0.2f).CGColor,(id)alpha(tcolor(TextColor),0.4f).CGColor];
        agradient.locations = @[@0.0,@0.5,@1.0];
        [gradientBackground.layer insertSublayer:agradient atIndex:0];
        [self addSubview:gradientBackground];
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, topY, self.frame.size.width, self.frame.size.height-topY)];
        background.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        background.backgroundColor = tcolor(BackgroundColor);
        [self addSubview:background];
        
        self.searchField = [[UITextField alloc] initWithFrame:CGRectMake(TEXT_FIELD_MARGIN_LEFT, topY, self.frame.size.width-TEXT_FIELD_MARGIN_LEFT - kSideButtonsWidth, self.frame.size.height - topY)];
        self.searchField.font = TEXT_FIELD_FONT;
        self.searchField.textColor = tcolor(TextColor);
        self.searchField.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.searchField.returnKeyType = UIReturnKeySearch;
        self.searchField.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        self.searchField.placeholder = LOCALIZE_STRING(@"Search");
        self.searchField.borderStyle = UITextBorderStyleNone;
        self.searchField.delegate = self;
        self.searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        @try {
            self.backgroundColor = tcolor(BackgroundColor);
            [self.searchField setValue:tcolor(TextColor) forKeyPath:@"_placeholderLabel.textColor"];
        }
        @catch (NSException *exception) {
            
        }
        self.searchField.userInteractionEnabled = YES;
        //[self.searchField addTarget:self action:@selector(startedSearch:) forControlEvents:UIControlEventEditingDidBegin];
        [self.searchField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:self.searchField];
        
        
        UIButton *closeButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(frame.size.width-kSideButtonsWidth, topY, kSideButtonsWidth, frame.size.height-topY);
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
        closeButton.titleLabel.font = iconFont(23);
        [closeButton setTitle:iconString(@"plusThick") forState:UIControlStateNormal];
        closeButton.transform = CGAffineTransformMakeRotation(M_PI/2/2);
        [closeButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        self.closeButton = closeButton;
        
    }
    return self;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField.isFirstResponder)
        [textField resignFirstResponder];
    [self.searchDelegate didCloseSearchFieldTopMenu:self];
    return YES;
}
-(void)textFieldChanged:(UITextField*)sender{
    if([self.searchDelegate respondsToSelector:@selector(searchTopMenu:didSearchForString:)])
        [self.searchDelegate searchTopMenu:self didSearchForString:sender.text];
}
-(void)onClose:(UIButton*)closeButton{
    [self.searchDelegate didClearSearchTopMenu:self];
}

@end
