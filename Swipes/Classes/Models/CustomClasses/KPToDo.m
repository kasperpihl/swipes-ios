
#import "NotificationHandler.h"
#import "KPTag.h"
#import "UtilityClass.h"
#ifndef NOT_APPLICATION
#import "NSDate-Utilities.h"
#else
#import "NSDate+UtilitiesiOS8.h"
#endif
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
      @"origin": @"origin",
      @"originIdentifier": @"originIdentifier",
      @"priority":@"priority"
    };
}
#define checkStringWithKey(object, pfValue, cdKey, cdValue) if(![cdValue isEqualToString:pfValue]) [self setValue:pfValue forKey:cdKey]
#define checkDateWithKey(object, pfValue, cdKey, cdValue) if(![cdValue isEqualToDate:pfValue]) [self setValue:pfValue forKey:cdKey]
#define checkNumberWithKey(object, pfValue, cdKey, cdValue) if(![cdValue isEqualToNumber:pfValue]) [self setValue:pfValue forKey:cdKey]

+(KPToDo*)addItem:(NSString *)item priority:(BOOL)priority tags:(NSArray *)tags save:(BOOL)save from:(NSString *)from
{
    KPToDo *newToDo = [KPToDo newObjectInContext:nil];
    newToDo.title = item;
    newToDo.schedule = [NSDate date];
    if(priority) newToDo.priorityValue = 1;
    newToDo.orderValue = kDefOrderVal;
    if (tags && tags.count > 0)
        [self updateTags:tags forToDos:@[newToDo] remove:NO save:NO from:@"Add Task"];
    if (save)
        [KPToDo saveToSync];
    [[NSNotificationCenter defaultCenter] postNotificationName:NH_UpdateLocalNotifications object:nil];
    if( from ){
        [ANALYTICS trackEvent:@"Added Task" options:@{@"Length":@(item.length), @"From": from }];
        [ANALYTICS trackCategory:@"Tasks" action:@"Added" label:from value:@(item.length)];
    }
    
    return newToDo;
}

+(NSArray*)scheduleToDos:(NSArray*)toDoArray forDate:(NSDate *)date save:(BOOL)save from:(NSString *)from
{
    NSMutableArray *movedToDos = [NSMutableArray array];
    for(KPToDo *toDo in toDoArray){
        [toDo scheduleForDate:date];
        [movedToDos addObject:toDo];
        if (from) {
        }
    }
    if (save)
        [KPToDo saveToSync];
    [[NSNotificationCenter defaultCenter] postNotificationName:NH_UpdateLocalNotifications object:nil];
    if (from) {
        [ANALYTICS trackEvent:@"Scheduled Tasks" options:@{@"Number of Tasks":@(toDoArray.count), @"From": from }];
        [ANALYTICS trackCategory:@"Tasks" action:@"Scheduled" label:from value:@(toDoArray.count)];
    }
    return [movedToDos copy];
}

+(NSArray*)completeToDos:(NSArray*)toDoArray save:(BOOL)save context:(NSManagedObjectContext*)context from:(NSString *)from {
    __block NSMutableArray *movedToDos = [NSMutableArray array];
    if(!context)
        context = [KPCORE context];
    __block BOOL isSubtasks = NO;
    [context performBlockAndWait:^{
        for(KPToDo *toDo in toDoArray){
            if ( toDo.parent )
                isSubtasks = YES;
            [toDo completeInContext:context];
            [movedToDos addObject:toDo];
        }
        if(save)
            [KPCORE saveContextForSynchronization:context];
    }];
    
    
    if (from) {
        NSNumber *numberOfCompletedTasks = [NSNumber numberWithInteger:toDoArray.count];

        if(!isSubtasks){
            [ANALYTICS trackCategory:@"Tasks" action:@"Completed" label:from value:numberOfCompletedTasks];
            [ANALYTICS trackEvent:@"Completed Tasks" options:@{@"Number of Tasks":numberOfCompletedTasks, @"From": from }];
        }
        else{
            [ANALYTICS trackCategory:@"Action Steps" action:@"Completed" label:from value:nil];
            [ANALYTICS trackEvent:@"Completed Action Step" options:@{ @"From": from }];
        }
        if( !isSubtasks ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:HH_TriggerHint object:@(HintCompleted)];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NH_UpdateLocalNotifications object:nil];
    
    return [movedToDos copy];
}

