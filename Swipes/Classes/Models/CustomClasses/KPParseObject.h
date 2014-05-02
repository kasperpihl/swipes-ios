#import "_KPParseObject.h"
#import "KPParseCommunicator.h"
@interface KPParseObject : _KPParseObject {}
+(KPParseObject *)newObjectInContext:(NSManagedObjectContext*)context;
+(KPParseObject *)getCDObjectFromObject:(NSDictionary*)object context:(NSManagedObjectContext*)context;
+(BOOL)deleteObject:(NSDictionary*)object context:(NSManagedObjectContext*)context;
-(void)beforeDelete;
/* 
 update called on sync - overwritten in subclass
 return Array with affected changed attributes that needs sync after update
 return nil if no
*/
-(NSArray*)updateWithObjectFromServer:(NSDictionary*)object context:(NSManagedObjectContext*)context;
-(NSString*)getParseClassName;
-(NSString*)getTempId;

/* To use saveWithHandler: overwrite setAttributesForSavingObject: in subclass to set all the attributes to save */
-(NSDictionary*)objectToSaveInContext:(NSManagedObjectContext *)context changedAttributes:(NSArray*)attributes;

/* 
 Method to overwrite in subclass (KPToDo/KPTag)
 Gets called with the a dictionary and the array of changed attributes
*/
-(BOOL)setAttributesForSavingObject:(NSMutableDictionary**)object changedAttributes:(NSArray*)changedAttributes;
@end