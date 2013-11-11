#import "KPToDo.h"

#import "NotificationHandler.h"
#import "KPTag.h"
#import "UtilityClass.h"
#import "NSDate-Utilities.h"
#import "KPParseCoreData.h"

@interface KPToDo ()
@property (nonatomic,strong) NSString *readableTags;
// Private interface goes here.
@end


@implementation KPToDo
@synthesize readableTags = _readableTags;
@synthesize textTags = _textTags;
@synthesize tagString = _tagString;
-(NSDictionary*)keyMatch{
    return @{
      @"title": @"title",
      @"schedule": @"schedule",
      @"completionDate": @"completionDate",
      @"notes": @"notes",
      @"repeatCount": @"numberOfRepeated",
      @"repeatDate": @"repeatedDate",
      @"order": @"order",
    };
}
#define checkStringWithKey(object, pfValue, cdKey, cdValue) if(![cdValue isEqualToString:pfValue]) [self setValue:pfValue forKey:cdKey]
#define checkDateWithKey(object, pfValue, cdKey, cdValue) if(![cdValue isEqualToDate:pfValue]) [self setValue:pfValue forKey:cdKey]
#define checkNumberWithKey(object, pfValue, cdKey, cdValue) if(![cdValue isEqualToNumber:pfValue]) [self setValue:pfValue forKey:cdKey]
-(void)updateWithObject:(PFObject *)object context:(NSManagedObjectContext *)context{
    [super updateWithObject:object context:context];
    [context performBlockAndWait:^{
        NSDictionary *keyMatch = [self keyMatch];
        for(NSString *pfKey in [object allKeys]){
            id pfValue = [object objectForKey:pfKey];
            if([pfKey isEqualToString:@"repeatOption"]){
                if(![[self stringForRepeatOption:self.repeatOptionValue] isEqualToString:pfValue]) self.repeatOptionValue = [self optionForRepeatString:pfValue];
                continue;
            }
            if([pfKey isEqualToString:@"tags"]){
                NSArray *tagsFromServer = (NSArray*)pfValue;
                NSLog(@"tags:%@",tagsFromServer);
                NSMutableArray *objectIDs = [NSMutableArray array];
                
                for(PFObject *tag in tagsFromServer){
                    if(tag && (NSNull*)tag != [NSNull null]) [objectIDs addObject:tag.objectId];
                }
                if(objectIDs.count > 0){
                    NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@",@"objectId",[objectIDs copy]];
                    NSLog(@"self:%@ objIds:%@",self.objectId,objectIDs);
                    NSArray *tagsObjects = [KPTag MR_findAllWithPredicate:tagPredicate inContext:context];
                    
                    NSMutableArray *tagStrings = [NSMutableArray array];
                    NSInteger tagCount = tagsObjects.count;
                    NSMutableArray *notSortedTags = [NSMutableArray array];
                    for(NSInteger i = 0 ; i < tagCount ; i++) [tagStrings addObject:[NSNull null]];
                    for(KPTag *tag in tagsObjects){
                        NSInteger index = [objectIDs indexOfObject:tag.objectId];
                        if(index != NSNotFound && index < tagCount) [tagStrings replaceObjectAtIndex:index withObject:tag.title];
                        else{
                            [notSortedTags addObject:tag.title];
                        }
                    }
                    if(notSortedTags.count > 0){
                        NSInteger counter = 0;
                        for(NSInteger i = 0 ; i < tagCount ; i++){
                            if([tagStrings objectAtIndex:i] == [NSNull null]) [tagStrings replaceObjectAtIndex:i withObject:[notSortedTags objectAtIndex:counter++]];
                        }
                    }
                    self.tagString = [tagStrings componentsJoinedByString:@", "];
                    self.tags = [NSSet setWithArray:tagsObjects];
                    
                }
                else {
                    self.tagString = @"";
                    self.tags = [NSSet set];
                }
                continue;
            }
            NSString *cdKey = [keyMatch objectForKey:pfKey];
            if(cdKey){
                id cdValue = [self valueForKey:cdKey];
                
                if([cdValue isKindOfClass:[NSString class]] && [pfValue isKindOfClass:[NSString class]]){ checkStringWithKey(object, pfValue, cdKey, cdValue); }
                else if([cdValue isKindOfClass:[NSDate class]] && [pfValue isKindOfClass:[NSDate class]]){ checkDateWithKey(object, pfValue, cdKey, cdValue); }
                else if([cdValue isKindOfClass:[NSNumber class]] && [pfValue isKindOfClass:[NSNumber class]]){ checkNumberWithKey(object, pfValue, cdKey, cdValue); }
                else if(pfValue != cdValue){
                    if(pfValue == (id)[NSNull null]) pfValue = nil;
                    [self setValue:pfValue forKey:cdKey];
                }
            }
        }
    }];
}
-(BOOL)setAttributesForSavingObject:(PFObject *__autoreleasing *)object changedAttributes:(NSArray *)changedAttributes{
    BOOL setAll = NO;
    NSDictionary *keyMatch = [self keyMatch];
    if(!self.objectId) setAll = YES;
    BOOL shouldUpdate = NO;
    for(NSString *pfKey in keyMatch){
        NSString *cdKey = [keyMatch objectForKey:pfKey];
        if(setAll || [changedAttributes containsObject:cdKey]){
            if([self valueForKey:cdKey]) [*object setObject:[self valueForKey:cdKey] forKey:pfKey];
            else([*object setObject:[NSNull null] forKey:pfKey]);
            shouldUpdate = YES;
        }
    }
    if(setAll || [changedAttributes containsObject:@"repeatOption"]){
        [*object setObject:[self stringForRepeatOption:self.repeatOptionValue] forKey:@"repeatOption"];
        shouldUpdate = YES;
    }
    if(setAll || [changedAttributes containsObject:@"tags"]){
        NSInteger tagCount = self.tags.count;
        NSMutableArray *tagArray = [NSMutableArray arrayWithCapacity:tagCount];
        NSArray *tagsFromString = [self.tagString componentsSeparatedByString:@", "];
        for (NSInteger i = 0; i < tagCount; ++i) [tagArray addObject:[NSNull null]];
        NSMutableArray *emptyObjects = [NSMutableArray array];

        for(KPTag *tag in self.tags){
            NSInteger index = [tagsFromString indexOfObject:tag.title];
            PFObject *objectToSave = [tag emptyObjectForSaving];
            if(index != NSNotFound && index < tagCount) [tagArray replaceObjectAtIndex:index withObject:objectToSave];
            else [emptyObjects addObject:objectToSave];
        }
        
        if(emptyObjects.count > 0){
            NSInteger emptyCount = 0;
            for(NSInteger i = 0 ; i < tagArray.count ; i++){
                if([tagArray objectAtIndex:i] == [NSNull null]){
                    [tagArray replaceObjectAtIndex:i withObject:[emptyObjects objectAtIndex:emptyCount++]];
                }
            }
        }
        NSLog(@"tag array to save:%@",tagArray);
        [*object setObject:tagArray forKey:@"tags"];
        shouldUpdate = YES;
    }
    return shouldUpdate;
}
-(CellType)cellTypeForTodo{
    NSDate *now = [NSDate date];
    if(self.completionDate) return CellTypeDone;
    else{
        if(!self.schedule || ([self.schedule isLaterThanDate:now] && ![self.schedule isEqualToDate:now])) return CellTypeSchedule;
        else return CellTypeToday;
    }
    return CellTypeNone;
}
-(void)updateNotes:(NSString *)notes save:(BOOL)save{
    self.notes = notes;
    if(save) [self save];
}
-(void)setRepeatOption:(RepeatOptions)option save:(BOOL)save{
    self.repeatOptionValue = option;
    self.repeatedDate = self.schedule;
    if(save) [self save];
}
-(void)updateRepeatedSave:(BOOL)save{
    if(self.repeatOptionValue > RepeatNever){
        self.repeatedDate = self.schedule;
        if(save) [self save];
    }
}
-(RepeatOptions)optionForRepeatString:(NSString*)repeatString{
    RepeatOptions option = RepeatNever;
    if([repeatString isEqualToString:@"every day"]) option = RepeatEveryDay;
    else if([repeatString isEqualToString:@"mon-fri or sat+sun"]) option = RepeatEveryMonFriOrSatSun;
    else if([repeatString isEqualToString:@"every week"]) option = RepeatEveryWeek;
    else if([repeatString isEqualToString:@"every month"]) option = RepeatEveryMonth;
    else if([repeatString isEqualToString:@"every year"]) option = RepeatEveryYear;
    return option;
}
-(NSString*)stringForRepeatOption:(RepeatOptions)option{
    NSString *repeatString;
    switch (option) {
        
        case RepeatEveryDay:
            repeatString = @"every day";
            break;
        case RepeatEveryMonFriOrSatSun:
            repeatString = @"mon-fri or sat+sun";
            break;
        case RepeatEveryWeek:
            repeatString = @"every week";
            break;
        case RepeatEveryMonth:
            repeatString = @"every month";
            break;
        case RepeatEveryYear:
            repeatString = @"every year";
            break;
        case RepeatNever:
        default:
            repeatString = @"never";
            break;
    }
    return repeatString;
}

