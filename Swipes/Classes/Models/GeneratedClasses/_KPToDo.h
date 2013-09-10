// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KPToDo.h instead.

#import <CoreData/CoreData.h>
#import "KPParseObject.h"

extern const struct KPToDoAttributes {
	__unsafe_unretained NSString *alarm;
	__unsafe_unretained NSString *completionDate;
	__unsafe_unretained NSString *notes;
	__unsafe_unretained NSString *numberOfRepeated;
	__unsafe_unretained NSString *order;
	__unsafe_unretained NSString *repeatOption;
	__unsafe_unretained NSString *repeatedDate;
	__unsafe_unretained NSString *schedule;
	__unsafe_unretained NSString *state;
	__unsafe_unretained NSString *tagString;
	__unsafe_unretained NSString *title;
} KPToDoAttributes;

extern const struct KPToDoRelationships {
	__unsafe_unretained NSString *tags;
} KPToDoRelationships;

extern const struct KPToDoFetchedProperties {
} KPToDoFetchedProperties;

@class KPTag;













@interface KPToDoID : NSManagedObjectID {}
@end

@interface _KPToDo : KPParseObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (KPToDoID*)objectID;





@property (nonatomic, strong) NSDate* alarm;



//- (BOOL)validateAlarm:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* completionDate;



//- (BOOL)validateCompletionDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* notes;



//- (BOOL)validateNotes:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* numberOfRepeated;



@property int32_t numberOfRepeatedValue;
- (int32_t)numberOfRepeatedValue;
- (void)setNumberOfRepeatedValue:(int32_t)value_;

//- (BOOL)validateNumberOfRepeated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* order;



@property int32_t orderValue;
- (int32_t)orderValue;
- (void)setOrderValue:(int32_t)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* repeatOption;



@property int32_t repeatOptionValue;
- (int32_t)repeatOptionValue;
- (void)setRepeatOptionValue:(int32_t)value_;

//- (BOOL)validateRepeatOption:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* repeatedDate;



//- (BOOL)validateRepeatedDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* schedule;



//- (BOOL)validateSchedule:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* state;



//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* tagString;



//- (BOOL)validateTagString:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *tags;

- (NSMutableSet*)tagsSet;





@end

@interface _KPToDo (CoreDataGeneratedAccessors)

- (void)addTags:(NSSet*)value_;
- (void)removeTags:(NSSet*)value_;
- (void)addTagsObject:(KPTag*)value_;
- (void)removeTagsObject:(KPTag*)value_;

@end

@interface _KPToDo (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveAlarm;
- (void)setPrimitiveAlarm:(NSDate*)value;




- (NSDate*)primitiveCompletionDate;
- (void)setPrimitiveCompletionDate:(NSDate*)value;




- (NSString*)primitiveNotes;
- (void)setPrimitiveNotes:(NSString*)value;




- (NSNumber*)primitiveNumberOfRepeated;
- (void)setPrimitiveNumberOfRepeated:(NSNumber*)value;

- (int32_t)primitiveNumberOfRepeatedValue;
- (void)setPrimitiveNumberOfRepeatedValue:(int32_t)value_;




- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (int32_t)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(int32_t)value_;




- (NSNumber*)primitiveRepeatOption;
- (void)setPrimitiveRepeatOption:(NSNumber*)value;

- (int32_t)primitiveRepeatOptionValue;
- (void)setPrimitiveRepeatOptionValue:(int32_t)value_;




- (NSDate*)primitiveRepeatedDate;
- (void)setPrimitiveRepeatedDate:(NSDate*)value;




- (NSDate*)primitiveSchedule;
- (void)setPrimitiveSchedule:(NSDate*)value;




- (NSString*)primitiveState;
- (void)setPrimitiveState:(NSString*)value;




- (NSString*)primitiveTagString;
- (void)setPrimitiveTagString:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (NSMutableSet*)primitiveTags;
- (void)setPrimitiveTags:(NSMutableSet*)value;


@end
