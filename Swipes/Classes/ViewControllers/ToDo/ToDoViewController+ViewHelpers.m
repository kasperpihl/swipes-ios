//
//  ToDoViewController+ViewHelpers.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 27/01/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#define LABEL_X CELL_LABEL_X
#import "ToDoViewController+ViewHelpers.h"
#import "UIColor+Utilities.h"
@implementation ToDoViewController (ViewHelpers)
-(UILabel *)addAndGetImage:(NSString*)imageName inView:(UIView*)view{
    UILabel *icon = iconLabel(imageName, 15);
    [icon setTextColor:tcolor(TextColor)];
    icon.frame = CGRectSetPos(icon.frame,(LABEL_X-icon.frame.size.width)/2, (view.frame.size.height-icon.frame.size.height)/2);
    icon.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [view addSubview:icon];
    return icon;
}
-(UIButton*)addClickButtonToView:(UIView*)view action:(SEL)action{
    UIButton *clickedButton = [[UIButton alloc] initWithFrame:view.bounds];
    clickedButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
    [clickedButton setBackgroundImage:[color(55,55,55,0.1) image] forState:UIControlStateHighlighted];
    //clickedButton.contentEdgeInsets = UIEdgeInsetsMake(0, LABEL_X, 0, LABEL_X/3);
    [clickedButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:clickedButton];
    return clickedButton;
}
-(void)addSeperatorToView:(UIView*)view{
    CGFloat seperatorHeight = 1;
    CGFloat leftMargin = LABEL_X;
    CGFloat rightMargin = LABEL_X/3;
    
    UIView *seperator2View = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, 0, view.frame.size.width-rightMargin-leftMargin, seperatorHeight)];
    UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, view.frame.size.height-seperatorHeight, view.frame.size.width-rightMargin-leftMargin, seperatorHeight)];
    seperatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    seperator2View.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    seperatorView.backgroundColor = seperator2View.backgroundColor = tcolor(BackgroundColor);
    [view addSubview:seperatorView];
    [view addSubview:seperator2View];
}
@end
