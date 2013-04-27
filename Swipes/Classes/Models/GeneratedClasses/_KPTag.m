// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KPTag.m instead.

#import "_KPTag.h"

const struct KPTagAttributes KPTagAttributes = {
	.title = @"title",
};

const struct KPTagRelationships KPTagRelationships = {
	.todos = @"todos",
};

const struct KPTagFetchedProperties KPTagFetchedProperties = {
};

@implementation KPTagID
@end

@implementation _KPTag

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Tag";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:moc_];
}

- (KPTagID*)objectID {
	return (KPTagID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic title;






@dynamic todos;

	
- (NSMutableSet*)todosSet {
	[self willAccessValueForKey:@"todos"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"todos"];
  
	[self didAccessValueForKey:@"todos"];
	return result;
}
	






@end
