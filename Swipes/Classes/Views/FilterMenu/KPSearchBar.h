//
//  KPSearchBar.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 02/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KPSearchBar;
typedef NS_ENUM(NSUInteger, KPSearchBarMode) {
    KPSearchBarModeNone,
    KPSearchBarModeSearch,
    KPSearchBarModeTags
};
@protocol KPSearchBarDataSource <NSObject>
-(NSArray*)unselectedTagsForSearchBar:(KPSearchBar*)searchBar;
-(NSArray*)selectedTagsForSearchBar:(KPSearchBar*)searchBar;
@end
@protocol KPSearchBarDelegate <NSObject>
-(void)clearedAllFiltersForSearchBar:(KPSearchBar*)searchBar;
-(void)startedSearchBar:(KPSearchBar*)searchBar;
-(void)searchBar:(KPSearchBar*)searchBar selectedTag:(NSString*)tag;
-(void)searchBar:(KPSearchBar*)searchBar deselectedTag:(NSString *)tag;
-(void)searchBar:(KPSearchBar *)searchBar searchedForString:(NSString*)searchString;
@end
@class KPTagList;
@interface KPSearchBar : UIView
@property (nonatomic, weak) id<KPSearchBarDelegate> searchBarDelegate;
@property (nonatomic, weak) id<KPSearchBarDataSource> searchBarDataSource;
@property (nonatomic, assign) KPSearchBarMode currentMode;
@property (nonatomic, strong) UIColor *openBackgroundColor;
@property (nonatomic, weak) KPTagList *tagListView;
//-(void)resignSearchField;
-(void)reloadDataAndUpdate:(BOOL)update;
@end
