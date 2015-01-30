//
//  KPFilter.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 11/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "KPFilter.h"
#import "SettingsHandler.h"
@interface KPFilter ()

@end
@implementation KPFilter
static KPFilter *sharedObject;
+(KPFilter *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[KPFilter allocWithZone:NULL] init];
        [sharedObject initialize];
    }
    return sharedObject;
}
-(void)initialize{
    //notify(SH_UpdateSetting, updatedSetting:);
}
-(void)updatedSetting:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *setting = [userInfo objectForKey:@"Setting"];
    NSString *value = [userInfo objectForKey:@"Value"];
    if(setting && setting.integerValue == SettingFilter){
        [self loadFilterFromString:value];
    }
    
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
-(void)loadFilterFromString:(NSString*)string{
    if(!string || string == (id)[NSNull null] || string.length == 0)
        return [self clearAll];
    
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    if(!error){
        NSArray *tags = [result objectForKey:@"tags"];
        if(tags){
            for( NSString *tag in tags)
                [self selectTag:tag];
        }
        NSString *search = [result objectForKey:@"search"];
        if(search){
            [self searchForString:search];
        }
        NSNumber *notes = [result objectForKey:@"notes"];
        NSNumber *priority = [result objectForKey:@"priority"];
        NSNumber *recurring = [result objectForKey:@"recurring"];
        if(notes){
            if([notes boolValue])
                [self setNotesFilter:FilterSettingOn];
        }
        if(priority){
            if([priority boolValue])
                [self setPriorityFilter:FilterSettingOn];
        }
        if(recurring){
            if([recurring boolValue])
                [self setRecurringFilter:FilterSettingOn];

        }
        
    }
}
-(void)updateStateAndNotify:(BOOL)notify{
    BOOL isActive = NO;
    NSMutableDictionary *filter = [NSMutableDictionary dictionary];
    if(self.searchString && self.searchString.length > 0){
        [filter setObject:self.searchString forKey:@"search"];
        isActive = YES;
    }
    if(self.selectedTags.count > 0){
        [filter setObject:self.selectedTags forKey:@"tags"];
        isActive = YES;
    }
    
    if(self.notesFilter != FilterSettingNone){
        [filter setObject:@(YES) forKey:@"notes"];
        isActive = YES;
    }
    if(self.priorityFilter != FilterSettingNone){
        [filter setObject:@(YES) forKey:@"priority"];
        isActive = YES;
    }
    if(self.recurringFilter != FilterSettingNone){
        [filter setObject:@(YES) forKey:@"recurring"];
        isActive = YES;
    }
    /*NSString *filterString = @"";
    if(isActive){
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:filter
                                                           options:0 // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        if(!error){
            filterString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            //[self loadFilterFromString:jsonString];
        }
    }
    //if(![[kSettings valueForSetting:SettingFilter] isEqualToString:filterString])
        //[kSettings setValue:filterString forSetting:SettingFilter notify:YES];*/
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
-(void)dealloc{
    
}
@end
