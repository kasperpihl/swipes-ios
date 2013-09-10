// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KPToDo.m instead.

#import "_KPToDo.h"

const struct KPToDoAttributes KPToDoAttributes = {
	.alarm = @"alarm",
	.completionDate = @"completionDate",
	.notes = @"notes",
	.numberOfRepeated = @"numberOfRepeated",
	.order = @"order",
	.repeatOption = @"repeatOption",
	.repeatedDate = @"repeatedDate",
	.schedule = @"schedule",
	.state = @"state",
	.tagString = @"tagString",
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
	
	if ([key isEqualToString:@"numberOfRepeatedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"numberOfRepeated"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"orderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"order"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"repeatOptionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"repeatOption"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic alarm;






@dynamic completionDate;






@dynamic notes;






@dynamic numberOfRepeated;



- (int32_t)numberOfRepeatedValue {
	NSNumber *result = [self numberOfRepeated];
	return [result intValue];
}

- (void)setNumberOfRepeatedValue:(int32_t)value_ {
	[self setNumberOfRepeated:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveNumberOfRepeatedValue {
	NSNumber *result = [self primitiveNumberOfRepeated];
	return [result intValue];
}

- (void)setPrimitiveNumberOfRepeatedValue:(int32_t)value_ {
	[self setPrimitiveNumberOfRepeated:[NSNumber numberWithInt:value_]];
}





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





@dynamic repeatOption;



- (int32_t)repeatOptionValue {
	NSNumber *result = [self repeatOption];
	return [result intValue];
}

- (void)setRepeatOptionValue:(int32_t)value_ {
	[self setRepeatOption:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveRepeatOptionValue {
	NSNumber *result = [self primitiveRepeatOption];
	return [result intValue];
}

- (void)setPrimitiveRepeatOptionValue:(int32_t)value_ {
	[self setPrimitiveRepeatOption:[NSNumber numberWithInt:value_]];
}





@dynamic repeatedDate;






@dynamic schedule;






@dynamic state;






@dynamic tagString;






@dynamic title;






@dynamic tags;

	
- (NSMutableSet*)tagsSet {
	[self willAccessValueForKey:@"tags"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tags"];
  
	[self didAccessValueForKey:@"tags"];
	return result;
}
	






@end
