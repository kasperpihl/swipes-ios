//
//  SelectionTopMenu.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 08/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "SelectionTopMenu.h"
#define kSideButtonsWidth 50
@interface SelectionTopMenu ()
@end
@implementation SelectionTopMenu
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        UIButton *allButton = [UIButton buttonWithType:UIButtonTypeCustom];
        allButton.frame = CGRectMake(0, 0, kSideButtonsWidth, frame.size.height);
        allButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        allButton.titleLabel.font = KP_REGULAR(16);
        [allButton setTitle:@"All" forState:UIControlStateNormal];
        [self addSubview:allButton];
        self.allButton = allButton;
        
        UILabel *helpLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSideButtonsWidth, 0, frame.size.width-2*kSideButtonsWidth, frame.size.height)];
        helpLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        helpLabel.font = KP_REGULAR(15);
        helpLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:helpLabel];
        self.helpLabel = helpLabel;
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(frame.size.width-kSideButtonsWidth, 0, kSideButtonsWidth, frame.size.height);
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
        closeButton.titleLabel.font = iconFont(23);
        [closeButton setTitle:iconString(@"roundClose") forState:UIControlStateNormal];
        [self addSubview:closeButton];
        self.closeButton = closeButton;
    }
    return self;
}
-(void)setHelpLabelText:(NSString *)text{
    
}

#pragma mark IBActions
-(void)onAll:(UIButton*)allButton{
    [self.delegate didPressAllInTopMenu:self];
}
-(void)onClose:(UIButton*)closeButton{
    [self.delegate didPressCloseInTopMenu:self];
}



#pragma mark UIView
-(void)dealloc{
    self.allButton = nil;
    self.helpLabel = nil;
    self.closeButton = nil;
}
@end
