//
//  FilterTopMenu.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 11/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "TopMenu.h"
@class FilterTopMenu;

@protocol FilterTopMenuDataSource <NSObject>
-(NSArray*)unselectedTagsForFilterTopMenu:(FilterTopMenu*)topMenu;
-(NSArray*)selectedTagsForFilterTopMenu:(FilterTopMenu*)topMenu;
@end

@protocol FilterTopMenuDelegate <NSObject>
-(void)didClearFilterTopMenu:(FilterTopMenu*)topMenu;
-(void)filterMenu:(FilterTopMenu*)filterMenu selectedTag:(NSString*)tag;
-(void)filterMenu:(FilterTopMenu*)filterMenu deselectedTag:(NSString *)tag;
@end
@class KPTagList;
@interface FilterTopMenu : TopMenu
@property (nonatomic) IBOutlet UIButton *closeButton;
@property (nonatomic,weak) id<FilterTopMenuDelegate> filterDelegate;
@property (nonatomic,weak) id<FilterTopMenuDataSource> tagsDataSource;
@property (nonatomic, weak) KPTagList *tagListView;
@end
