#import "_KPToDo.h"

@interface KPToDo : _KPToDo {}
-(void)changeToOrder:(NSInteger)newOrder;
-(void)changeState:(NSString*)state;
-(void)setForToday;
-(void)complete;
-(void)scheduleForDate:(NSDate*)date;
@end
