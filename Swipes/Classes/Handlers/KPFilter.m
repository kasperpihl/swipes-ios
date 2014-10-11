//
//  KPFilter.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 11/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "KPFilter.h"
@interface KPFilter ()

@end
@implementation KPFilter
static KPFilter *sharedObject;
+(KPFilter *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[KPFilter allocWithZone:NULL] init];
    }
    return sharedObject;
}
-(NSMutableArray *)selectedTags{
    if(!_selectedTags)
        _selectedTags = [NSMutableArray array];
    return _selectedTags;
}
-(void)searchForString:(NSString*)string{
    if(string != _searchString){
        if(!string || string.length < MIN_SEARCH_LETTER_LENGTH){
            string = nil;
        }
        _searchString = string;
        [self updateStateAndNotify:YES];
    }
}
-(void)selectTag:(NSString *)tag{
    if(![self.selectedTags containsObject:tag]){
        [self.selectedTags addObject:tag];
        [self updateStateAndNotify:YES];
    }
}
-(void)deselectTag:(NSString *)tag{
    if([self.selectedTags containsObject:tag]){
        [self.selectedTags removeObject:tag];
        [self updateStateAndNotify:YES];
    }
}
-(void)clearAll{
    [self.selectedTags removeAllObjects];
    _searchString = nil;
    [self updateStateAndNotify:YES];
    
}

-(void)updateStateAndNotify:(BOOL)notify{
    BOOL isActive = NO;
    if(self.searchString && self.searchString.length > 0)
        isActive = YES;
    if(self.selectedTags.count > 0)
        isActive = YES;
    
    _isActive = isActive;
    
    if(notify)
        [self.delegate didUpdateFilter:self];
}

-(NSString *)readableFilter{
    return nil;
}
@end
