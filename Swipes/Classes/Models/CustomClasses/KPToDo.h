#import "_KPToDo.h"

@interface KPToDo : _KPToDo {}
@property (nonatomic,strong) NSArray *textTags;
-(void)changeToOrder:(NSInteger)newOrder;
-(void)complete;
-(void)scheduleForDate:(NSDate*)date;
-(NSString *)stringifyTags;
-(NSMutableAttributedString*)stringForSelectedTags:(NSArray*)selectedTags;
-(void)updateTagSet:(NSSet*)tagsSet withTags:(NSArray*)tags remove:(BOOL)remove;
@end
