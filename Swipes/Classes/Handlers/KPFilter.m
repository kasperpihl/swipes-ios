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

-(void)setPriorityFilter:(FilterSetting)priorityFilter{
    if(_priorityFilter != priorityFilter){
        _priorityFilter = priorityFilter;
        [self updateStateAndNotify:YES];
    }
}
-(void)setNotesFilter:(FilterSetting)notesFilter{
    if(_notesFilter != notesFilter){
        _notesFilter = notesFilter;
        [self updateStateAndNotify:YES];
    }
}
-(void)setRecurringFilter:(FilterSetting)recurringFilter{
    if(_recurringFilter != recurringFilter){
        _recurringFilter = recurringFilter;
        [self updateStateAndNotify:YES];
    }
}

-(void)clearAll{
    [self.selectedTags removeAllObjects];
    _searchString = nil;
    _recurringFilter = _notesFilter = _priorityFilter = FilterSettingNone;
    [self updateStateAndNotify:YES];
    
}

-(void)setIsActive:(BOOL)isActive{
    if(_isActive != isActive){
        _isActive = isActive;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"filter active state changed" object:self];
    }
}

-(void)updateStateAndNotify:(BOOL)notify{
    BOOL isActive = NO;
    if(self.searchString && self.searchString.length > 0)
        isActive = YES;
    if(self.selectedTags.count > 0)
        isActive = YES;
    
    if(self.notesFilter != FilterSettingNone)
        isActive = YES;
    if(self.priorityFilter != FilterSettingNone)
        isActive = YES;
    if(self.recurringFilter != FilterSettingNone)
        isActive = YES;
    
    self.isActive = isActive;
    
    if(notify)
        [self.delegate didUpdateFilter:self];
}

-(NSString *)readableFilter{
    BOOL tagsFilter = (self.selectedTags.count > 0);
    BOOL searchFilter = (self.searchString && self.searchString.length > 0);
    BOOL priorityFilter = (kFilter.priorityFilter == FilterSettingOn);
    BOOL notesFilter = (kFilter.notesFilter == FilterSettingOn);
    BOOL recurringFilter = (kFilter.recurringFilter == FilterSettingOn);
    NSInteger countDown = 5;
    
    if(!tagsFilter)
        countDown--;
    if(!searchFilter)
        countDown--;
    if(!notesFilter)
        countDown--;
    if(!priorityFilter)
        countDown--;
    if(!recurringFilter)
        countDown--;
    
    NSString *totalSearchString = @"";
    
    if(recurringFilter){
        totalSearchString = @"Recurring ";
    }
    if(priorityFilter){
        totalSearchString = [totalSearchString stringByAppendingString:@"Priority "];
    }
    totalSearchString = [totalSearchString stringByAppendingString:@"Tasks"];
    
    NSInteger counter = 0;
    if(notesFilter){
        totalSearchString = [totalSearchString stringByAppendingString:@" with Notes"];
        counter++;
    }
    
    if(searchFilter){
        totalSearchString = [totalSearchString stringByAppendingFormat:@" matching \"%@\"",self.searchString];
        counter++;
    }
    if(tagsFilter){
        NSString *tagString = [self.selectedTags componentsJoinedByString:@", "];
        totalSearchString = [totalSearchString stringByAppendingFormat:@" %@ tags: %@",((counter == 0)?@"with":@"and"),tagString];
    }
    return totalSearchString;
}
@end
