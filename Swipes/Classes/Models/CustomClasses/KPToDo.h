#import "_KPToDo.h"
@class CLPlacemark;
@interface KPToDo : _KPToDo {}
@property (nonatomic,strong) NSArray *textTags;
/* Add a new ToDo */
+(KPToDo*)addItem:(NSString *)item priority:(BOOL)priority tags:(NSArray*)tags save:(BOOL)save;
/* Schedule ToDo's - The array contains the items that changed state */
+(NSArray*)scheduleToDos:(NSArray*)toDoArray forDate:(NSDate *)date save:(BOOL)save;
/* Complete ToDo's - The array contains the items that changed state */
+(NSArray*)completeToDos:(NSArray*)toDoArray save:(BOOL)save;
/* Delete ToDo's */
+(void)deleteToDos:(NSArray*)toDos save:(BOOL)save;
/* Update Tags for ToDo's */
+(void)updateTags:(NSArray *)tags forToDos:(NSArray *)toDosArray remove:(BOOL)remove save:(BOOL)save;
/* Start watching for Location */
+(NSArray*)notifyToDos:(NSArray *)toDoArray onLocation:(CLPlacemark*)location type:(GeoFenceType)type save:(BOOL)save;

/* Selected tags for ToDo's */
+(NSArray *)selectedTagsForToDos:(NSArray*)toDos;

+(NSArray*)sortOrderForItems:(NSArray*)items save:(BOOL)save;


-(NSArray*)changeToOrder:(NSInteger)newOrder withItems:(NSArray*)items;

-(CellType)cellTypeForTodo;
-(NSMutableAttributedString*)stringForSelectedTags:(NSArray*)selectedTags;

-(NSString*)readableTitleForStatus;
-(void)setRepeatOption:(RepeatOptions)option save:(BOOL)save;
-(NSArray*)nextNumberOfRepeatedDates:(NSInteger)numberOfDates;
+(void)saveToSync;
@end