-(void)save{
    [KPCORE saveInContext:nil];
}
-(NSString *)readableTime:(NSDate*)time showTime:(BOOL)showTime{
    if(!time) return nil;
    NSString *timeString = [UtilityClass timeStringForDate:time];
    
    NSDate *beginningOfDate = [time dateAtStartOfDay];
    NSInteger numberOfDaysAfterTodays = [beginningOfDate distanceInDaysToDate:[[NSDate date] dateAtStartOfDay]];
    NSString *dateString;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    BOOL shouldFormat = NO;
    if(numberOfDaysAfterTodays == 0){
        dateString = @"Today";
        if([time isLaterThanDate:[NSDate date]]) dateString = @"Today";
    }
    else if(numberOfDaysAfterTodays == -1) dateString = @"Tomorrow";
    else if(numberOfDaysAfterTodays == 1) dateString = @"Yesterday";
    else if(numberOfDaysAfterTodays < 7 && numberOfDaysAfterTodays > -7){
        [dateFormatter setDateFormat:@"EEEE"];
        shouldFormat = YES;
    }
    else{
        if([time isSameYearAsDate:[NSDate date]]) dateFormatter.dateFormat = @"LLL d";
        else dateFormatter.dateFormat = @"LLL d  '´'yy";
        shouldFormat = YES;
    }
    if(shouldFormat){
        dateString = [dateFormatter stringFromDate:time];
    }
    dateString = [dateString capitalizedString];
    if(!showTime) return dateString;
    return [NSString stringWithFormat:@"%@, %@",dateString,timeString];
    
}
-(NSDate *)nextDateFrom:(NSDate*)date{
    NSDate *returnDate;
    switch (self.repeatOption.integerValue) {
        case RepeatEveryDay:
            returnDate = [date dateByAddingDays:1];
            break;
        case RepeatEveryMonFriOrSatSun:
            if(date.isTypicallyWeekend) returnDate = [date dateAtNextWeekendDay];
            else returnDate = [date dateAtNextWorkday];
            break;
        case RepeatEveryWeek:
            returnDate = [date dateByAddingWeeks:1];
            break;
        case RepeatEveryMonth:
            returnDate = [date dateByAddingMonths:1];
            break;
        case RepeatEveryYear:
            returnDate = [date dateByAddingYears:1];
            break;
    }
    return returnDate;
}
-(NSArray*)nextNumberOfRepeatedDates:(NSInteger)numberOfDates{
    if(self.repeatOptionValue == RepeatNever) return nil;
    NSInteger counter = 0;
    NSDate *date = self.schedule;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:numberOfDates];
    do {
        date = [self nextDateFrom:date];
        [array addObject:date];
    } while (counter < numberOfDates);
    return array;
}
-(KPToDo*)deepCopy{
    KPToDo *newToDo = [KPToDo newObjectInContext:nil];
    newToDo.completionDate = self.completionDate;
    newToDo.notes = self.notes;
    newToDo.order = self.order;
    newToDo.schedule = self.schedule;
    [newToDo setTags:self.tags];
    newToDo.tagString = self.tagString;
    newToDo.title = self.title;
    return newToDo;
}

