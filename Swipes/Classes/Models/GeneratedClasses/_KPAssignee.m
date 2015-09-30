// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KPAssignee.m instead.

#import "_KPAssignee.h"

const struct KPAssigneeAttributes KPAssigneeAttributes = {
	.userId = @"userId",
};

const struct KPAssigneeRelationships KPAssigneeRelationships = {
	.todos = @"todos",
};

@implementation KPAssigneeID
@end

@implementation _KPAssignee

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Assignee" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Assignee";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Assignee" inManagedObjectContext:moc_];
}

- (KPAssigneeID*)objectID {
	return (KPAssigneeID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic userId;

@dynamic todos;

- (NSMutableSet*)todosSet {
	[self willAccessValueForKey:@"todos"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"todos"];

	[self didAccessValueForKey:@"todos"];
	return result;
}

@end

