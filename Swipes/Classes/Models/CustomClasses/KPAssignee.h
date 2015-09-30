#import "_KPAssignee.h"

@interface KPAssignee : _KPAssignee {}

+(KPAssignee *)addAssigneeWithUserId:(NSString *)userId save:(BOOL)save from:(NSString *)from inContext:(NSManagedObjectContext*)context;
+(KPAssignee *)findByUserId:(NSString *)userId inContext:(NSManagedObjectContext*)context;

@end
