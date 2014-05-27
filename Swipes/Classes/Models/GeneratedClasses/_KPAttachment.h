// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KPAttachment.h instead.

#import <CoreData/CoreData.h>


extern const struct KPAttachmentAttributes {
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *service;
	__unsafe_unretained NSString *sync;
	__unsafe_unretained NSString *title;
} KPAttachmentAttributes;

extern const struct KPAttachmentRelationships {
	__unsafe_unretained NSString *todo;
} KPAttachmentRelationships;

extern const struct KPAttachmentFetchedProperties {
} KPAttachmentFetchedProperties;

@class KPToDo;






@interface KPAttachmentID : NSManagedObjectID {}
@end

@interface _KPAttachment : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (KPAttachmentID*)objectID;





@property (nonatomic, strong) NSString* identifier;



//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* service;



//- (BOOL)validateService:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sync;



@property BOOL syncValue;
- (BOOL)syncValue;
- (void)setSyncValue:(BOOL)value_;

//- (BOOL)validateSync:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) KPToDo *todo;

//- (BOOL)validateTodo:(id*)value_ error:(NSError**)error_;





@end

@interface _KPAttachment (CoreDataGeneratedAccessors)

@end

@interface _KPAttachment (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;




- (NSString*)primitiveService;
- (void)setPrimitiveService:(NSString*)value;




- (NSNumber*)primitiveSync;
- (void)setPrimitiveSync:(NSNumber*)value;

- (BOOL)primitiveSyncValue;
- (void)setPrimitiveSyncValue:(BOOL)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (KPToDo*)primitiveTodo;
- (void)setPrimitiveTodo:(KPToDo*)value;


@end
