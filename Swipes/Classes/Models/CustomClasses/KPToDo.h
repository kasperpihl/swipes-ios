#import "_KPToDo.h"

@interface KPToDo : _KPToDo {}
@property (nonatomic,strong) NSArray *textTags;
-(void)changeToOrder:(NSInteger)newOrder;
-(BOOL)complete;
-(CellType)cellTypeForTodo;
-(BOOL)scheduleForDate:(NSDate*)date;
-(NSString *)stringifyTags;
-(NSMutableAttributedString*)stringForSelectedTags:(NSArray*)selectedTags;
-(void)updateTagSet:(NSSet*)tagsSet withTags:(NSArray*)tags remove:(BOOL)remove;
-(NSString*)readableTitleForStatus;
-(void)updateNotes:(NSString *)notes save:(BOOL)save;
-(NSString *)readableTime:(NSDate*)time showTime:(BOOL)showTime;
-(void)deleteToDoSave:(BOOL)save;
-(void)updateRepeatedSave:(BOOL)save;
-(void)setRepeatOption:(RepeatOptions)option save:(BOOL)save;
-(NSArray*)nextNumberOfRepeatedDates:(NSInteger)numberOfDates;
@end
