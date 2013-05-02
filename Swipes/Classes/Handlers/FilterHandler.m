//
//  FilterHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 01/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "FilterHandler.h"
#import "TagHandler.h"
#import "ToDoHandler.h"
@interface FilterHandler ()

@end
@implementation FilterHandler
-(NSMutableArray *)selectedTags{
    if(!_selectedTags) _selectedTags = [NSMutableArray array];
    return _selectedTags;
}
+(FilterHandler *)filterForItems:(NSArray*)items{
    FilterHandler *filter = [[FilterHandler alloc] init];
    filter.items = items;
    filter.allTags = [filter extractTags];
    [filter runSort];
    return filter;
}
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
    NSMutableSet *remainingTags = [NSMutableSet set];
    NSMutableArray *sortedToDos = [NSMutableArray array];
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
                [sortedToDos addObject:toDo];
            }
        }
        for(NSString *tag in self.selectedTags){
            [remainingTags removeObject:tag];
        }
        self.remainingTags = [[remainingTags allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    else{
        self.remainingTags = self.allTags;
        sortedToDos = [self.items mutableCopy];
    }
    self.sortedItems = [sortedToDos copy];
}
-(void)selectTag:(NSString *)tag{
    if(![self.selectedTags containsObject:tag]){
        [self.selectedTags addObject:tag];
        [self runSort];
    }
}
-(void)deselectTag:(NSString *)tag{
    if([self.selectedTags containsObject:tag]){
        [self.selectedTags removeObject:tag];
        [self runSort];
    }
    
}
@end
