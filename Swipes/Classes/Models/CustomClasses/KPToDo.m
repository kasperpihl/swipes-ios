#import "KPToDo.h"

#import "NotificationHandler.h"
#import "KPTag.h"
#import "UtilityClass.h"
#import "NSDate-Utilities.h"
#import "KPParseCoreData.h"
#import "Underscore.h"
#import "AnalyticsHandler.h"

#define kDefOrderVal -1

@interface KPToDo ()
@property (nonatomic,strong) NSString *readableTags;
// Private interface goes here.
@end


@implementation KPToDo
@synthesize readableTags = _readableTags;
@synthesize textTags = _textTags;
-(NSDictionary*)keyMatch{
    return @{
      @"title": @"title",
      @"schedule": @"schedule",
      @"completionDate": @"completionDate",
      @"notes": @"notes",
      @"repeatCount": @"numberOfRepeated",  
      @"repeatDate": @"repeatedDate",
      @"order": @"order",
      @"priority":@"priority"
    };
}
#define checkStringWithKey(object, pfValue, cdKey, cdValue) if(![cdValue isEqualToString:pfValue]) [self setValue:pfValue forKey:cdKey]
#define checkDateWithKey(object, pfValue, cdKey, cdValue) if(![cdValue isEqualToDate:pfValue]) [self setValue:pfValue forKey:cdKey]
#define checkNumberWithKey(object, pfValue, cdKey, cdValue) if(![cdValue isEqualToNumber:pfValue]) [self setValue:pfValue forKey:cdKey]

+(KPToDo*)addItem:(NSString *)item priority:(BOOL)priority save:(BOOL)save{
    KPToDo *newToDo = [KPToDo newObjectInContext:nil];
    newToDo.title = item;
    newToDo.schedule = [NSDate date];
    if(priority) newToDo.priorityValue = 1;
    newToDo.orderValue = kDefOrderVal;
    if(save) [KPToDo save];
    NSString *taskLength = @"50+";
    if(item.length <= 10) taskLength = @"1-10";
    else if(item.length <= 20) taskLength = @"11-20";
    else if(item.length <= 30) taskLength = @"21-30";
    else if(item.length <= 40) taskLength = @"31-40";
    else if(item.length <= 50) taskLength = @"41-50";
    [ANALYTICS tagEvent:@"Added Task" options:@{@"Length":taskLength}];
    [NOTIHANDLER updateLocalNotifications];
    return newToDo;
}
+(NSArray*)scheduleToDos:(NSArray*)toDoArray forDate:(NSDate *)date save:(BOOL)save{
    NSMutableArray *movedToDos = [NSMutableArray array];
    for(KPToDo *toDo in toDoArray){
        BOOL movedToDo = [toDo scheduleForDate:date];
        if(movedToDo) [movedToDos addObject:toDo];
    }
    if(save) [KPCORE saveInContext:nil];
    [NOTIHANDLER updateLocalNotifications];
    return [movedToDos copy];
}
+(NSArray*)completeToDos:(NSArray*)toDoArray save:(BOOL)save{
    NSMutableArray *movedToDos = [NSMutableArray array];
    for(KPToDo *toDo in toDoArray){
        BOOL movedToDo = [toDo complete];
        if(movedToDo) [movedToDos addObject:toDo];
    }
    if(save) [KPCORE saveInContext:nil];
    NSNumber *numberOfCompletedTasks = [NSNumber numberWithInteger:toDoArray.count];
    [ANALYTICS tagEvent:@"Completed Tasks" options:@{@"Number of Tasks":numberOfCompletedTasks}];
    [NOTIHANDLER updateLocalNotifications];
    return [movedToDos copy];
}

