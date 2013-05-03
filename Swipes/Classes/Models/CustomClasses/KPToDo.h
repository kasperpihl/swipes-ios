#import "_KPToDo.h"

@interface KPToDo : _KPToDo {}
@property (nonatomic,strong) NSArray *textTags;
-(void)changeToOrder:(NSInteger)newOrder;
-(void)setForToday;
-(void)complete;
-(void)scheduleForDate:(NSDate*)date;
-(void)updateTagsString;
-(NSString *)stringifyTags;
-(NSMutableAttributedString*)stringForSelectedTags:(NSArray*)selectedTags;
@end
