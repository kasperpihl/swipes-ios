#import "KPToDo.h"

#import "KPTag.h"
@interface KPToDo ()
@property (nonatomic,strong) NSString *readableTags;
// Private interface goes here.

@end


@implementation KPToDo
@synthesize readableTags = _readableTags;
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
    NSInteger count = self.tags.count;
    if(count > 0){
        NSSortDescriptor * titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        NSArray *tags = [self.tags sortedArrayUsingDescriptors:@[titleDescriptor]];
        mutableString = [NSMutableString stringWithString:@""];
        for(KPTag *tag in tags){
            [mutableString appendFormat:@"%@, ",tag.title];
        }
        [mutableString deleteCharactersInRange:NSMakeRange([mutableString length]-2, 2)];
    }
    self.readableTags = [mutableString copy];
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
