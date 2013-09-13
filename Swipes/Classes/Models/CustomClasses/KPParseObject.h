#import "_KPParseObject.h"
#import "KPParseCommunicator.h"
@interface KPParseObject : _KPParseObject {}
+(KPParseObject *)newObjectInContext:(NSManagedObjectContext*)context;
+(KPParseObject *)getCDObjectFromObject:(PFObject*)object context:(NSManagedObjectContext*)context;
+(KPParseObject *)objectById:(NSString *)identifier context:(NSManagedObjectContext*)context;

-(void)updateWithObject:(PFObject*)object context:(NSManagedObjectContext*)context;

+(PFQuery*)query;
-(void)getDataforKey:(NSString*)key withCompletion:(DataBlock)downloadComplete;
-(void)setFile:(PFFile*)file forKey:(NSString*)key;
-(void)updateChangedAttributes;
/* To use saveWithHandler: overwrite setAttributesForSavingObject: in subclass to set all the attributes to save */
-(PFObject*)objectToSave;
-(void)setAttributesForSavingObject:(PFObject**)object;
/* Overwrite for completion handler after saving */
@end
