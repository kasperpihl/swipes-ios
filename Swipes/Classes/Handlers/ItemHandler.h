//
//  FilterHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KPToDo.h"
#import "KPFilter.h"

@class ItemHandler;
@protocol KPFilterDelegate;

@protocol ItemHandlerDelegate <NSObject>
-(UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
-(void)didUpdateItemHandler:(ItemHandler*)handler;
-(NSString *)itemHandler:(ItemHandler*)handler titleForItem:(KPToDo*)item;
-(NSArray*)itemsForItemHandler:(ItemHandler*)handler;
-(void)itemHandler:(ItemHandler*)handler changedItemNumber:(NSInteger)itemNumber oldNumber:(NSInteger)oldNumber;
@end

@interface ItemHandler : NSObject  <UITableViewDataSource,KPFilterDelegate>
@property (nonatomic,weak) id<ItemHandlerDelegate> delegate;
@property (nonatomic,strong) NSArray *allTags;
@property (nonatomic,strong) NSArray *remainingTags;
@property (nonatomic) BOOL isSorted;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *filteredItems;
@property (nonatomic) NSIndexPath *draggingIndexPath;
@property (nonatomic) NSInteger itemCounter;
@property (nonatomic) NSInteger itemCounterWithFilter;
-(void)setItems:(NSArray*)items;
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
