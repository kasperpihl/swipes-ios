#import "_KPParseObject.h"
#import "KPParseCommunicator.h"
@interface KPParseObject : _KPParseObject {}
+(KPParseObject *)object:(PFObject*)object context:(NSManagedObjectContext*)context;
+(KPParseObject *)objectById:(NSString *)identifier context:(NSManagedObjectContext*)context;
+(PFQuery*)query;

-(void)getDataforKey:(NSString*)key withCompletion:(DataBlock)downloadComplete;
-(void)setFile:(PFFile*)file forKey:(NSString*)key;

/* To use saveWithHandler: overwrite setAttributesForSavingObject: in subclass to set all the attributes to save */
-(void)save:(PFObject*)object handler:(SuccessfulBlock)block;
-(PFObject*)setAttributesForSavingObject:(PFObject*)object;
-(void)finishedSaving:(BOOL)successful error:(NSError*)error;
@end
