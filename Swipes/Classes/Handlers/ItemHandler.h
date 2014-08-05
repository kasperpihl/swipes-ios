//
//  FilterHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KPSearchBar.h"
#import "KPToDo.h"
@class ItemHandler;
@protocol ItemHandlerDelegate <NSObject>
-(UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
-(void)didUpdateItemHandler:(ItemHandler*)handler;
-(NSString *)itemHandler:(ItemHandler*)handler titleForItem:(KPToDo*)item;
-(NSArray*)itemsForItemHandler:(ItemHandler*)handler;
-(void)itemHandler:(ItemHandler*)handler changedItemNumber:(NSInteger)itemNumber oldNumber:(NSInteger)oldNumber;
@end

@interface ItemHandler : NSObject  <KPSearchBarDataSource,UITableViewDataSource>
@property (nonatomic,weak) id<ItemHandlerDelegate> delegate;
@property (nonatomic,strong) NSArray *allTags;
@property (nonatomic,strong) NSArray *remainingTags;
@property (nonatomic,strong) NSMutableArray *selectedTags;
@property (nonatomic) BOOL hasFilter;
@property (nonatomic) BOOL hasSearched;
@property (nonatomic) BOOL isSorted;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *filteredItems;
@property (nonatomic) NSIndexPath *draggingIndexPath;
@property (nonatomic) NSInteger itemCounter;
@property (nonatomic) NSInteger itemCounterWithFilter;
-(void)setItems:(NSArray*)items;
-(void)selectTag:(NSString*)tag;
-(void)deselectTag:(NSString*)tag;
-(void)searchForString:(NSString*)string;
-(void)clearAll;
-(NSString *)titleForSection:(NSInteger)section;
-(NSInteger)totalNumberOfItemsBeforeItem:(KPToDo*)item;
-(NSIndexPath*)indexPathForItem:(KPToDo*)item;
-(KPToDo*)itemForIndexPath:(NSIndexPath*)indexPath;
-(void)addItem:(NSString *)item priority:(BOOL)priority tags:(NSArray *)tags;
-(void)reloadData;
-(void)refresh;
-(NSIndexSet*)removeItems:(NSArray*)items;
-(void)moveItem:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath;
@end
