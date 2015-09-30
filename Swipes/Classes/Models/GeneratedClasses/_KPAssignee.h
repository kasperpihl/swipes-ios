// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KPAssignee.h instead.

#import <CoreData/CoreData.h>

extern const struct KPAssigneeAttributes {
	__unsafe_unretained NSString *userId;
} KPAssigneeAttributes;

extern const struct KPAssigneeRelationships {
	__unsafe_unretained NSString *todos;
} KPAssigneeRelationships;

@class KPToDo;

@interface KPAssigneeID : NSManagedObjectID {}
@end

@interface _KPAssignee : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) KPAssigneeID* objectID;

@property (nonatomic, strong) NSString* userId;

//- (BOOL)validateUserId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *todos;

- (NSMutableSet*)todosSet;

@end

@interface _KPAssignee (TodosCoreDataGeneratedAccessors)
- (void)addTodos:(NSSet*)value_;
- (void)removeTodos:(NSSet*)value_;
- (void)addTodosObject:(KPToDo*)value_;
- (void)removeTodosObject:(KPToDo*)value_;

@end

@interface _KPAssignee (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveUserId;
- (void)setPrimitiveUserId:(NSString*)value;

- (NSMutableSet*)primitiveTodos;
- (void)setPrimitiveTodos:(NSMutableSet*)value;

@end
