//
//  ItemHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ItemHandler.h"
#import "TagHandler.h"

@interface ItemHandler ()
@property (nonatomic,strong) NSMutableArray *titleArray;
@property (nonatomic,strong) NSMutableArray *sortedItems;
@property (nonatomic,strong) NSArray *items;
@property (nonatomic,strong) NSArray *filteredItems;
@end
@implementation ItemHandler
-(id)init{
    self = [super init];
    if(self){
        self.itemCounter = -1;
    }
    return self;
}
#pragma mark - Getters and Setters
-(NSMutableArray *)selectedTags{
    if(!_selectedTags) _selectedTags = [NSMutableArray array];
    return _selectedTags;
}
-(void)setItems:(NSArray *)items{
    _items = items;
    self.itemCounter = items.count;
    self.allTags = [self extractTags];
    [self runSort];
}
-(void)setItemCounter:(NSInteger)itemCounter{
    if(itemCounter != _itemCounter){
        _itemCounter = itemCounter;
        if([self.delegate respondsToSelector:@selector(itemHandler:changedItemNumber:)]) 
            [self.delegate itemHandler:self changedItemNumber:itemCounter];
    }
}
-(void)addItem:(NSString *)item{
    [TODOHANDLER addItem:item];
    [self reloadData];
}
-(void)reloadData{
    [self fetchData];
    [self notifyUpdate];
}
-(void)fetchData{
    NSArray *items;
    if([self.delegate respondsToSelector:@selector(itemsForItemHandler:)]) items = [self.delegate itemsForItemHandler:self];
    if(items) [self setItems:items];
}
-(void)notifyUpdate{
    if([self.delegate respondsToSelector:@selector(didUpdateItemHandler:)]) [self.delegate didUpdateItemHandler:self];
}