+(NSArray*)notifyToDos:(NSArray *)toDoArray onLocation:(CLPlacemark*)location type:(GeoFenceType)type save:(BOOL)save
{
    NSMutableArray *movedToDos = [NSMutableArray array];
    for(KPToDo *toDo in toDoArray){
        BOOL movedToDo = [toDo notifyOnLocation:location type:type];
        if (movedToDo)
            [movedToDos addObject:toDo];
    }
    if(save)
        [KPToDo saveToSync];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NH_UpdateLocalNotifications object:nil];
    
    return [movedToDos copy];
}

+(void)deleteToDos:(NSArray*)toDos inContext:(NSManagedObjectContext*)context save:(BOOL)save force:(BOOL)force
{
    BOOL shouldUpdateNotifications = NO;
    BOOL isActionStep = NO;
    for(KPToDo *toDo in toDos){
        if(toDo.parent)
            isActionStep = YES;
        if(!toDo.completionDate && !toDo.parent)
            shouldUpdateNotifications = YES;
        [toDo deleteToDoSave:NO inContext:context force:force];
    }
    if (save)
        [KPToDo saveToSync];
    
    NSNumber *numberOfDeletedTasks = [NSNumber numberWithInteger:toDos.count];
    
    if(!isActionStep){
        [ANALYTICS trackCategory:@"Tasks" action:@"Deleted" label:nil value:numberOfDeletedTasks];
        [ANALYTICS trackEvent:@"Deleted Tasks" options:@{@"Number of Tasks":numberOfDeletedTasks}];
    }
    else{
        [ANALYTICS trackCategory:@"Action Steps" action:@"Deleted" label:nil value:nil];
        [ANALYTICS trackEvent:@"Deleted Action Step" options:nil];
    }
    if (shouldUpdateNotifications)
        [[NSNotificationCenter defaultCenter] postNotificationName:NH_UpdateLocalNotifications object:nil];
}

+(void)updateTags:(NSArray *)tags forToDos:(NSArray *)toDos remove:(BOOL)remove save:(BOOL)save from:(NSString *)from{
    if (tags && [tags isKindOfClass:NSArray.class] && (0 < tags.count)){
        @try {
            NSPredicate *predicate;
            if(tags.count > 1){
                predicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@",@"title",tags];
            }
            else{
                NSString *tag = [tags lastObject];
                if(tag){
                    predicate = [NSPredicate predicateWithFormat:@"title == %@",tag];
                }
            }
            NSSet *tagsSet = [NSSet setWithArray:[KPTag MR_findAllWithPredicate:predicate]];
            for(KPToDo *toDo in toDos){
                
                [toDo updateTagSet:tagsSet withTags:tags remove:remove];
            }
            if(save)
                [KPToDo saveToSync];
            if(from){
                NSDictionary *options = @{ @"Number of Tags": @(tags.count), @"Number of Tasks": @(toDos.count), @"From": from };
                NSString *actionString = remove ? @"Unassigned" : @"Assigned";
                NSString *eventString = remove ? @"Unassign Tags" : @"Assign Tags";
                [ANALYTICS trackCategory:@"Tags" action:actionString label:from value:@(toDos.count)];
                [ANALYTICS trackEvent:eventString options:options];
            }
        }
        @catch (NSException *exception) {
            
            NSMutableDictionary *attachment = [NSMutableDictionary dictionary];
            //NSLog(@"%@",tags);
            if(tags)
                [attachment setObject:attachment forKey:@"tags"];
            [UtilityClass sendException:exception type:@"Update Tags Exception" attachment:attachment];
        }
        
    }
}

