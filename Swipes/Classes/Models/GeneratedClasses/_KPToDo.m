// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KPToDo.m instead.

#import "_KPToDo.h"

const struct KPToDoAttributes KPToDoAttributes = {
	.completionDate = @"completionDate",
	.notes = @"notes",
	.order = @"order",
	.schedule = @"schedule",
	.state = @"state",
	.title = @"title",
};

const struct KPToDoRelationships KPToDoRelationships = {
	.tags = @"tags",
};

const struct KPToDoFetchedProperties KPToDoFetchedProperties = {
};

@implementation KPToDoID
@end

@implementation _KPToDo

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ToDo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ToDo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ToDo" inManagedObjectContext:moc_];
}

- (KPToDoID*)objectID {
	return (KPToDoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"orderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"order"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic completionDate;






@dynamic notes;






@dynamic order;



- (int32_t)orderValue {
	NSNumber *result = [self order];
	return [result intValue];
}

- (void)setOrderValue:(int32_t)value_ {
	[self setOrder:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveOrderValue {
	NSNumber *result = [self primitiveOrder];
	return [result intValue];
}

- (void)setPrimitiveOrderValue:(int32_t)value_ {
	[self setPrimitiveOrder:[NSNumber numberWithInt:value_]];
}





@dynamic schedule;






@dynamic state;






@dynamic title;






@dynamic tags;

	
- (NSMutableSet*)tagsSet {
	[self willAccessValueForKey:@"tags"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tags"];
  
	[self didAccessValueForKey:@"tags"];
	return result;
}
	






@end