-(void)moveItem:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    if(toIndexPath.row == fromIndexPath.row) return;
    if(!self.isSorted){
        KPToDo *movingToDoObject = [self itemForIndexPath:fromIndexPath];
        KPToDo *replacingToDoObject = [self itemForIndexPath:toIndexPath];
        [movingToDoObject changeToOrder:replacingToDoObject.orderValue];
        NSMutableArray *newItems = [NSMutableArray array];
        for(NSInteger i = 0 ; i < self.items.count ; i++){
            KPToDo *item = [self.items objectAtIndex:i];
            if(i == fromIndexPath.row) continue;
            
            if(i == toIndexPath.row){
                if(toIndexPath.row > fromIndexPath.row) [newItems addObject:item];
                [newItems addObject:movingToDoObject];
                if(toIndexPath.row < fromIndexPath.row) [newItems addObject:item];
            }
            else [newItems addObject:item];
        }
        [self setItems:[newItems copy]];
        [self notifyUpdate];
    }
}
-(void)selectTag:(NSString *)tag{
    if(![self.selectedTags containsObject:tag]){
        [self.selectedTags addObject:tag];
        [self runSort];
        [self notifyUpdate];
    }
}
-(void)deselectTag:(NSString *)tag{
    if([self.selectedTags containsObject:tag]){
        [self.selectedTags removeObject:tag];
        [self runSort];
        [self notifyUpdate];
    }    
}
-(void)clearAll{
    [self.selectedTags removeAllObjects];
    [self runSort];
    [self notifyUpdate];
}
#pragma mark - KPSearchBarDataSource
-(NSArray *)unselectedTagsForSearchBar:(KPSearchBar *)searchBar{
    return self.remainingTags;
}
-(NSArray *)selectedTagsForSearchBar:(KPSearchBar *)searchBar{
    return [self.selectedTags copy];
}
#pragma mark UITableViewDataSource
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.delegate cellForRowAtIndexPath:indexPath];
}
-(KPToDo *)itemForIndexPath:(NSIndexPath *)indexPath{
    if(self.isSorted){
        KPToDo *toDo = [[self.sortedItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        return toDo;
    }
    return [self.filteredItems objectAtIndex:indexPath.row];
}
-(NSString *)titleForSection:(NSInteger)section{
    return [self.titleArray objectAtIndex:section];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.isSorted) return [self.sortedItems count];
    else return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.isSorted){
        NSArray *itemsForSection = [self.sortedItems objectAtIndex:section];
        return itemsForSection.count;
    }
    return self.filteredItems.count;
}
#pragma mark Sort Handling
-(NSArray*)extractTags{
    NSArray *tagArray = [NSArray array];
    NSMutableSet *tagSet = [NSMutableSet set];
    for(KPToDo *toDo in self.items){
        [tagSet addObjectsFromArray:toDo.textTags];
    }
    tagArray = [[tagSet allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return tagArray;
}
-(void)runSort{
    self.isSorted = NO;
    if([self.delegate respondsToSelector:@selector(itemHandler:titleForItem:)]) self.isSorted = YES;
    NSMutableSet *remainingTags = [NSMutableSet set];
    NSMutableArray *filteredItems = [NSMutableArray array];
    self.hasFilter = YES;
    if(self.selectedTags.count > 0){
        for(KPToDo *toDo in self.items){
            BOOL didIt = YES;
            for(NSString *tag in self.selectedTags){
                if(![toDo.textTags containsObject:tag]){
                    didIt = NO;
                }
            }
            if(didIt){
                [remainingTags addObjectsFromArray:toDo.textTags];
                [filteredItems addObject:toDo];
            }
        }
        for(NSString *tag in self.selectedTags){
            [remainingTags removeObject:tag];
        }
        self.remainingTags = [[remainingTags allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    else{
        self.hasFilter = NO;
        self.remainingTags = self.allTags;
        filteredItems = [self.items mutableCopy];
    }
    self.filteredItems = [filteredItems copy];
    self.itemCounterWithFilter = self.filteredItems.count;
    if(self.isSorted){
        self.sortedItems = [NSMutableArray array];
        self.titleArray = [NSMutableArray array];
        for(KPToDo *toDo in self.filteredItems){
            NSLog(@"sorting stuff");
            NSString *title = [self.delegate itemHandler:self titleForItem:toDo];
            [self addItem:toDo withTitle:title];
        }
    }
}
-(NSIndexSet*)removeItemsForIndexSet:(NSIndexSet *)indexSet{
    if(self.isSorted){
        NSArray *oldKeys = [self.titleArray copy];
        [self fetchData];
        NSArray *newKeys = [self.titleArray copy];
        NSMutableIndexSet *deletedSections = [NSMutableIndexSet indexSet];
        for(int i = 0 ; i < oldKeys.count ; i++){
            NSString *oldKey = [oldKeys objectAtIndex:i];
            if(![newKeys containsObject:oldKey]) [deletedSections addIndex:i];
        }
        return deletedSections;
    }
    else{
        NSMutableArray *newItems = [NSMutableArray array];
        for(NSInteger i = 0 ; i < self.items.count ; i++){
            if([indexSet containsIndex:i]) continue;
            [newItems addObject:[self.items objectAtIndex:i]];
        }
        self.items = [newItems copy];
        return nil;
    }
    
}
-(NSMutableArray*)arrayForTitle:(NSString*)title{
    NSInteger index = [self.titleArray indexOfObject:title];
    NSMutableArray *arrayOfItems;
    if(index != NSNotFound) arrayOfItems = [self.sortedItems objectAtIndex:index];
    else{
        [self.titleArray addObject:title];
        [self.sortedItems addObject:[NSMutableArray array]];
        arrayOfItems = [self.sortedItems lastObject];
    }
    return arrayOfItems;
    
}
-(void)addItem:(KPToDo*)toDo withTitle:(NSString*)title{
    NSMutableArray *arrayOfItems = [self arrayForTitle:title];
    [arrayOfItems addObject:toDo];
}
@end