+(void)deleteToDos:(NSArray*)toDos save:(BOOL)save{
    BOOL shouldUpdateNotifications = NO;
    for(KPToDo *toDo in toDos){
        if(!toDo.completionDate) shouldUpdateNotifications = YES;
        [toDo deleteToDoSave:NO];
    }
    if(save) [KPCORE saveInContext:nil];
    if(shouldUpdateNotifications) [NOTIHANDLER updateLocalNotifications];
}
+(void)updateTags:(NSArray *)tags forToDos:(NSArray *)toDos remove:(BOOL)remove save:(BOOL)save{
    if(tags){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@",@"title",tags];
        NSSet *tagsSet = [NSSet setWithArray:[KPTag MR_findAllWithPredicate:predicate]];
        for(KPToDo *toDo in toDos){
            [toDo updateTagSet:tagsSet withTags:tags remove:remove];
        }
        if(save) [KPCORE saveInContext:nil];
    }
}
+(NSArray *)selectedTagsForToDos:(NSArray *)toDos{
    NSMutableArray *commonTags = [NSMutableArray array];
    NSMutableArray *common2Tags = [NSMutableArray array];
    NSInteger counter = 0;
    for(KPToDo *toDo in toDos){
        if(counter > 1){
            commonTags = common2Tags;
            common2Tags = [NSMutableArray array];
        }
        for(KPTag *tag in toDo.tags){
            if(counter == 0) [commonTags addObject:tag.title];
            else{
                if([commonTags containsObject:tag.title]) [common2Tags addObject:tag.title];
            }
        }
        counter++;
    }
    if(counter > 1) commonTags = common2Tags;
    return commonTags;
}


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
                //NSLog(@"tags:%@",tagsFromServer);
                NSMutableArray *objectIDs = [NSMutableArray array];
                
                for(PFObject *tag in tagsFromServer){
                    if(tag && (NSNull*)tag != [NSNull null]) [objectIDs addObject:tag.objectId];
                }
                if(objectIDs.count > 0){
                    NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"%K IN %@",@"objectId",[objectIDs copy]];
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
-(void)setRepeatOption:(RepeatOptions)option save:(BOOL)save{
    self.repeatOptionValue = option;
    if(option != RepeatNever) self.repeatedDate = self.schedule;
    else self.repeatedDate = nil;
    if(save) [KPToDo save];
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

+(void)save{
    [KPCORE saveInContext:nil];
}
-(NSDate *)nextDateFrom:(NSDate*)date{
    NSDate *returnDate;
    switch (self.repeatOptionValue) {
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
            title = [UtilityClass readableTime:toDoDate showTime:NO];
            if([title isEqualToString:@"Today"]) title = @"Later Today";
            //title = [NSString stringWithFormat:@"Schedule %@",dateString];
        }
    }
    else if(cellType == CellTypeDone){
        NSDate *toDoDate = self.completionDate;
        NSString *dateString = [UtilityClass readableTime:toDoDate showTime:NO];
        title = [NSString stringWithFormat:@"%@",dateString];
    }
    
    return [title capitalizedString];
}
+(NSArray*)sortOrderForItems:(NSArray*)items save:(BOOL)save{
    NSPredicate *orderedItemsPredicate = [NSPredicate predicateWithFormat:@"(order > %i)",kDefOrderVal];
    NSPredicate *unorderedItemsPredicate = [NSPredicate predicateWithFormat:@"!(order > %i)",kDefOrderVal];
    NSSortDescriptor *orderedItemsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSSortDescriptor *unorderedItemsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"schedule" ascending:YES];
    NSArray *orderedItems = [[items filteredArrayUsingPredicate:orderedItemsPredicate] sortedArrayUsingDescriptors:@[orderedItemsSortDescriptor]];
    NSArray *unorderedItems = [[items filteredArrayUsingPredicate:unorderedItemsPredicate] sortedArrayUsingDescriptors:@[unorderedItemsSortDescriptor]];
    NSInteger counter = kDefOrderVal + 1;
    NSArray *sortedItems = [orderedItems arrayByAddingObjectsFromArray:unorderedItems];
    NSInteger numberOfChanges = 0;
    for(KPToDo *toDo in sortedItems){
        
        if(toDo.orderValue != counter){
            toDo.orderValue = counter;
            numberOfChanges++;
        }
        NSLog(@"%i - %@",toDo.orderValue,toDo.title);
        counter++;
    }
    NSLog(@"number of changes:%i",numberOfChanges);
    if(save && numberOfChanges > 0){
        [KPToDo save];
    }
    /*
     Ordered items = items where order > 0
     itemsWithoutOrder = items where !order or order == 0
     Sorted by schedule date ascending
     i = 1
     foreach ordered Item:
     item.order = i
     i++
     foreach unordered Item:
     item.order = i
     i++
     save
    */
    NSArray* reversedArray = [[sortedItems reverseObjectEnumerator] allObjects];
    return reversedArray;
    
}

-(void)changeToOrder:(NSInteger)newOrder withItems:(NSArray *)items{
    if(newOrder == self.orderValue) return;
    BOOL decrease = (newOrder > self.orderValue);
    NSString *predicateRawString = (newOrder > self.orderValue) ? @"(order > %i) AND (order =< %i)" : @"(order < %i) AND (order >= %i)";
    
    NSPredicate *betweenPredicate = [NSPredicate predicateWithFormat: predicateRawString, self.orderValue, newOrder];
    NSArray *results = [[items filteredArrayUsingPredicate:betweenPredicate] sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES]]];
    NSLog(@"items: %@ res:%@",items,results);
    self.orderValue = newOrder;
    for (int i = 0 ; i < results.count; i++) {
        KPToDo *toDo = [results objectAtIndex:i];
       
        if(decrease) toDo.orderValue--;
        else toDo.orderValue++;
        NSLog(@"r %i - %@",toDo.orderValue,toDo.title);
    }
    
    [KPToDo save];
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
    if(save) [KPToDo save];
}
-(NSArray *)textTags{
    return Underscore.array([self.tagString componentsSeparatedByString:@", "]).filter(Underscore.isString).reject(^BOOL (NSString *tag){ return (tag.length == 0); }).unwrap;

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
        self.orderValue = kDefOrderVal;
        self.completionDate = [NSDate date];
        return YES;
    }
}
-(BOOL)scheduleForDate:(NSDate*)date{
    if(!date){
        self.orderValue = kDefOrderVal;
        self.repeatedDate = nil;
        self.repeatOptionValue = RepeatNever;
    }
    CellType oldCell = [self cellTypeForTodo];
    self.completionDate = nil;
    self.schedule = date;
    if([self.schedule isInFuture]) self.orderValue = kDefOrderVal;
    CellType newCell = [self cellTypeForTodo];
    return (oldCell != newCell);
}
@end
