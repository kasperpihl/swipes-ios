
#import "NotificationHandler.h"
#import "KPTag.h"
#import "UtilityClass.h"
#import "NSDate-Utilities.h"
#import "CoreSyncHandler.h"
#import "Underscore.h"
#import "AnalyticsHandler.h"
#import "HintHandler.h"
#import <CoreLocation/CoreLocation.h>
#import "KPAttachment.h"
#import "KPToDo.h"
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
      @"location": @"location",
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
+(KPToDo*)addItem:(NSString *)item priority:(BOOL)priority tags:(NSArray *)tags save:(BOOL)save{
    KPToDo *newToDo = [KPToDo newObjectInContext:nil];
    newToDo.title = item;
    newToDo.schedule = [NSDate date];
    if(priority) newToDo.priorityValue = 1;
    newToDo.orderValue = kDefOrderVal;
    if(tags && tags.count > 0)
        [self updateTags:tags forToDos:@[newToDo] remove:NO save:NO];
    if(save) [KPToDo saveToSync];
    NSString *taskLength = @"50+";
    if(item.length <= 10) taskLength = @"1-10";
    else if(item.length <= 20) taskLength = @"11-20";
    else if(item.length <= 30) taskLength = @"21-30";
    else if(item.length <= 40) taskLength = @"31-40";
    else if(item.length <= 50) taskLength = @"41-50";
    [ANALYTICS tagEvent:@"Added Task" options:@{@"Length":taskLength}];
    [ANALYTICS heartbeat];
    [NOTIHANDLER updateLocalNotifications];
    
    return newToDo;
}
-(void)addSubtask:(NSString *)title save:(BOOL)save{
    KPToDo *subTask = [KPToDo newObjectInContext:nil];
    subTask.title = title;
    subTask.orderValue = kDefOrderVal;
    subTask.parent = self;
    if(save) [KPToDo saveToSync];
    NSString *taskLength = @"50+";
    if(title.length <= 10) taskLength = @"1-10";
    else if(title.length <= 20) taskLength = @"11-20";
    else if(title.length <= 30) taskLength = @"21-30";
    else if(title.length <= 40) taskLength = @"31-40";
    else if(title.length <= 50) taskLength = @"41-50";
    NSInteger numberOfActionSteps = self.subtasks.count;
    [ANALYTICS tagEvent:@"Added Action Step" options:@{@"Length":taskLength, @"Total Action Steps on Task": @(numberOfActionSteps)}];
}
+(NSArray*)scheduleToDos:(NSArray*)toDoArray forDate:(NSDate *)date save:(BOOL)save{
    NSMutableArray *movedToDos = [NSMutableArray array];
    for(KPToDo *toDo in toDoArray){
        BOOL movedToDo = [toDo scheduleForDate:date];
        if(movedToDo) [movedToDos addObject:toDo];
    }
    if(save)
        [KPToDo saveToSync];
    [NOTIHANDLER updateLocalNotifications];
    [ANALYTICS heartbeat];
    return [movedToDos copy];
}
+(NSArray*)completeToDos:(NSArray*)toDoArray save:(BOOL)save{
    NSMutableArray *movedToDos = [NSMutableArray array];
    BOOL isSubtasks = NO;
    for(KPToDo *toDo in toDoArray){
        if ( toDo.parent )
            isSubtasks = YES;
        BOOL movedToDo = [toDo complete];
        if(movedToDo) [movedToDos addObject:toDo];
    }
    if(save)
        [KPToDo saveToSync];
    NSNumber *numberOfCompletedTasks = [NSNumber numberWithInteger:toDoArray.count];
    [ANALYTICS tagEvent:@"Completed Tasks" options:@{@"Number of Tasks":numberOfCompletedTasks}];
    [ANALYTICS heartbeat];
    if( !isSubtasks )
        [kHints triggerHint:HintCompleted];
    [NOTIHANDLER updateLocalNotifications];
    return [movedToDos copy];
}