+(NSArray *)findByTitle:(NSString *)title
{
    if (title) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@ AND isLocallyDeleted <> YES", title];
        NSArray* result = [KPToDo MR_findAllWithPredicate:predicate];
        if (result && (0 == result.count))
            return nil;
        return result;
    }
    return nil;
}

+(NSArray *)findByTempId:(NSString *)tempId
{
    if (tempId) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tempId = %@", tempId];
        NSArray* result = [KPToDo MR_findAllWithPredicate:predicate];
        if (result && (0 == result.count))
            return nil;
        return result;
    }
    return nil;
}

+(NSArray *)findLocallyDeletedForService:(NSString *)service
{
    if (service) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"isLocallyDeleted = %@", @(YES)];
        NSArray* result = [KPToDo MR_findAllWithPredicate:predicate];
        if (result && (0 == result.count))
            return nil;
        NSMutableArray* todos = [NSMutableArray array];
        for (KPToDo* todo in result) {
            if ([todo firstAttachmentForServiceType:service]) {
                [todos addObject:todo];
            }
        }
        return todos;
    }
    return nil;
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
            if(!tag || !tag.title) continue;
            if(counter == 0) [commonTags addObject:tag.title];
            else{
                if([commonTags containsObject:tag.title]) [common2Tags addObject:tag.title];
            }
        }
        counter++;
    }
    if(counter > 1)
        commonTags = common2Tags;
    return commonTags;
}

+(void)saveToSync{
    [KPCORE saveContextForSynchronization:nil];
}

+(NSArray*)sortOrderForItems:(NSArray*)items newItemsOnTop:(BOOL)newOnTop save:(BOOL)save context:(NSManagedObjectContext*)context{
    if(!context)
        context = KPCORE.context;
    
    __block NSArray *sortedItems;
    [context performBlockAndWait:^{
        NSMutableArray *existingOrders = [NSMutableArray array];
        
        for( KPToDo *todo in items ){
            [existingOrders addObject:todo.order];
        }
        //if(!newOnTop)
        //NSLog(@"%@",[[existingOrders reverseObjectEnumerator] allObjects]);
        
        NSPredicate *orderedItemsPredicate = [NSPredicate predicateWithFormat:@"(order > %i)",kDefOrderVal];
        NSPredicate *unorderedItemsPredicate = [NSPredicate predicateWithFormat:@"!(order > %i)",kDefOrderVal];
        NSSortDescriptor *orderedItemsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        NSSortDescriptor *unorderedItemsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"schedule" ascending:NO];
        NSArray *orderedItems = [[items filteredArrayUsingPredicate:orderedItemsPredicate] sortedArrayUsingDescriptors:@[orderedItemsSortDescriptor]];
        NSArray *unorderedItems = [[items filteredArrayUsingPredicate:unorderedItemsPredicate] sortedArrayUsingDescriptors:@[unorderedItemsSortDescriptor]];
        int counter = kDefOrderVal + 1;
        
        if(newOnTop)
            sortedItems= [unorderedItems arrayByAddingObjectsFromArray:orderedItems];
        else
            sortedItems = [orderedItems arrayByAddingObjectsFromArray:unorderedItems];
        
        NSInteger numberOfChanges = 0;
        for(KPToDo *toDo in sortedItems){
            if(toDo.orderValue != counter){
                toDo.orderValue = counter;
                numberOfChanges++;
                //NSLog(@"changed %i",counter);
            }
            //NSLog(@"%i - %@",toDo.orderValue,toDo.title);
            counter++;
        }
        if(save && numberOfChanges > 0){
            [KPCORE saveContextForSynchronization:context];
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
        
    }];
    return sortedItems;
    
}

-(KPToDo*)addSubtask:(NSString *)title save:(BOOL)save from:(NSString *)from
{
    KPToDo *subTask = [KPToDo newObjectInContext:[self managedObjectContext]];
    subTask.title = title;
    subTask.orderValue = kDefOrderVal;
    subTask.schedule = [NSDate date];
    subTask.parent = self;
    if( save )
        [KPToDo saveToSync];
    
    if (from) {
        [ANALYTICS trackEvent:@"Added Action Step" options:@{@"Length":@(title.length), @"Total Action Steps on Task": @(self.subtasks.count), @"From": from}];
        [ANALYTICS trackCategory:@"Action Steps" action:@"Added" label:from value:@(title.length)];
    }
    return subTask;
}

