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
      @"order": @"order"
    };
}
#define checkStringWithKey(object, pfKey, cdKey) if(![[self valueForKey:cdKey] isEqualToString:[object objectForKey:pfKey]]) [self setValue:[object valueForKey:pfKey] forKey:cdKey]
#define checkDateWithKey(object, pfKey, cdKey) if(![[self valueForKey:cdKey] isEqualToDate:[object objectForKey:pfKey]]) [self setValue:[object valueForKey:pfKey] forKey:cdKey]
#define checkNumberWithKey(object, pfKey, cdKey) if(![[self valueForKey:cdKey] isEqualToNumber:[object objectForKey:pfKey]]) [self setValue:[object valueForKey:pfKey] forKey:cdKey]
-(void)updateWithObject:(PFObject *)object context:(NSManagedObjectContext *)context{
    [super updateWithObject:object context:context];
    [context performBlockAndWait:^{
        NSDictionary *keyMatch = [self keyMatch];
        for(NSString *pfKey in [object allKeys]){
            if([pfKey isEqualToString:@"repeatOption"]){
                if(![[self stringForRepeatOption:self.repeatOptionValue] isEqualToString:[object objectForKey:@"repeatOption"]]) self.repeatOptionValue = [self optionForRepeatString:[object objectForKey:@"repeatOption"]];
                continue;
            }
            NSString *cdKey = [keyMatch objectForKey:pfKey];
            if(cdKey){
                id cdValue = [self valueForKey:cdKey];
                if([cdValue isKindOfClass:[NSString class]]){ checkStringWithKey(object, pfKey, cdKey); }
                else if([cdValue isKindOfClass:[NSDate class]]){ checkDateWithKey(object, pfKey, cdKey); }
                else if([cdValue isKindOfClass:[NSNumber class]]){ checkNumberWithKey(object, pfKey, cdKey); }
            }
        }
    }];
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
    return shouldUpdate;
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
        if([time isSameYearAsDate:[NSDate date]]) dateFormatter.dateFormat = @"d LLL";
        else dateFormatter.dateFormat = @"d LLL  '´'yy";
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
        title = [NSString stringWithFormat:@"Completed %@",dateString];
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
#warning Handle deleted objects in synchronize
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