+(NSArray*)notifyToDos:(NSArray *)toDoArray onLocation:(CLPlacemark*)location type:(GeoFenceType)type save:(BOOL)save{
    NSMutableArray *movedToDos = [NSMutableArray array];
    for(KPToDo *toDo in toDoArray){
        BOOL movedToDo = [toDo notifyOnLocation:location type:type];
        if(movedToDo) [movedToDos addObject:toDo];
    }
    if(save) [KPToDo saveToSync];
    [NOTIHANDLER updateLocationUpdates];
    [ANALYTICS heartbeat];
    return [movedToDos copy];
}

+(void)deleteToDos:(NSArray*)toDos save:(BOOL)save{
    BOOL shouldUpdateNotifications = NO;
    for(KPToDo *toDo in toDos){
        if(!toDo.completionDate && !toDo.parent)
            shouldUpdateNotifications = YES;
        [toDo deleteToDoSave:NO];
    }
    if (save)
             [KPToDo saveToSync];
    if (shouldUpdateNotifications)
             [NOTIHANDLER updateLocalNotifications];
    [ANALYTICS heartbeat];
}
+(void)updateTags:(NSArray *)tags forToDos:(NSArray *)toDos remove:(BOOL)remove save:(BOOL)save{
    if(tags){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@",@"title",tags];
        NSSet *tagsSet = [NSSet setWithArray:[KPTag MR_findAllWithPredicate:predicate]];
        for(KPToDo *toDo in toDos){
            [toDo updateTagSet:tagsSet withTags:tags remove:remove];
        }
        if(save)
            [KPToDo saveToSync];
        [ANALYTICS heartbeat];
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
            NSLog(@"tag:%@",tag);
            if(!tag || !tag.title) continue;
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

-(NSArray*)updateWithObjectFromServer:(NSDictionary *)object context:(NSManagedObjectContext *)context{
    [super updateWithObjectFromServer:object context:context];
    __block NSMutableSet *changedAttributesSet = [NSMutableSet set];
    [context performBlockAndWait:^{
        
        NSDictionary *keyMatch = [self keyMatch];
        // Get changes since start of the sync - not to overwrite recent changes
        NSArray *localChanges = [KPCORE lookupTemporaryChangedAttributesForObject:self.objectId];
        // If the object saved was new - the changes will be for it's tempId not objectId
        if(!localChanges) localChanges = [KPCORE lookupTemporaryChangedAttributesForTempId:self.tempId];
        NSString *parentId = [object objectForKey:@"pparentLocalId"];
        if(!self.parent && parentId && parentId != (id)[NSNull null]){
            KPToDo *parent = [KPToDo MR_findFirstByAttribute:@"objectId" withValue:parentId inContext:context];
            if( parent ){
                self.parent = parent;
            }
        }
            
        for(NSString *pfKey in [object allKeys]){
            if([localChanges containsObject:pfKey])
                continue;
            
            id pfValue = [object objectForKey:pfKey];
            if([pfKey isEqualToString:@"repeatOption"]){
                if(![[self stringForRepeatOption:self.repeatOptionValue] isEqualToString:pfValue]) self.repeatOptionValue = [self optionForRepeatString:pfValue];
                continue;
            }
            if([pfKey isEqualToString:@"tags"]){
                NSArray *tagsFromServer = (NSArray*)pfValue;
                //NSLog(@"tags:%@",tagsFromServer);
                NSMutableArray *objectIDs = [NSMutableArray array];
                if(tagsFromServer && [tagsFromServer isKindOfClass:[NSArray class]]){
                    for(NSDictionary *tag in tagsFromServer){
                        if(tag && (NSNull*)tag != [NSNull null]) [objectIDs addObject:[tag objectForKey:@"objectId"]];
                        else {
                            [changedAttributesSet addObject:@"tags"];
                        }
                    }
                }
                if(objectIDs.count > 0){
                    NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"%K IN %@",@"objectId",[objectIDs copy]];
                    NSArray *tagsObjects = [KPTag MR_findAllWithPredicate:tagPredicate inContext:context];
                    NSMutableArray *tagStrings = [NSMutableArray array];
                    NSInteger tagCount = tagsObjects.count;
                    NSMutableArray *notSortedTags = [NSMutableArray array];
                    for(NSInteger i = 0 ; i < tagCount ; i++) [tagStrings addObject:[NSNull null]];
                    for(KPTag *tag in tagsObjects){
                        if(!tag || tag == (id)[NSNull null] || tag.title.length == 0){
                            [changedAttributesSet addObject:@"tags"];
                            continue;
                        }
                        NSInteger index = [objectIDs indexOfObject:tag.objectId];
                        if(index != NSNotFound && index < tagCount) [tagStrings replaceObjectAtIndex:index withObject:tag.title];
                        else{
                            [notSortedTags addObject:tag.title];
                        }
                    }
                    if(notSortedTags.count > 0){
                        NSInteger counter = 0;
                        for(NSInteger i = 0 ; i < tagCount ; i++){
                            if([tagStrings objectAtIndex:i] == [NSNull null]){
                                counter++;
                                if(notSortedTags.count < counter) [tagStrings replaceObjectAtIndex:i withObject:[notSortedTags objectAtIndex:counter]];
                            }
                        }
                    }
                    [tagStrings removeObjectIdenticalTo:[NSNull null]];
                    self.tagString = [tagStrings componentsJoinedByString:@", "];
                    self.tags = [NSSet setWithArray:tagsObjects];
                    
                }
                else {
                    self.tagString = @"";
                    self.tags = [NSSet set];
                }
                continue;
            }
            
            if([pfKey isEqualToString:@"attachments"]){
                NSArray *attachments = (NSArray*)pfValue;
                [self removeAllAttachmentsForService:@"all"];
                for( NSDictionary *attachmentObj in attachments){
                    NSString *title = [attachmentObj objectForKey:@"title"];
                    NSString *identifier = [attachmentObj objectForKey:@"identifier"];
                    NSString *service = [attachmentObj objectForKey:@"service"];
                    BOOL sync = [[attachmentObj objectForKey:@"sync"] boolValue];
                    KPAttachment* attachment = [KPAttachment attachmentForService:service title:title identifier:identifier sync:sync inContext:context];
                    // add the new attachment
                    [self addAttachments:[NSSet setWithObject:attachment]];
                }
                continue;
            }
            
            NSString *cdKey = [keyMatch objectForKey:pfKey];
            if(cdKey){
                
                id cdValue = [self valueForKey:cdKey];
                if([pfValue isKindOfClass:[NSDictionary class]] && [[pfValue objectForKey:@"__type"] isEqualToString:@"Date"]){
                    NSDateFormatter *dateFormatter = [Global isoDateFormatter];
                    pfValue = [dateFormatter dateFromString:[pfValue objectForKey:@"iso"]];
                }
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
    if(changedAttributesSet.count > 0) return [changedAttributesSet allObjects];
    else return nil;
}
-(BOOL)setAttributesForSavingObject:(NSMutableDictionary *__autoreleasing *)object changedAttributes:(NSArray *)changedAttributes{
    NSDictionary *keyMatch = [self keyMatch];
    BOOL isNewObject = (!self.objectId);
    if(changedAttributes && [changedAttributes containsObject:@"all"]) isNewObject = YES;
    BOOL shouldUpdate = NO;
    for(NSString *pfKey in keyMatch){
        NSString *cdKey = [keyMatch objectForKey:pfKey];
        if(isNewObject || [changedAttributes containsObject:cdKey]){
            if([[self valueForKey:cdKey] isKindOfClass:[NSDate class]]){
                NSDateFormatter *dateFormatter = [Global isoDateFormatter];
                NSString *isoString = [dateFormatter stringFromDate:[self valueForKey:cdKey]];
                [*object setObject:@{@"__type":@"Date",@"iso":isoString} forKey:pfKey];
            }
            else if([self valueForKey:cdKey]) [*object setObject:[self valueForKey:cdKey] forKey:pfKey];
            else([*object setObject:[NSNull null] forKey:pfKey]);
            shouldUpdate = YES;
        }
    }
    if(isNewObject || [changedAttributes containsObject:@"repeatOption"]){
        [*object setObject:[self stringForRepeatOption:self.repeatOptionValue] forKey:@"repeatOption"];
        shouldUpdate = YES;
    }
    if ( (isNewObject || [changedAttributes containsObject:@"parent"]) && self.parent ){
        NSString *parentId = self.parent.objectId;
        if ( !parentId )
            parentId = self.parent.tempId;
        if( parentId ){
            [*object setObject:parentId forKey:@"parentLocalId"];
            shouldUpdate = YES;
        }
    }
    
    if( (isNewObject || [changedAttributes containsObject:@"attachments"]) ){
        NSMutableArray *attachmentArray = [NSMutableArray array];
        
        for ( KPAttachment *attachment in self.attachments ){
            [attachmentArray addObject:[attachment jsonForSaving]];
        }
        if ( !( isNewObject && attachmentArray.count == 0 ) ){
            [*object setObject:[attachmentArray copy] forKey:@"attachments"];
            shouldUpdate = YES;
        }
    }
    
    if(isNewObject || [changedAttributes containsObject:@"tags"]){
        NSInteger tagCount = self.tags.count;
        NSMutableArray *tagArray = [NSMutableArray arrayWithCapacity:tagCount];
        NSArray *tagsFromString = [self.tagString componentsSeparatedByString:@", "];
        for (NSInteger i = 0; i < tagCount; ++i)
            [tagArray addObject:[NSNull null]];
        NSMutableArray *emptyObjects = [NSMutableArray array];
        /* Prepare the tag objects pointers for saving - include tempId + objectId if exist */
        for(KPTag *tag in self.tags){
            
            NSMutableDictionary *tagObj = [NSMutableDictionary dictionaryWithObject:[tag getTempId] forKey:@"tempId"];
            [tagObj setObject:@"Tag" forKey:@"className"];
            if(tag.objectId) [tagObj setObject:tag.objectId forKey:@"objectId"];
            
            NSInteger index = [tagsFromString indexOfObject:tag.title];
            if(index != NSNotFound && index < tagCount) [tagArray replaceObjectAtIndex:index withObject:tagObj];
            else [emptyObjects addObject:tagObj];
        }
        
        if(emptyObjects.count > 0){
            NSInteger emptyCount = 0;
            for(NSInteger i = 0 ; i < tagArray.count ; i++){
                if([tagArray objectAtIndex:i] == [NSNull null]){
                    [tagArray replaceObjectAtIndex:i withObject:[emptyObjects objectAtIndex:emptyCount++]];
                }
            }
        }
        if( !( isNewObject && tagCount == 0 ) ){
            // Don't send 0 tags if new object
            [*object setObject:tagArray forKey:@"tags"];
            shouldUpdate = YES;
        }
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
    if(save) [KPToDo saveToSync];
}

- (RepeatOptions)optionForRepeatString:(NSString *)repeatString {
    RepeatOptions option = RepeatNever;
    
    if([repeatString isEqualToString:@"every day"])
        option = RepeatEveryDay;
    else if([repeatString isEqualToString:@"mon-fri or sat+sun"])
        option = RepeatEveryMonFriOrSatSun;
    else if([repeatString isEqualToString:@"every week"])
        option = RepeatEveryWeek;
    else if([repeatString isEqualToString:@"every month"])
        option = RepeatEveryMonth;
    else if([repeatString isEqualToString:@"every year"])
        option = RepeatEveryYear;

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

+(void)saveToSync{
    [KPCORE saveContextForSynchronization:nil];
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
-(BOOL)isSubtask{
    return (self.parent) ? YES : NO;
}

+(NSArray*)sortOrderForItems:(NSArray*)items newItemsOnTop:(BOOL)newOnTop save:(BOOL)save{
    NSPredicate *orderedItemsPredicate = [NSPredicate predicateWithFormat:@"(order > %i)",kDefOrderVal];
    NSPredicate *unorderedItemsPredicate = [NSPredicate predicateWithFormat:@"!(order > %i)",kDefOrderVal];
    NSSortDescriptor *orderedItemsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSSortDescriptor *unorderedItemsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"schedule" ascending:NO];
    NSArray *orderedItems = [[items filteredArrayUsingPredicate:orderedItemsPredicate] sortedArrayUsingDescriptors:@[orderedItemsSortDescriptor]];
    NSArray *unorderedItems = [[items filteredArrayUsingPredicate:unorderedItemsPredicate] sortedArrayUsingDescriptors:@[unorderedItemsSortDescriptor]];
    int counter = kDefOrderVal + 1;
    NSArray *sortedItems;
    if(newOnTop)
        sortedItems= [unorderedItems arrayByAddingObjectsFromArray:orderedItems];
    else
        sortedItems = [orderedItems arrayByAddingObjectsFromArray:unorderedItems];
    
    NSInteger numberOfChanges = 0;
    if(!unorderedItems || unorderedItems.count == 0) return sortedItems;
    for(KPToDo *toDo in sortedItems){
        if(toDo.orderValue != counter){
            toDo.orderValue = counter;
            numberOfChanges++;
        }
        //NSLog(@"%i - %@",toDo.orderValue,toDo.title);
        counter++;
    }
    if(save && numberOfChanges > 0){
        [KPToDo saveToSync];
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
    return sortedItems;
    
}

-(NSArray*)changeToOrder:(NSInteger)newOrder withItems:(NSArray *)items{
    if(newOrder == self.orderValue) return nil;
    NSLog(@"change:%i - %i",self.orderValue,newOrder);
    BOOL decrease = (newOrder > self.orderValue);
    NSString *predicateRawString = (newOrder > self.orderValue) ? @"(order > %i) AND (order =< %i)" : @"(order < %i) AND (order >= %i)";
    
    NSPredicate *betweenPredicate = [NSPredicate predicateWithFormat: predicateRawString, self.orderValue, newOrder];
    NSArray *results = [[items filteredArrayUsingPredicate:betweenPredicate] sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES]]];
    self.orderValue = newOrder;
    for (int i = 0 ; i < results.count; i++) {
        KPToDo *toDo = [results objectAtIndex:i];
       
        if(decrease) toDo.orderValue--;
        else toDo.orderValue++;
        //NSLog(@"r %i - %@",toDo.orderValue,toDo.title);
    }
    
    [KPToDo saveToSync];
    
    [ANALYTICS heartbeat];
    NSArray *newOrderItems = [items sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES]]];
    return newOrderItems;
}

-(void)updateTagSet:(NSSet*)tagsSet withTags:(NSArray*)tags remove:(BOOL)remove{
    
    NSMutableArray *tagsStrings = [NSMutableArray array];
    if(self.tagString.length > 0)
        tagsStrings = [[self.tagString componentsSeparatedByString:@", "] mutableCopy];
    
    if (remove)
        [self removeTags:tagsSet];
    else
        [self addTags:tagsSet];
    
    for(NSString *tag in tags){
        BOOL contained = [tagsStrings containsObject:tag];
        if(remove && contained)
            [tagsStrings removeObject:tag];
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
    [self beforeDelete];
    [self MR_deleteEntity];
    if(save)
        [KPToDo saveToSync];
}
-(void)beforeDelete{
    if(self.subtasks.count > 0){
        [KPToDo deleteToDos:[self.subtasks allObjects] save:NO];
    }
}

-(void)switchPriority{
    self.priorityValue = (self.priorityValue == 0) ? 1 : 0;
    [KPToDo saveToSync];
    if(self.priorityValue == 1)
        [kHints triggerHint:HintPriority];
}

-(BOOL)notifyOnLocation:(CLPlacemark*)location type:(GeoFenceType)type{
    /*
        Location ID -
    */
    CellType oldCell = [self cellTypeForTodo];
    
    CGFloat latitude = location.location.coordinate.latitude;
    CGFloat longitude = location.location.coordinate.longitude;
    NSArray *lines = location.addressDictionary[ @"FormattedAddressLines"];
    NSString *locationName = [lines componentsJoinedByString:@", "];
    NSString *locationId;
    if(self.location){
        NSArray *existingLocation = [self.location componentsSeparatedByString:kLocationSplitStr];
        locationId = [existingLocation objectAtIndex:0];
    }
    if(!locationId) locationId = [UtilityClass generateIdWithLength:5];
    NSString *typeString = @"IN";
    if(type == GeoFenceOnLeave) typeString = @"OUT";
    
    NSArray *locationArray = @[locationId,locationName,@(latitude),@(longitude),typeString];
    
    NSString *locationString = [locationArray componentsJoinedByString:kLocationSplitStr];
    self.location = locationString;
    self.schedule = nil;
    self.completionDate = nil;
    
    CellType newCell = [self cellTypeForTodo];
    return (oldCell != newCell);
}
-(void)stopNotifyingLocationSave:(BOOL)save{
    self.location = nil;
    if(save) [KPToDo saveToSync];
    [NOTIHANDLER updateLocationUpdates];
}
-(NSArray *)textTags{
    return Underscore.array([self.tagString componentsSeparatedByString:@", "]).filter(Underscore.isString).reject(^BOOL (NSString *tag){ return (tag.length == 0); }).unwrap;

}
-(void)completeRepeatedTask{
    if(self.repeatOptionValue == RepeatNever) return;
    NSDate *next = [self nextDateFrom:self.repeatedDate];
    
    NSInteger numberOfRepeated = self.numberOfRepeatedValue;
    while ([next isInPast]) {
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
    if(self.location) self.location = nil;
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

-(BOOL)scheduleForDate:(NSDate*)date
{
    if (self.location)
        self.location = nil;
    
    if (!date) {
        self.repeatedDate = nil;
        self.repeatOptionValue = RepeatNever;
    }
    CellType oldCell = [self cellTypeForTodo];
    self.schedule = date;
    /* If this task was completed less than 15 minutes ago - don't put at the top of the stack but in it's old place */
    if(self.completionDate && [self.completionDate minutesBeforeDate:[NSDate date]] > 15) self.orderValue = kDefOrderVal;
    self.completionDate = nil;
    CellType newCell = [self cellTypeForTodo];
    return (oldCell != newCell);
}

#pragma mark - Attachments
- (void)updateAttachmentFromObjects:(NSArray*)attachments{
    
   
}
- (void)attachService:(NSString *)service title:(NSString *)title identifier:(NSString *)identifier sync:(BOOL)sync
{
    // remove all present attachments for this service
    [self removeAllAttachmentsForService:service];
    
    // create the attachment
    KPAttachment* attachment = [KPAttachment attachmentForService:service title:title identifier:identifier sync:sync];
    
    // add the new attachment
    [self addAttachments:[NSSet setWithObject:attachment]];
}

- (void)removeAllAttachmentsForService:(NSString *)service
{
    NSMutableSet* attachmentSet = [NSMutableSet set];
    for (KPAttachment* att in self.attachments) {
        if ([att.service isEqualToString:service] || [service isEqualToString:@"all"]) {
            [attachmentSet addObject:att];
        }
    }
    if (0 < attachmentSet.count) {
        [self removeAttachments:attachmentSet];
    }
}

- (KPAttachment *)firstAttachmentForServiceType:(NSString *)service
{
    for (KPAttachment* attachment in self.attachments) {
        if ([attachment.service isEqualToString:service])
            return attachment;
    }
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"KPToDo -> title: %@, order: %@, priority: %@", self.title, self.order, self.priority];
}

@end
