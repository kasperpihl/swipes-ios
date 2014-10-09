//
//  SelectionTopMenu.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 08/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "SelectionTopMenu.h"
#import "SlowHighlightIcon.h"
#define kSideButtonsWidth 60
#define kTopY 20
@interface SelectionTopMenu ()

@end
@implementation SelectionTopMenu
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        UIButton *allButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
        allButton.frame = CGRectMake(0, kTopY, kSideButtonsWidth, frame.size.height-kTopY);
        allButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        allButton.titleLabel.font = KP_REGULAR(16);
        [allButton setTitle:@"All" forState:UIControlStateNormal];
        [allButton addTarget:self action:@selector(onAll:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:allButton];
        self.allButton = allButton;
        
        UIButton *helpButton = [[UIButton alloc] initWithFrame:CGRectMake(kSideButtonsWidth, kTopY, frame.size.width-2*kSideButtonsWidth, frame.size.height-kTopY)];
        helpButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        helpButton.titleLabel.font = KP_BOLD(16);
        [helpButton addTarget:self action:@selector(onHelpButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:helpButton];
        self.helpButton = helpButton;
        
        UIButton *closeButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(frame.size.width-kSideButtonsWidth, kTopY, kSideButtonsWidth, frame.size.height-kTopY);
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
        closeButton.titleLabel.font = iconFont(23);
        [closeButton setTitle:iconString(@"roundClose") forState:UIControlStateNormal];
        [closeButton setTitle:iconString(@"roundCloseFull") forState:UIControlStateHighlighted];
        [closeButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        self.closeButton = closeButton;
    }
    return self;
}

#pragma mark IBActions
-(void)onAll:(UIButton*)allButton{
    [self.selectionDelegate didPressAllInSelectionTopMenu:self];
}
-(void)onClose:(UIButton*)closeButton{
    [self.selectionDelegate didPressCloseInSelectionTopMenu:self];
}
-(void)onHelpButton:(UIButton*)helpButton{
    [self.selectionDelegate didPressHelpLabelInSelectionTopMenu:self];
}


#pragma mark UIView
-(void)dealloc{
    self.allButton = nil;
    self.helpButton = nil;
    self.closeButton = nil;
}
@end
