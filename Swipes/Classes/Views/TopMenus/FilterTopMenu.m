//
//  FilterTopMenu.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 11/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#import "SlowHighlightIcon.h"
#import "KPTagList.h"
#import "FilterTopMenu.h"

@implementation FilterTopMenu
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = tcolor(BackgroundColor);
        
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
        
        KPTagList *tagList = [[KPTagList alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        tagList.emptyText = @"No tags assigned";
        tagList.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //UIColor *tagColor = gray(0,1);
        //tagList.tagBackgroundColor = CLEAR;
        //tagList.selectedTagBackgroundColor = tagColor;
        //tagList.tagBorderColor = tagColor;
        //tagList.tagTitleColor = tagColor;
        //tagList.selectedTagTitleColor = tcolor(TextColor);
        tagList.spacing = 8;
        tagList.marginLeft = tagList.spacing;
        tagList.marginTop = (14+tagList.spacing)/2;
        tagList.emptyLabelMarginHack = 10;
        tagList.firstRowSpacingHack = 44;
        tagList.bottomMargin = (16+tagList.spacing)/2;
        tagList.marginRight = tagList.spacing;
        [self addSubview:tagList];
        self.tagListView = tagList;
    }
    return self;
}
-(void)dealloc{
    self.tagListView = nil;
    self.closeButton = nil;
}
@end
