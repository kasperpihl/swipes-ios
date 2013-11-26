//
//  ItemHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "ItemHandler.h"
#import "KPTag.h"
#import "AnalyticsHandler.h"

@interface ItemHandler ()
@property (nonatomic,strong) NSMutableArray *titleArray;
@property (nonatomic,strong) NSMutableArray *sortedItems;
@property (nonatomic,strong) NSString *searchString;
@property (nonatomic,strong) NSIndexPath *draggedCellPosition;
@end
@implementation ItemHandler
-(id)init{
    self = [super init];
    if(self){
        self.itemCounter = -1;
    }
    return self;
}
-(void)setDraggingIndexPath:(NSIndexPath *)draggingIndexPath{
    self.draggedCellPosition = draggingIndexPath;
    _draggingIndexPath = draggingIndexPath;
}
#pragma mark - Getters and Setters
-(NSMutableArray *)selectedTags{
    if(!_selectedTags) _selectedTags = [NSMutableArray array];
    return _selectedTags;
}
-(void)setItems:(NSArray *)items{
    _items = items;
    [self refresh];
}
-(void)refresh{
    self.allTags = [self extractTags];
    [self runSort];
    self.itemCounter = self.items.count;
}
-(void)setItemCounter:(NSInteger)itemCounter{
    if(itemCounter != _itemCounter){
        
        if([self.delegate respondsToSelector:@selector(itemHandler:changedItemNumber:oldNumber:)])
            [self.delegate itemHandler:self changedItemNumber:itemCounter oldNumber:_itemCounter];
        _itemCounter = itemCounter;
    }
}
-(void)addItem:(NSString *)item priority:(BOOL)priority{
    if(self.hasFilter || self.hasSearched) [self clearAll];
    [KPToDo addItem:item priority:priority save:YES];
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
    [self setDraggingIndexPath:nil];
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
    self.searchString = @"";
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
    self.draggedCellPosition = destinationIndexPath;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.delegate cellForRowAtIndexPath:indexPath];
}
-(NSInteger)totalNumberOfItemsBeforeItem:(KPToDo*)item{
    NSInteger numberOfItems = 0;
    if(self.isSorted){
        NSInteger sectionIndex = 0;
        for(NSArray *array in self.sortedItems){
            NSInteger index = [array indexOfObject:item];
            if(index == NSNotFound) numberOfItems += array.count;
            else return numberOfItems += index;
            sectionIndex++;
        }
    }
    else{
        NSInteger index = [self.filteredItems indexOfObject:item];
        if(index != NSNotFound) return numberOfItems += index;
    }
    return -1;
}
-(NSIndexPath*)indexPathForItem:(KPToDo*)item{
    if(self.isSorted){
        NSInteger sectionIndex = 0;
        for(NSArray *array in self.sortedItems){
            NSInteger index = [array indexOfObject:item];
            if(index != NSNotFound) return [NSIndexPath indexPathForItem:index inSection:sectionIndex];
            sectionIndex++;
        }
    }
    else{
        NSInteger index = [self.filteredItems indexOfObject:item];
        if(index != NSNotFound) return [NSIndexPath indexPathForItem:index inSection:0];
    }
    return nil;
}
-(KPToDo *)itemForIndexPath:(NSIndexPath *)indexPath{
    @try {
        if(self.isSorted){
            KPToDo *toDo = [[self.sortedItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            return toDo;
        }
        else{
            NSInteger row = indexPath.row;
            if(self.draggingIndexPath){
                NSInteger draggedCellPosition = self.draggedCellPosition ? self.draggedCellPosition.row : self.draggingIndexPath.row;
                NSInteger draggedCellOriginalPosition = self.draggingIndexPath.row;
                
                NSInteger renderedRow = indexPath.row;
                //if(positionRow == thisRow) row = self.draggingIndexPath.row;
                if(renderedRow >= draggedCellOriginalPosition && draggedCellPosition > renderedRow){
                    row = renderedRow+1;
                }
                else if(renderedRow <= draggedCellOriginalPosition && draggedCellPosition < renderedRow){
                    row = renderedRow-1;
                }
            }
            if(row >= self.filteredItems.count) return nil;
            return [self.filteredItems objectAtIndex:row];
        }
    }
    @catch (NSException *exception) {
        return nil;
    }
}
-(NSString *)titleForSection:(NSInteger)section{
    if(self.isSorted) return [self.titleArray objectAtIndex:section];
    else{
        return @"Tasks";
        /*NSString *s = self.itemCounter > 1 ? @"s":@"";
        return [NSString stringWithFormat:@"%i Task%@",self.itemCounter,s];*/
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.isSorted) return [self.sortedItems count];
    else return (self.itemCounterWithFilter > 0) ? 1 : 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.isSorted){
        NSArray *itemsForSection = [self.sortedItems objectAtIndex:section];
        return itemsForSection.count;
    }
    return self.itemCounterWithFilter;
}
#pragma mark Sort Handling
-(NSArray*)extractTags{
    NSArray *tagArray;
    NSMutableSet *tagSet = [NSMutableSet set];
    for(KPToDo *toDo in self.items){
        [tagSet addObjectsFromArray:toDo.textTags];
    }
    tagArray = [[tagSet allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return tagArray;
}
-(void)runSort{
    self.isSorted = NO;
    self.hasFilter = NO;
    self.hasSearched = NO;
    if([self.delegate respondsToSelector:@selector(itemHandler:titleForItem:)]) self.isSorted = YES;
    NSMutableSet *remainingTags = [NSMutableSet set];
    NSMutableArray *filteredItems = [NSMutableArray array];
    BOOL hasSelectedTags = (self.selectedTags.count > 0);
    BOOL hasSearchString = (self.searchString.length >= MIN_SEARCH_LETTER_LENGTH);
    
    NSInteger counter = 0;
    if(hasSelectedTags){
        self.hasFilter = YES;
        NSMutableSet *matchingTags = [NSMutableSet set];
        for(KPToDo *toDo in self.items){
            BOOL didIt = YES;
            for(NSString *tag in self.selectedTags){
                if(![toDo.textTags containsObject:tag]){
                    didIt = NO;
                }
            }
            if(didIt){
                if(toDo.textTags && toDo.textTags.count > 0){
                    if(counter > 0) {
                        NSSet *iteratingSet = [matchingTags copy];
                        for(NSString *textTag in iteratingSet){
                            if(![toDo.textTags containsObject:textTag] && [matchingTags containsObject:textTag]) [matchingTags removeObject:textTag];
                        }
                    }
                    else [matchingTags addObjectsFromArray:toDo.textTags];
                }
                [remainingTags addObjectsFromArray:toDo.textTags];
                [filteredItems addObject:toDo];
                counter++;
            }
        }
        for(NSString *tag in self.selectedTags){
            [remainingTags removeObject:tag];
        }
        for(NSString *textTag in matchingTags) [remainingTags removeObject:textTag];
        self.remainingTags = [[remainingTags allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    else if(hasSearchString){
        self.hasSearched = YES;
        NSArray *searchArray = [self.searchString componentsSeparatedByString:@" "];
        NSMutableString *mutPredicate = [NSMutableString stringWithFormat:@""];
        NSInteger counter = 0;
        for(NSString *string in searchArray){
            if(!string || string.length == 0) continue;
            [mutPredicate appendFormat:@"((title contains[cd] '%@') OR (tagString contains[cd] '%@') OR (notes contains[cd] '%@')) AND ",string,string,string];
            counter++;
        }
        if(counter > 0){
            NSString *predicate = [mutPredicate substringToIndex:[mutPredicate length] - 5];
            NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:predicate];
            filteredItems = [[self.items filteredArrayUsingPredicate:searchPredicate] mutableCopy];
        }
    }
    else{
        self.remainingTags = self.allTags;
        filteredItems = [self.items mutableCopy];
    }
    self.filteredItems = [filteredItems copy];
    self.itemCounterWithFilter = self.filteredItems.count;
    if(self.isSorted){
        self.sortedItems = [NSMutableArray array];
        self.titleArray = [NSMutableArray array];
        for(KPToDo *toDo in self.filteredItems){
            NSString *title = [self.delegate itemHandler:self titleForItem:toDo];
            [self addItem:toDo withTitle:title];
        }
    }
}
-(void)searchForString:(NSString*)string{
    if(string != self.searchString){
        if(string.length >= MIN_SEARCH_LETTER_LENGTH || self.hasSearched){
            self.searchString = string;
            [self runSort];
            [self notifyUpdate];
        }
    }
}
-(NSIndexSet*)removeItems:(NSArray*)items{
    NSMutableIndexSet *deletedSections = [NSMutableIndexSet indexSet];
    NSMutableArray *newItemsMutable = [self.items mutableCopy];
    NSArray *oldKeys = [self.titleArray copy];
    for(KPToDo *toDo in self.filteredItems){
        if([items containsObject:toDo]) [newItemsMutable removeObject:toDo];
    }
    self.items = [newItemsMutable copy];
    if(self.isSorted){
        NSArray *newKeys = [self.titleArray copy];
        for(int i = 0 ; i < oldKeys.count ; i++){
            NSString *oldKey = [oldKeys objectAtIndex:i];
            if(![newKeys containsObject:oldKey]) [deletedSections addIndex:i];
        }
    }
    else{
        NSInteger counter = (self.hasFilter) ? self.itemCounterWithFilter : self.itemCounter;
        if(counter == 0) [deletedSections addIndex:0];
    }
    return deletedSections;
    
}
-(NSMutableArray*)arrayForTitle:(NSString*)title{
    NSInteger index = [self.titleArray indexOfObject:title];
    NSMutableArray *arrayOfItems;
    if(index != NSNotFound) arrayOfItems = [self.sortedItems objectAtIndex:index];
    else{
        if(!title) title = @"Unknown";
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
