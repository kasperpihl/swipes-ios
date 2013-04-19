// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KPToDo.h instead.

#import <CoreData/CoreData.h>
#import "KPParseObject.h"

extern const struct KPToDoAttributes {
	__unsafe_unretained NSString *title;
} KPToDoAttributes;

extern const struct KPToDoRelationships {
} KPToDoRelationships;

extern const struct KPToDoFetchedProperties {
} KPToDoFetchedProperties;




@interface KPToDoID : NSManagedObjectID {}
@end

@interface _KPToDo : KPParseObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (KPToDoID*)objectID;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;






@end

@interface _KPToDo (CoreDataGeneratedAccessors)

@end

@interface _KPToDo (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




@end
