#import "_KPToDo.h"

@interface KPToDo : _KPToDo {}
@property (nonatomic,strong) NSArray *textTags;
-(void)changeToOrder:(NSInteger)newOrder;
-(void)complete;
-(CellType)cellTypeForTodo;
-(void)scheduleForDate:(NSDate*)date;
-(NSString *)stringifyTags;
-(NSMutableAttributedString*)stringForSelectedTags:(NSArray*)selectedTags;
-(void)updateTagSet:(NSSet*)tagsSet withTags:(NSArray*)tags remove:(BOOL)remove;
-(NSString*)readableTitleForStatus;
-(void)updateAlarm:(NSDate*)alarm force:(BOOL)force save:(BOOL)save;
-(void)updateNotes:(NSString *)notes save:(BOOL)save;
-(NSString *)readableTime:(NSDate*)time showTime:(BOOL)showTime;
@end
