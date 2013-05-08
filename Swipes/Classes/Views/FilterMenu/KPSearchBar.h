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
    KPSearchBarModeTags
};
@protocol KPSearchBarDataSource <NSObject>
-(NSArray*)unselectedTagsForSearchBar:(KPSearchBar*)searchBar;
-(NSArray*)selectedTagsForSearchBar:(KPSearchBar*)searchBar;
@end
@protocol KPSearchBarDelegate <NSObject>
-(void)searchBar:(KPSearchBar*)searchBar pressedFilterButton:(UIButton*)filterButton;
-(void)clearedAllFiltersForSearchBar:(KPSearchBar*)searchBar;
-(void)searchBar:(KPSearchBar*)searchBar selectedTag:(NSString*)tag;
-(void)searchBar:(KPSearchBar*)searchBar deselectedTag:(NSString *)tag;
@end

@interface KPSearchBar : UISearchBar
@property (nonatomic,weak) NSObject<KPSearchBarDelegate> *searchBarDelegate;
@property (nonatomic,weak) NSObject<KPSearchBarDataSource> *searchBarDataSource;
@property (nonatomic) KPSearchBarMode currentMode;
@property (nonatomic) CellType cellType;
-(id)initWithCellType:(CellType)cellType frame:(CGRect)frame;
@end
