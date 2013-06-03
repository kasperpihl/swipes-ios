#import "KPToDo.h"

#import "NotificationHandler.h"
#import "KPTag.h"
#import "NSDate-Utilities.h"
@interface KPToDo ()
@property (nonatomic,strong) NSString *readableTags;
// Private interface goes here.

@end


@implementation KPToDo
@synthesize readableTags = _readableTags;
@synthesize textTags = _textTags;
@synthesize tagString = _tagString;
-(CellType)cellTypeForTodo{
    if([self.state isEqualToString:@"done"]) return CellTypeDone;
    else if([self.state isEqualToString:@"scheduled"]){
        if([self.schedule isLaterThanDate:[[NSDate dateTomorrow] dateAtStartOfDay]] || !self.schedule) return CellTypeSchedule;
        else return CellTypeToday;
    }
    return CellTypeNone;
}
-(void)updateAlarm:(NSDate*)alarm force:(BOOL)force save:(BOOL)save{
    if([self.alarm isEqualToDate:alarm] && !force) return;
    self.alarm = alarm;
    NSString *identifier = [[self.objectID URIRepresentation] absoluteString];
    [NOTIHANDLER updateAlarm:self.alarm identifier:identifier title:self.title];
    if(save) [self save];
}
-(void)save{
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
}
-(NSString *)readableTime:(NSDate*)time{
    if(!time) return nil;
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];
    NSString *timeString = [timeFormatter stringFromDate:time];
    
    NSInteger numberOfDaysAfterTodays = [time daysAfterDate:[NSDate date]];
    NSString *dateString;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    BOOL shouldFormat = NO;
    if(time.isToday) dateString = @"Today";
    else if(numberOfDaysAfterTodays == 1) dateString = @"Tomorrow";
    else if(numberOfDaysAfterTodays < 7){
        [dateFormatter setDateFormat:@"EEEE"];
        shouldFormat = YES;
    }
    else{
        [dateFormatter setDateFormat:@"d MMMM"];
        shouldFormat = YES;
    }
    if(shouldFormat){
        dateString = [dateFormatter stringFromDate:time];
    }
    
    return [[NSString stringWithFormat:@"%@, %@",dateString,timeString] capitalizedString];
    
}
-(NSString *)readableTitleForStatus{
    NSString *title;
    CellType cellType = [self cellTypeForTodo];
    if(cellType == CellTypeToday) title = @"Schedule Today";
    else if(cellType == CellTypeSchedule){
        NSDate *toDoDate = self.schedule;
        if(!toDoDate) title = @"Unspecified";
        else if(toDoDate.isTomorrow) title = @"Schedule Tomorrow";
        else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE, dd-MM"];
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [dateFormatter setLocale:usLocale];
            NSString *strDate = [dateFormatter stringFromDate:toDoDate];
            title = [NSString stringWithFormat:@"Schedule %@",strDate];
        }
    }
    else if(cellType == CellTypeDone){
        NSDate *toDoDate = self.completionDate;
        if(toDoDate.isToday) title = @"Completed Today";
        else if(toDoDate.isYesterday) title = @"Completed Yesterday";
        else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [dateFormatter setLocale:usLocale];
            // this is imporant - we set our input date format to match our input string
            // if format doesn't match you'll get nil from your string, so be careful
            [dateFormatter setDateFormat:@"Completed dd-MM-yyyy"];
            // voila!
            NSString *strDate = [dateFormatter stringFromDate:toDoDate];
            title = strDate;
        }
    }
    
    return [title capitalizedString];
}
-(void)changeToOrder:(NSInteger)newOrder{
    if(newOrder == self.orderValue) return;
    BOOL decrease = (newOrder > self.orderValue);
    NSString *predicateRawString = (newOrder > self.orderValue) ? @"(order > %i) AND (order =< %i) AND state == %@" : @"(order < %i) AND (order >= %i) AND state == %@";
    
    NSPredicate *betweenPredicate = [NSPredicate predicateWithFormat: predicateRawString, self.orderValue, newOrder,self.state];
    NSArray *results = [KPToDo MR_findAllSortedBy:@"order" ascending:YES withPredicate:betweenPredicate];
    self.orderValue = newOrder;
    for (int i = 0 ; i < results.count; i++) {
        KPToDo *toDo = [results objectAtIndex:i];
        if(decrease) toDo.orderValue--;
        else toDo.orderValue++;
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
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
-(NSArray *)textTags{
    return [self.tagString componentsSeparatedByString:@", "];
}
-(NSString *)stringifyTags{
    return self.tagString;
    /*if(!self.readableTags) [self updateTagsString];
    return self.readableTags;*/
}
-(void)complete{
    self.state = @"done";
    self.completionDate = [NSDate date];
}
-(void)scheduleForDate:(NSDate*)date{
    self.schedule = date;
    self.state = @"scheduled";
}
@end
