// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KPToDo.m instead.

#import "_KPToDo.h"

const struct KPToDoAttributes KPToDoAttributes = {
	.title = @"title",
};

const struct KPToDoRelationships KPToDoRelationships = {
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
	

	return keyPaths;
}




@dynamic title;











@end