-(NSString *)readableTitleForStatus{
    NSString *title;
    CellType cellType = [self cellTypeForTodo];
    
    if(cellType == CellTypeToday) title = @"Tasks";
    else if(cellType == CellTypeSchedule){
        NSDate *toDoDate = self.schedule;
        if(!toDoDate) title = @"Unspecified";
        else{
            title = [self readableTime:toDoDate showTime:NO];
            if([title isEqualToString:@"Today"]) title = @"Later Today";
            //title = [NSString stringWithFormat:@"Schedule %@",dateString];
        }
    }
    else if(cellType == CellTypeDone){
        NSDate *toDoDate = self.completionDate;
        NSString *dateString = [self readableTime:toDoDate showTime:NO];
        title = [NSString stringWithFormat:@"%@",dateString];
    }
    
    return [title capitalizedString];
}
-(void)changeToOrder:(NSInteger)newOrder{
    if(newOrder == self.orderValue) return;
    BOOL decrease = (newOrder > self.orderValue);
    NSString *predicateRawString = (newOrder > self.orderValue) ? @"(order > %i) AND (order =< %i) AND completionDate != nil" : @"(order < %i) AND (order >= %i) AND completionDate != nil";
    
    NSPredicate *betweenPredicate = [NSPredicate predicateWithFormat: predicateRawString, self.orderValue, newOrder];
    NSArray *results = [KPToDo MR_findAllSortedBy:@"order" ascending:YES withPredicate:betweenPredicate];
    self.orderValue = newOrder;
    for (int i = 0 ; i < results.count; i++) {
        KPToDo *toDo = [results objectAtIndex:i];
        if(decrease) toDo.orderValue--;
        else toDo.orderValue++;
    }
    
    [self save];
}
-(void)setTagString:(NSString *)tagString{
    if(tagString.length == 0) _tagString = nil;
    else _tagString = tagString;
}
-(void)updateTagSet:(NSSet*)tagsSet withTags:(NSArray*)tags remove:(BOOL)remove{
    
    NSMutableArray *tagsStrings = [NSMutableArray array];
    if(self.tagString.length > 0) tagsStrings = [[self.tagString componentsSeparatedByString:@", "] mutableCopy];
    if(remove) [self removeTags:tagsSet];
    else [self addTags:tagsSet];
    for(NSString *tag in tags){
        BOOL contained = [tagsStrings containsObject:tag];
        if(remove && contained) [tagsStrings removeObject:tag];
        else if(!remove && !contained) [tagsStrings addObject:tag];
    }
    self.tagString = [tagsStrings componentsJoinedByString:@", "];
    
}
-(NSMutableAttributedString*)stringForSelectedTags:(NSArray*)selectedTags{
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           TAGS_LABEL_FONT, NSFontAttributeName,
                           nil];
    NSDictionary *boldAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               TAGS_LABEL_BOLD_FONT, NSFontAttributeName, nil];
    
    
    NSMutableArray *tagsStringArray = [[self.tagString componentsSeparatedByString:@", "] mutableCopy];
    for(NSInteger i = 0  ; i < selectedTags.count ; i++){
        NSString *tag = [selectedTags objectAtIndex:i];
        [tagsStringArray removeObject:tag];
        [tagsStringArray insertObject:tag atIndex:i];
    }
    
    NSString *sortedTagString = [tagsStringArray componentsJoinedByString:@", "];
    if(!sortedTagString || sortedTagString.length == 0) return nil;
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:sortedTagString
                                           attributes:attrs];
    NSMutableString *mutableString2 = [NSMutableString stringWithString:@""];
    for(NSInteger i = 0 ; i < selectedTags.count ; i++){
        NSString *tag = [tagsStringArray objectAtIndex:i];
        NSRange range = NSMakeRange(mutableString2.length,tag.length);
        [attributedText setAttributes:boldAttrs range:range];
        [mutableString2 appendFormat:@"%@, ",tag];
    }
    return attributedText;
    
}
-(void)deleteToDoSave:(BOOL)save{
    [self MR_deleteEntity];
    if(save) [self save];
}
-(NSArray *)textTags{
    return [self.tagString componentsSeparatedByString:@", "];
}
-(NSString *)stringifyTags{
    return self.tagString;
    /*if(!self.readableTags) [self updateTagsString];
    return self.readableTags;*/
}
-(void)completeRepeatedTask{
    if(self.repeatOptionValue == RepeatNever) return;
    NSDate *next = [self nextDateFrom:self.repeatedDate];
    
    NSInteger numberOfRepeated = self.numberOfRepeatedValue;
    while ([next isInPast]){
        next = [self nextDateFrom:next];
    }
    KPToDo *toDoCopy = [self deepCopy];
    toDoCopy.numberOfRepeatedValue = ++numberOfRepeated;
    [toDoCopy complete];
    [self scheduleForDate:next];
    self.repeatedDate = next;
    self.numberOfRepeated = [NSNumber numberWithInteger:numberOfRepeated];
}
-(BOOL)complete{
    if(self.repeatOptionValue > RepeatNever){
        CellType oldCell = [self cellTypeForTodo];
        [self completeRepeatedTask];
        CellType newCell = [self cellTypeForTodo];
        return (oldCell != newCell);
    }
    else{
        self.schedule = nil;
        self.completionDate = [NSDate date];
        return YES;
    }
}
-(BOOL)scheduleForDate:(NSDate*)date{
    if(!date){
        self.repeatedDate = nil;
        self.repeatOptionValue = RepeatNever;
    }
    CellType oldCell = [self cellTypeForTodo];
    self.completionDate = nil;
    self.schedule = date;
    CellType newCell = [self cellTypeForTodo];
    return (oldCell != newCell);
}
@end
