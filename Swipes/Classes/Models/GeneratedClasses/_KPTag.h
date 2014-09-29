// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KPTag.h instead.

#import <CoreData/CoreData.h>
#import "KPParseObject.h"

extern const struct KPTagAttributes {
	__unsafe_unretained NSString *title;
} KPTagAttributes;

extern const struct KPTagRelationships {
	__unsafe_unretained NSString *todos;
} KPTagRelationships;

@class KPToDo;

@interface KPTagID : KPParseObjectID {}
@end

@interface _KPTag : KPParseObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) KPTagID* objectID;

@property (nonatomic, strong) NSString* title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *todos;

- (NSMutableSet*)todosSet;

@end

@interface _KPTag (TodosCoreDataGeneratedAccessors)
- (void)addTodos:(NSSet*)value_;
- (void)removeTodos:(NSSet*)value_;
- (void)addTodosObject:(KPToDo*)value_;
- (void)removeTodosObject:(KPToDo*)value_;

@end

@interface _KPTag (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;

- (NSMutableSet*)primitiveTodos;
- (void)setPrimitiveTodos:(NSMutableSet*)value;

@end
