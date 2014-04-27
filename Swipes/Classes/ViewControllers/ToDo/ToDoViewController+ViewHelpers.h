//
//  ToDoViewController+ViewHelpers.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 27/01/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "ToDoViewController.h"

@interface ToDoViewController (ViewHelpers)
-(UILabel *)addAndGetImage:(NSString*)imageName inView:(UIView*)view;
-(UIButton*)addClickButtonToView:(UIView*)view action:(SEL)action;
-(void)addSeperatorToView:(UIView*)view;
@end
