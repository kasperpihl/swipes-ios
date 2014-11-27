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

-(NSAttributedString *)readableFilterWithResults:(NSInteger)results forCategory:(NSString *)category{
    UIFont *boldFont = KP_BOLD(15);
    UIFont *regularFont = KP_REGULAR(15);
    
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
    
    NSMutableAttributedString *totalSearchString = [[NSMutableAttributedString alloc] init];
#define attrString(strVar) [[NSAttributedString alloc] initWithString:strVar]
    
    NSMutableArray *boldRanges = [NSMutableArray array];
    NSAttributedString *resultAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu %@ ",(long)results,category]];
    [totalSearchString appendAttributedString:resultAttrString];
    [boldRanges addObject:[NSValue valueWithRange:NSMakeRange(0, resultAttrString.length-2-category.length)]];
    
    if(recurringFilter){
        NSString *recurringString = [LOCALIZE_STRING(@"recurring") stringByAppendingString:@" "];
        [totalSearchString appendAttributedString:attrString(recurringString)];
        [boldRanges addObject:[NSValue valueWithRange:NSMakeRange(totalSearchString.length-recurringString.length, recurringString.length-1)]];
    }
    if(priorityFilter){
        NSString *priorityString = [LOCALIZE_STRING(@"priority") stringByAppendingString:@" "];
        [totalSearchString appendAttributedString:attrString(priorityString)];
        [boldRanges addObject:[NSValue valueWithRange:NSMakeRange(totalSearchString.length-priorityString.length, priorityString.length-1)]];
    }
    [totalSearchString appendAttributedString:attrString(LOCALIZE_STRING(@"task"))];
    if(results != 1)
        [totalSearchString appendAttributedString:attrString(LOCALIZE_STRING(@"s"))];
    
    NSInteger counter = 0;
    if(notesFilter){
        NSString *withString = LOCALIZE_STRING(@" with ");
        NSString *noteString = LOCALIZE_STRING(@"notes");
        [totalSearchString appendAttributedString:attrString([withString stringByAppendingString:noteString])];
        [boldRanges addObject:[NSValue valueWithRange:NSMakeRange(totalSearchString.length-noteString.length, noteString.length)]];
        counter++;
    }
    
    if(searchFilter){
        NSString *searchString = [NSString stringWithFormat:LOCALIZE_STRING(@" matching \"%@\""),self.searchString];
        [totalSearchString appendAttributedString:attrString(searchString)];
        counter++;
        [boldRanges addObject:[NSValue valueWithRange:NSMakeRange(totalSearchString.length-self.searchString.length-1, self.searchString.length)]];
    }
    if(tagsFilter){
        NSString *tagString = [self.selectedTags componentsJoinedByString:@", "];
        NSString *fullTagString = [NSString stringWithFormat:LOCALIZE_STRING(@" %@ tags: %@"),((counter == 0)?LOCALIZE_STRING(@"with"):LOCALIZE_STRING(@"and")),tagString];
        [totalSearchString appendAttributedString:attrString(fullTagString)];
        [boldRanges addObject:[NSValue valueWithRange:NSMakeRange(totalSearchString.length-tagString.length, tagString.length)]];
    }
    
    [totalSearchString addAttributes:@{NSFontAttributeName:regularFont,NSForegroundColorAttributeName:tcolor(TextColor)} range:NSMakeRange(0, totalSearchString.length)];
    for(NSValue *value in boldRanges){
        [totalSearchString addAttributes:@{NSFontAttributeName:boldFont} range:[value rangeValue]];
    }
    
    return totalSearchString;
}
@end
