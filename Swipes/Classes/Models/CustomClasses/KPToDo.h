#import "_KPToDo.h"

@interface KPToDo : _KPToDo {}
-(void)changeToOrder:(NSInteger)newOrder;
-(void)setForToday;
-(void)complete;
-(void)scheduleForDate:(NSDate*)date;
-(void)updateTagsString;
-(NSString *)stringifyTags;
@end
