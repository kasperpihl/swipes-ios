#import "_KPToDo.h"

#define kTitleMaxLength 255

@class CLPlacemark;
@interface KPToDo : _KPToDo {}
@property (nonatomic,strong) NSArray *textTags;
/* Add a new ToDo */
+(KPToDo*)addItem:(NSString *)item priority:(BOOL)priority tags:(NSArray*)tags save:(BOOL)save from:(NSString*)from;
/* Schedule ToDo's - The array contains the items that changed state */
+(NSArray*)scheduleToDos:(NSArray*)toDoArray forDate:(NSDate *)date save:(BOOL)save from:(NSString *)from;
/* Complete ToDo's - The array contains the items that changed state */
+(NSArray*)completeToDos:(NSArray*)toDoArray save:(BOOL)save context:(NSManagedObjectContext*)context from:(NSString *)from;
/* Delete ToDo's */
+(void)deleteToDos:(NSArray*)toDos inContext:(NSManagedObjectContext*)context save:(BOOL)save force:(BOOL)force;
/* Update Tags for ToDo's */
+(void)updateTags:(NSArray *)tags forToDos:(NSArray *)toDosArray remove:(BOOL)remove save:(BOOL)save from:(NSString*)from;
/* Start watching for Location */
+(NSArray*)notifyToDos:(NSArray *)toDoArray onLocation:(CLPlacemark*)location type:(GeoFenceType)type save:(BOOL)save;

-(KPToDo*)addSubtask:(NSString*)title save:(BOOL)save from:(NSString*)from;

-(void)switchPriority;

+(NSArray *)findByTitle:(NSString *)title;
+(NSArray *)findByTempId:(NSString *)tempId;
+(NSArray *)findLocallyDeletedForService:(NSString *)service;

/* Selected tags for ToDo's */
+(NSArray *)selectedTagsForToDos:(NSArray*)toDos;

+(NSArray*)sortOrderForItems:(NSArray*)items newItemsOnTop:(BOOL)newOnTop save:(BOOL)save context:(NSManagedObjectContext*)context;

+(void)saveToSync;

+(void)removeAllAttachmentsForAllToDosWithService:(NSString *)service inContext:(NSManagedObjectContext *)context save:(BOOL)save;

+(void)changeTimeZoneFrom:(NSInteger)from to:(NSInteger)to;

-(NSArray*)changeToOrder:(int32_t)newOrder withItems:(NSArray*)items;

-(CellType)cellTypeForTodo;
-(NSMutableAttributedString*)stringForSelectedTags:(NSArray*)selectedTags;

-(NSSet*)getSubtasks;
-(BOOL)isSubtask;
-(BOOL)hasChangesSinceDate:(NSDate*)date;

-(NSString*)readableTitleForStatus;
-(void)setRepeatOption:(RepeatOptions)option save:(BOOL)save;
-(NSArray*)nextNumberOfRepeatedDates:(NSInteger)numberOfDates;
- (void)attachService:(NSString *)service title:(NSString *)title identifier:(NSString *)identifier inContext:(NSManagedObjectContext *)context sync:(BOOL)sync from:(NSString *)from;
-(void) removeAllAttachmentsForService:(NSString *)service identifier:(NSString*)identifier inContext:(NSManagedObjectContext *)context;
- (KPAttachment *)firstAttachmentForServiceType:(NSString *)service;
- (KPAttachment *)attachmentForService:(NSString*)service identifier:(NSString*)identifier;
-(void)deleteToDoSave:(BOOL)save inContext:(NSManagedObjectContext*)context force:(BOOL)force;

@end
