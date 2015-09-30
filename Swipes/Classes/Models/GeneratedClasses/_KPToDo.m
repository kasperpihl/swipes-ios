// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KPToDo.m instead.

#import "_KPToDo.h"

const struct KPToDoAttributes KPToDoAttributes = {
	.alarm = @"alarm",
	.completionDate = @"completionDate",
	.location = @"location",
	.notes = @"notes",
	.numberOfRepeated = @"numberOfRepeated",
	.order = @"order",
	.origin = @"origin",
	.originIdentifier = @"originIdentifier",
	.ownerId = @"ownerId",
	.priority = @"priority",
	.projectLocalId = @"projectLocalId",
	.projectOrder = @"projectOrder",
	.repeatOption = @"repeatOption",
	.repeatedDate = @"repeatedDate",
	.schedule = @"schedule",
	.state = @"state",
	.tagString = @"tagString",
	.title = @"title",
	.toUserId = @"toUserId",
	.userId = @"userId",
};

const struct KPToDoRelationships KPToDoRelationships = {
	.assignees = @"assignees",
	.attachments = @"attachments",
	.parent = @"parent",
	.subtasks = @"subtasks",
	.tags = @"tags",
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
	if ([key isEqualToString:@"priorityValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"priority"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"projectOrderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"projectOrder"];
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

@dynamic location;

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

@dynamic origin;

@dynamic originIdentifier;

@dynamic ownerId;

@dynamic priority;

- (int16_t)priorityValue {
	NSNumber *result = [self priority];
	return [result shortValue];
}

- (void)setPriorityValue:(int16_t)value_ {
	[self setPriority:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitivePriorityValue {
	NSNumber *result = [self primitivePriority];
	return [result shortValue];
}

- (void)setPrimitivePriorityValue:(int16_t)value_ {
	[self setPrimitivePriority:[NSNumber numberWithShort:value_]];
}

@dynamic projectLocalId;

@dynamic projectOrder;

- (int32_t)projectOrderValue {
	NSNumber *result = [self projectOrder];
	return [result intValue];
}

- (void)setProjectOrderValue:(int32_t)value_ {
	[self setProjectOrder:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveProjectOrderValue {
	NSNumber *result = [self primitiveProjectOrder];
	return [result intValue];
}

- (void)setPrimitiveProjectOrderValue:(int32_t)value_ {
	[self setPrimitiveProjectOrder:[NSNumber numberWithInt:value_]];
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

@dynamic toUserId;

@dynamic userId;

@dynamic assignees;

- (NSMutableSet*)assigneesSet {
	[self willAccessValueForKey:@"assignees"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"assignees"];

	[self didAccessValueForKey:@"assignees"];
	return result;
}

@dynamic attachments;

- (NSMutableSet*)attachmentsSet {
	[self willAccessValueForKey:@"attachments"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"attachments"];

	[self didAccessValueForKey:@"attachments"];
	return result;
}

@dynamic parent;

@dynamic subtasks;

- (NSMutableSet*)subtasksSet {
	[self willAccessValueForKey:@"subtasks"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"subtasks"];

	[self didAccessValueForKey:@"subtasks"];
	return result;
}

@dynamic tags;

- (NSMutableSet*)tagsSet {
	[self willAccessValueForKey:@"tags"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tags"];

	[self didAccessValueForKey:@"tags"];
	return result;
}

@end