-(NSArray*)updateWithObjectFromServer:(NSDictionary *)object context:(NSManagedObjectContext *)context{
    [super updateWithObjectFromServer:object context:context];
    __block NSMutableSet *changedAttributesSet = [NSMutableSet set];
    [context performBlockAndWait:^{
        NSDictionary *keyMatch = [self keyMatch];
        // Get changes since start of the sync - not to overwrite recent changes
        NSArray *localChanges = [KPCORE lookupTemporaryChangedAttributesForObject:self.objectId];
        // If the object saved was new - the changes will be for it's tempId not objectId
        if(!localChanges)
            localChanges = [KPCORE lookupTemporaryChangedAttributesForTempId:self.tempId];
        NSString *parentId = [object objectForKey:@"parentLocalId"];
        BOOL didDelete = NO;
        if(!self.parent && parentId && parentId != (id)[NSNull null]){
            KPToDo *parent = [KPToDo MR_findFirstByAttribute:@"objectId" withValue:parentId inContext:context];
            if( parent ){
                self.parent = parent;
            }
            else{
                // Parent didn't exist (maybe a remote delete task)
                didDelete = YES;
                [self deleteToDoSave:NO inContext:context force:YES];
            }
        }
        if(!didDelete){
            //DLog(@"task: %@", self);
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
                    //DLog(@"tags:%@",tagsFromServer);
                    //DLog(@"%@, %@",self, self.objectId);
                    NSMutableArray *objectIDs = [NSMutableArray array];
                    if(tagsFromServer && [tagsFromServer isKindOfClass:[NSArray class]]){
                        for(NSDictionary *tag in tagsFromServer){
                            if(tag && (NSNull*)tag != [NSNull null]) {
                                [objectIDs addObject:[tag objectForKey:@"objectId"]];
                            }
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
                    [self removeAllAttachmentsForService:@"all" identifier:nil inContext:context];
                    for( NSDictionary *attachmentObj in attachments){
                        NSString *title = [attachmentObj objectForKey:@"title"];
                        NSString *identifier = [attachmentObj objectForKey:@"identifier"];
                        NSString *service = [attachmentObj objectForKey:@"service"];
                        NSNumber *syncNumber = [attachmentObj objectForKey:@"sync"];
                        BOOL sync = NO;
                        if (syncNumber && syncNumber != (id)[NSNull null])
                            sync = [syncNumber boolValue];
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
        }
    }];
    if(changedAttributesSet.count > 0)
        return [changedAttributesSet allObjects];
    else
        return nil;
}

-(BOOL)setAttributesForSavingObject:(NSMutableDictionary *__autoreleasing *)object changedAttributes:(NSArray *)changedAttributes
{
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

-(BOOL)hasChangesSinceDate:(NSDate *)date{
    if([self.updatedAt isLaterThanDate:date])
        return YES;
    for( KPToDo *subtask in self.subtasks ){
        if( [subtask.updatedAt isLaterThanDate:date] )
            return YES;
    }
    return NO;
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
    if(option != RepeatNever)
        self.repeatedDate = self.schedule;
    else
        self.repeatedDate = nil;
    
    if(save)
        [KPToDo saveToSync];
    
    [ANALYTICS trackEvent:@"Recurring Task" options:@{@"Reoccurrence":[self stringForRepeatOption:option]}];
    [ANALYTICS trackCategory:@"Tasks" action:@"Recurring" label:[self stringForRepeatOption:option] value:nil];
}

- (RepeatOptions)optionForRepeatString:(NSString *)repeatString {
    RepeatOptions option = RepeatNever;
    if(repeatString && repeatString != (id)[NSNull null]){
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
    }
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

-(KPToDo*)deepCopyInContext:(NSManagedObjectContext*)context
{
    KPToDo *newToDo = [KPToDo newObjectInContext:context];
    newToDo.completionDate = self.completionDate;
    newToDo.notes = self.notes;
    newToDo.order = self.order;
    newToDo.schedule = self.schedule;
    [newToDo setTags:self.tags];
    newToDo.tagString = self.tagString;
    newToDo.title = self.title;
    return newToDo;
}

-(NSString *)readableTitleForStatus
{
    NSString *title;
    CellType cellType = [self cellTypeForTodo];
    
    if(cellType == CellTypeToday)
        title = [NSLocalizedString(@"tasks", nil) capitalizedString];
    else if(cellType == CellTypeSchedule){
        NSDate *toDoDate = self.schedule;
        if(!toDoDate)
            title = NSLocalizedString(@"Unspecified", nil);
        else{
            title = [UtilityClass readableTime:toDoDate showTime:NO];
            if([title isEqualToString:[NSLocalizedString(@"Today", nil) capitalizedString]])
                title = NSLocalizedString(@"Later Today", nil);
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

-(NSSet *)getSubtasks{
    NSArray *allSubtasks = [[self subtasks] allObjects];
    NSMutableSet *notDeletedSubtasks = [NSMutableSet set];
    for( KPToDo *subtask in allSubtasks ){
        if( ![subtask.isLocallyDeleted boolValue] )
            [notDeletedSubtasks addObject:subtask];
    }
    return [notDeletedSubtasks copy];
}

-(BOOL)isSubtask{
    return (self.parent) ? YES : NO;
}

-(NSArray*)changeToOrder:(int32_t)newOrder withItems:(NSArray *)items{
    if(newOrder == self.orderValue)
        return nil;
    //NSLog(@"change:%i - %i",self.orderValue,newOrder);
    BOOL decrease = (newOrder > self.orderValue);
    NSString *predicateRawString = (newOrder > self.orderValue) ? @"(order > %i) AND (order =< %i)" : @"(order < %i) AND (order >= %i)";
    
    NSPredicate *betweenPredicate = [NSPredicate predicateWithFormat: predicateRawString, self.orderValue, newOrder];
    NSArray *results = [[items filteredArrayUsingPredicate:betweenPredicate] sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES]]];
    self.orderValue = newOrder;
    for (int i = 0 ; i < results.count; i++) {
        KPToDo *toDo = [results objectAtIndex:i];
       
        if(decrease)
            toDo.orderValue--;
        else
            toDo.orderValue++;
        //NSLog(@"r %i - %@",toDo.orderValue,toDo.title);
    }
    
    
    [KPToDo saveToSync];
    NSArray *newOrderItems = [items sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES]]];
    /*newOrderItems = [KPToDo sortOrderForItems:newOrderItems newItemsOnTop:NO save:<#(BOOL)#>]*/
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
        else if(!remove && !contained)
            [tagsStrings addObject:tag];
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
    if(!sortedTagString || sortedTagString.length == 0)
        return nil;
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

-(void)deleteToDoSave:(BOOL)save inContext:(NSManagedObjectContext*)context force:(BOOL)force
{
    if(!context)
        context = KPCORE.context;
    
    BOOL shouldDelete = [self shouldDeleteForce:force inContext:context];
    if( shouldDelete ){
        [self removeAllAttachmentsForService:@"all" identifier:nil inContext:context];
        [self MR_deleteEntityInContext:context];
    }
    if(save)
        [KPToDo saveToSync];
}

-(BOOL)shouldDeleteForce:(BOOL)force inContext:(NSManagedObjectContext*)context
{
    if(self.subtasks.count > 0){
        [KPToDo deleteToDos:[self.subtasks allObjects] inContext:context save:NO force:YES];
    }
    else if( self.parent && !force && [self.origin isEqualToString:EVERNOTE_SERVICE]){
        self.isLocallyDeleted = @(YES);
        DLog(@"deleted subtask from Evernote");
        return NO;
    }
    else if (!self.parent && !force && [self firstAttachmentForServiceType:GMAIL_SERVICE]) {
        self.isLocallyDeleted = @(YES);
        DLog(@"deleted Gmail task");
        return NO;
    }
    return YES;
}

-(void)switchPriority{
    self.priorityValue = (self.priorityValue == 0) ? 1 : 0;
    [KPToDo saveToSync];
    NSString *prioritySwitch = self.priorityValue ? @"On" : @"Off";
    [ANALYTICS trackEvent:@"Update Priority" options:@{@"Assigned":prioritySwitch}];
    [ANALYTICS trackCategory:@"Tasks" action:@"Priority" label:prioritySwitch value:nil];
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
    if(!locationId)
        locationId = [UtilityClass generateIdWithLength:5];
    NSString *typeString = @"IN";
    if(type == GeoFenceOnLeave)
        typeString = @"OUT";
    
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
    if(save)
        [KPToDo saveToSync];
    [[NSNotificationCenter defaultCenter] postNotificationName:NH_UpdateLocalNotifications object:nil];
}

-(NSArray *)textTags{
    return Underscore.array([self.tagString componentsSeparatedByString:@", "]).filter(Underscore.isString).reject(^BOOL (NSString *tag){ return (tag.length == 0); }).unwrap;

}


-(void)copyActionStepsToCopy:(KPToDo*)copy inContext:(NSManagedObjectContext *)context{
    for( KPToDo *actionStep in self.subtasks ){
        KPToDo *newToDo = [KPToDo newObjectInContext:context];
        newToDo.completionDate = actionStep.completionDate;
        newToDo.order = actionStep.order;
        newToDo.schedule = actionStep.schedule;
        newToDo.parent = copy;
        newToDo.title = actionStep.title;
        
        if(actionStep.completionDate)
            [actionStep scheduleForDate:nil];
    }
}

-(void)completeRepeatedTaskInContext:(NSManagedObjectContext*)context{
    if (self.repeatOptionValue == RepeatNever)
        return;
    
    NSDate *next = [self nextDateFrom:self.repeatedDate];
    
    int32_t numberOfRepeated = self.numberOfRepeatedValue;
    while ([next isInPast]) {
        next = [self nextDateFrom:next];
    }
    KPToDo *toDoCopy = [self deepCopyInContext:context];
    [self copyActionStepsToCopy:toDoCopy inContext:context];
    toDoCopy.numberOfRepeatedValue = ++numberOfRepeated;
    [toDoCopy completeInContext:context];
    [self scheduleForDate:next];
    self.repeatedDate = next;
    self.numberOfRepeated = [NSNumber numberWithInteger:numberOfRepeated];
}

-(BOOL)completeInContext:(NSManagedObjectContext*)context{
    __block BOOL completed = NO;
    [context performBlockAndWait:^{
        if(self.location)
            self.location = nil;
        if(self.repeatOptionValue > RepeatNever){
            CellType oldCell = [self cellTypeForTodo];
            [self completeRepeatedTaskInContext:context];
            CellType newCell = [self cellTypeForTodo];
            completed = (oldCell != newCell);
        }
        else{
            self.schedule = nil;
            self.completionDate = [NSDate date];
            completed = YES;
        }
    }];
    return completed;
    
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
    if(!self.parent && !(self.completionDate && [self.completionDate minutesBeforeDate:[NSDate date]] < 15))
        self.orderValue = kDefOrderVal;
    self.completionDate = nil;
    CellType newCell = [self cellTypeForTodo];
    return (oldCell != newCell);
}

#pragma mark - Attachments

- (void)attachService:(NSString *)service title:(NSString *)title identifier:(NSString *)identifier inContext:(NSManagedObjectContext *)context sync:(BOOL)sync from:(NSString *)from
{
    if(!context)
        context = KPCORE.context;
    // add the new attachment
    [context performBlockAndWait:^{
        // remove all present attachments for this service
        [self removeAllAttachmentsForService:service identifier:identifier inContext:context];
        NSString* newTitle = (title.length > kTitleMaxLength) ? [title substringToIndex:kTitleMaxLength] : title;
        // create the attachment
        KPAttachment* attachment = [KPAttachment attachmentForService:service title:newTitle identifier:identifier sync:sync inContext:context];
        [self addAttachments:[NSSet setWithObject:attachment]];
    }];
    
    if( from ){
        NSDictionary *options = @{ @"Service": service, @"From": from };
        [ANALYTICS trackEvent:@"Added Attachment" options:options];
        [ANALYTICS trackCategory:@"Tasks" action:@"Attachment" label:service value:nil];
    }
}

- (void)removeAllAttachmentsForService:(NSString *)service identifier:(NSString*)identifier inContext:(NSManagedObjectContext *)context
{
    if(!context)
        context = KPCORE.context;
    [context performBlockAndWait:^{
        NSMutableSet* attachmentSet = [NSMutableSet set];
        for (KPAttachment* att in self.attachments) {
            if ([att.service isEqualToString:service] || [service isEqualToString:@"all"]) {
                if(!identifier || [identifier isEqualToString:att.identifier])
                    [attachmentSet addObject:att];
            }
        }
        if (0 < attachmentSet.count) {
            [self removeAttachments:attachmentSet];
            for(KPAttachment *att in attachmentSet ){
                [att MR_deleteEntityInContext:context];
            }
            for ( KPToDo *todo in self.subtasks ){
                if([todo.origin isEqualToString:service]){
                    //todo.originIdentifier = nil;
                    todo.origin = nil;
                }
            }
        }
    }];
    
}

+(void)removeAllAttachmentsForAllToDosWithService:(NSString *)service inContext:(NSManagedObjectContext *)context save:(BOOL)save{
    if(!context)
        context = KPCORE.context;
    NSArray *attachments = [KPAttachment MR_findByAttribute:@"service" withValue:EVERNOTE_SERVICE inContext:context];
    NSArray *tasks = [KPToDo MR_findByAttribute:@"origin" withValue:EVERNOTE_SERVICE];
    [context performBlockAndWait:^{
        for( KPAttachment *attachment in attachments ){
            [attachment MR_deleteEntityInContext:context];
        }
        for ( KPToDo *todo in tasks ){
            //todo.originIdentifier = nil;
            todo.origin = nil;
        }
    }];
    if(save)
        [KPCORE saveContextForSynchronization:context];
    
}
-(KPAttachment *)attachmentForService:(NSString *)service identifier:(NSString *)identifier{
    for (KPAttachment* attachment in self.attachments) {
        if ([attachment.service isEqualToString:service] && [attachment.identifier isEqualToString:identifier])
            return attachment;
    }
    return nil;
}
- (KPAttachment *)firstAttachmentForServiceType:(NSString *)service
{
    for (KPAttachment* attachment in self.attachments) {
        if ([attachment.service isEqualToString:service])
            return attachment;
    }
    return nil;
}

+(void)changeTimeZoneFrom:(NSInteger)from to:(NSInteger)to{
    NSInteger difference = from - to;
    NSPredicate *repeatingTaskPredicate = [NSPredicate predicateWithFormat:@"repeatOption > %i",RepeatNever];
    NSArray *tasksToMove = [KPToDo MR_findAllWithPredicate:repeatingTaskPredicate];
    for ( KPToDo *toDo in tasksToMove ){
        if( toDo.repeatedDate )
            toDo.repeatedDate = [toDo.repeatedDate dateByAddingTimeInterval:difference];
        if( toDo.schedule )
            toDo.schedule = [toDo.schedule dateByAddingTimeInterval:difference];
    }
    [KPToDo saveToSync];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"KPToDo -> title: %@, order: %@, origin: %@ - %@, parent: %@, completionDate: %@, schedule: %@, isLocallyDeleted: %@",
            self.title, self.order, self.origin, self.originIdentifier, self.parent, self.completionDate, self.schedule, self.isLocallyDeleted];
}

@end
