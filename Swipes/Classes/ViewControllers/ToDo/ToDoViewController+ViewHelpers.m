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
-(UIImageView *)addAndGetImage:(NSString*)imageName inView:(UIView*)view{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.image = [UIImage imageNamed:imageName];//[UtilityClass imageNamed: withColor:EDIT_TASK_GRAYED_OUT_TEXT];
    imageView.frame = CGRectSetPos(imageView.frame,(LABEL_X-imageView.frame.size.width)/2, (view.frame.size.height-imageView.frame.size.height)/2);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    //imageView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
    [view addSubview:imageView];
    return imageView;
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
