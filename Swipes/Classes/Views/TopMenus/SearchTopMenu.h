//
//  SearchTopMenu.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 10/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "TopMenu.h"
@class SearchTopMenu;
@protocol SearchTopMenuDelegate <NSObject>
-(void)searchTopMenu:(SearchTopMenu*)topMenu didSearchForString:(NSString*)searchString;
-(void)didClearSearchTopMenu:(SearchTopMenu*)topMenu;
-(void)didCloseSearchFieldTopMenu:(SearchTopMenu*)topMenu;
@end

@interface SearchTopMenu : TopMenu
@property (nonatomic) IBOutlet UITextField *searchField;
@property (nonatomic) UIButton *clearButton;
@property (nonatomic) IBOutlet UIButton *closeButton;

@property (nonatomic,weak) NSObject<SearchTopMenuDelegate> *searchDelegate;
@end
