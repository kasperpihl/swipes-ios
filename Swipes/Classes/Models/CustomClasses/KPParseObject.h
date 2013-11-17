#import "_KPParseObject.h"
#import "KPParseCommunicator.h"
@interface KPParseObject : _KPParseObject {}
+(KPParseObject *)newObjectInContext:(NSManagedObjectContext*)context;
+(KPParseObject *)getCDObjectFromObject:(PFObject*)object context:(NSManagedObjectContext*)context;
+(KPParseObject *)objectById:(NSString *)identifier context:(NSManagedObjectContext*)context;
+(BOOL)deleteObjectById:(NSString*)identifier context:(NSManagedObjectContext*)context;
-(void)updateWithObject:(PFObject*)object context:(NSManagedObjectContext*)context;

/* To use saveWithHandler: overwrite setAttributesForSavingObject: in subclass to set all the attributes to save */
-(PFObject*)objectToSaveInContext:(NSManagedObjectContext *)context;
-(BOOL)setAttributesForSavingObject:(PFObject**)object changedAttributes:(NSArray*)changedAttributes;
-(PFObject*)emptyObjectForSaving;
+(PFObject*)objectForDeletionWithClassName:(NSString*)className objectId:(NSString*)objectId;
/* Overwrite for completion handler after saving */

/* File handling */
-(void)getDataforKey:(NSString*)key withCompletion:(DataBlock)downloadComplete;
-(void)setFile:(PFFile*)file forKey:(NSString*)key;
@end