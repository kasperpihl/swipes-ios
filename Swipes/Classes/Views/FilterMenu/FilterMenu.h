//
//  FilterMenu.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#import <UIKit/UIKit.h>
#define DEFAULT_MAX_WIDTH 280
@class FilterMenu;
@protocol FilterMenuDataSource <NSObject>
-(NSArray*)unselectedTagsForFilterMenu:(FilterMenu*)filterMenu;
-(NSArray*)selectedTagsForFilterMenu:(FilterMenu*)filterMenu;
@end
@protocol FilterMenuDelegate <NSObject>
-(void)clearedAllFiltersForFilterMenu:(FilterMenu*)filterMenu;
-(void)filterMenu:(FilterMenu*)filterMenu selectedTag:(NSString*)tag;
-(void)filterMenu:(FilterMenu *)filterMenu deselectedTag:(NSString *)tag;
@end



typedef enum {
    MLPopupMenuUp = 0,
    MLPopupMenuDown = 1
} MLPopupDirection;

@interface FilterMenu : UIView
@property (nonatomic,weak) NSObject<FilterMenuDataSource> *dataSource;
@property (nonatomic,weak) NSObject<FilterMenuDelegate> *delegate;

@property (nonatomic, assign) BOOL isPopped;
@property (nonatomic) NSInteger maxWidth;
+(FilterMenu*)filterMenuWithUnselectedTags:(NSArray *)tags selectedTags:(NSArray*)selectedTags;
- (void)popInWithEvent:(UIEvent*)event;
- (void)hide;
@end