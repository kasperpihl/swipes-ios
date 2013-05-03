#import "KPToDo.h"

#import "KPTag.h"
#define TAGS_LABEL_BOLD_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:12]
#define TAGS_LABEL_FONT [UIFont fontWithName:@"HelveticaNeue" size:12]
@interface KPToDo ()
@property (nonatomic,strong) NSString *readableTags;
// Private interface goes here.

@end


@implementation KPToDo
@synthesize readableTags = _readableTags;
@synthesize textTags = _textTags;
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
-(void)updateTagsString{
    NSMutableString *mutableString;
    NSMutableArray *textTags = [NSMutableArray array];
    NSInteger count = self.tags.count;
    if(count > 0){
        NSSortDescriptor * titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        NSArray *tags = [self.tags sortedArrayUsingDescriptors:@[titleDescriptor]];
        mutableString = [NSMutableString stringWithString:@""];
        for(KPTag *tag in tags){
            [textTags addObject:tag.title];
            [mutableString appendFormat:@"%@, ",tag.title];
        }
        [mutableString deleteCharactersInRange:NSMakeRange([mutableString length]-2, 2)];
    }
    self.textTags = textTags;
    self.readableTags = [mutableString copy];
}
-(NSMutableAttributedString*)stringForSelectedTags:(NSArray*)selectedTags{
    if(!self.readableTags) [self updateTagsString];
    
    NSMutableString *mutableString = [NSMutableString stringWithString:@""];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           TAGS_LABEL_FONT, NSFontAttributeName,
                           nil];
    NSDictionary *boldAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              TAGS_LABEL_BOLD_FONT, NSFontAttributeName, nil];
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:self.readableTags
                                           attributes:attrs];
    for(NSString *tag in self.textTags){
        if([selectedTags containsObject:tag]){
            NSRange range = NSMakeRange(mutableString.length,tag.length);
            [attributedText setAttributes:boldAttrs range:range];
        }
        [mutableString appendFormat:@"%@, ",tag];
    }
    
    
    return attributedText;
    
}
-(NSArray *)textTags{
    if(!_textTags){
        [self updateTagsString];
    }
    return _textTags;
}
-(NSString *)stringifyTags{
    if(!self.readableTags) [self updateTagsString];
    return self.readableTags;
    
}
-(void)setForToday{
    self.state = @"today";
    self.schedule = [NSDate date];
}
-(void)complete{
    self.state = @"done";
    self.completionDate = [NSDate date];
}
-(void)scheduleForDate:(NSDate*)date{
    self.state = @"schedule";
    self.schedule = date;
}
@end
