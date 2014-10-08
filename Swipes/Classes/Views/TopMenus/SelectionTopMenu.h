//
//  SelectionTopMenu.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 08/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SelectionTopMenu;
@protocol SelectionTopMenuDelegate <NSObject>
-(void)didPressAllInTopMenu:(SelectionTopMenu*)topMenu;
-(void)didPressCloseInTopMenu:(SelectionTopMenu*)topMenu;
@end

@interface SelectionTopMenu : UIView
@property (nonatomic) IBOutlet UIButton *allButton;
@property (nonatomic) IBOutlet UILabel *helpLabel;
@property (nonatomic) IBOutlet UIButton *closeButton;

@property (nonatomic,weak) NSObject <SelectionTopMenuDelegate> *delegate;

-(void)setHelpLabelText:(NSString*)text;
@end