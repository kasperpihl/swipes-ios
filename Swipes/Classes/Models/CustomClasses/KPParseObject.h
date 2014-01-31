#import "_KPParseObject.h"
#import "KPParseCommunicator.h"
@interface KPParseObject : _KPParseObject {}
+(KPParseObject *)newObjectInContext:(NSManagedObjectContext*)context;
+(KPParseObject *)getCDObjectFromObject:(NSDictionary*)object context:(NSManagedObjectContext*)context;
+(BOOL)deleteObject:(NSDictionary*)object context:(NSManagedObjectContext*)context;

/* 
 update called on sync - overwritten in subclass
 return YES if it changed anything and needs sync
*/
-(BOOL)updateWithObject:(NSDictionary*)object context:(NSManagedObjectContext*)context;
-(NSString*)getParseClassName;
-(NSString*)getTempId;
/* To use saveWithHandler: overwrite setAttributesForSavingObject: in subclass to set all the attributes to save */
-(NSDictionary*)objectToSaveInContext:(NSManagedObjectContext *)context;

/* 
 Method to overwrite in subclass (KPToDo/KPTag)
 Gets called with the a dictionary and the array of changed attributes
*/
-(BOOL)setAttributesForSavingObject:(NSMutableDictionary**)object changedAttributes:(NSArray*)changedAttributes;
@end