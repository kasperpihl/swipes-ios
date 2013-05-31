#import "KPToDo.h"

#import "KPTag.h"

@interface KPToDo ()
@property (nonatomic,strong) NSString *readableTags;
// Private interface goes here.

@end


@implementation KPToDo
@synthesize readableTags = _readableTags;
@synthesize textTags = _textTags;
@synthesize tagString = _tagString;
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
