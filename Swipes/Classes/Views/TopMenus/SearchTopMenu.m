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
        self.backgroundColor = tcolor(BackgroundColor);
        
        self.searchField = [[UITextField alloc] initWithFrame:CGRectMake(TEXT_FIELD_MARGIN_LEFT, kTopY, self.frame.size.width-TEXT_FIELD_MARGIN_LEFT - kSideButtonsWidth, self.frame.size.height - kTopY)];
        self.searchField.font = TEXT_FIELD_FONT;
        self.searchField.textColor = tcolor(TextColor);
        self.searchField.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.searchField.returnKeyType = UIReturnKeySearch;
        self.searchField.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        self.searchField.placeholder = @"Search";
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
        closeButton.frame = CGRectMake(frame.size.width-kSideButtonsWidth, kTopY, kSideButtonsWidth, frame.size.height-kTopY);
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
        closeButton.titleLabel.font = iconFont(23);
        [closeButton setTitle:iconString(@"roundClose") forState:UIControlStateNormal];
        [closeButton setTitle:iconString(@"roundCloseFull") forState:UIControlStateHighlighted];
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
