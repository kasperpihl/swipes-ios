//
//  SelectionTopMenu.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 08/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "TopMenu.h"
@class SelectionTopMenu;
@protocol SelectionTopMenuDelegate <NSObject>
-(void)didPressAllInSelectionTopMenu:(SelectionTopMenu*)topMenu;
-(void)didPressHelpLabelInSelectionTopMenu:(SelectionTopMenu*)topMenu;
-(void)didPressCloseInSelectionTopMenu:(SelectionTopMenu*)topMenu;
@end

@interface SelectionTopMenu : TopMenu
@property (nonatomic) IBOutlet UIButton *allButton;
@property (nonatomic) IBOutlet UIButton *helpButton;
@property (nonatomic) IBOutlet UIButton *closeButton;

@property (nonatomic,weak) NSObject <SelectionTopMenuDelegate> *selectionDelegate;
@end