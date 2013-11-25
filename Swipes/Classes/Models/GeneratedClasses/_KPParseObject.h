// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KPParseObject.h instead.

#import <CoreData/CoreData.h>


extern const struct KPParseObjectAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *objectId;
	__unsafe_unretained NSString *parseClassName;
	__unsafe_unretained NSString *tempId;
	__unsafe_unretained NSString *updatedAt;
} KPParseObjectAttributes;

extern const struct KPParseObjectRelationships {
} KPParseObjectRelationships;

extern const struct KPParseObjectFetchedProperties {
} KPParseObjectFetchedProperties;








@interface KPParseObjectID : NSManagedObjectID {}
@end

@interface _KPParseObject : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (KPParseObjectID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* objectId;



//- (BOOL)validateObjectId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* parseClassName;



//- (BOOL)validateParseClassName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* tempId;



//- (BOOL)validateTempId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;






@end

@interface _KPParseObject (CoreDataGeneratedAccessors)

@end

@interface _KPParseObject (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveObjectId;
- (void)setPrimitiveObjectId:(NSString*)value;




- (NSString*)primitiveParseClassName;
- (void)setPrimitiveParseClassName:(NSString*)value;




- (NSString*)primitiveTempId;
- (void)setPrimitiveTempId:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;




@end
