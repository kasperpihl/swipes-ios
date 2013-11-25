// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KPParseObject.m instead.

#import "_KPParseObject.h"

const struct KPParseObjectAttributes KPParseObjectAttributes = {
	.createdAt = @"createdAt",
	.objectId = @"objectId",
	.parseClassName = @"parseClassName",
	.tempId = @"tempId",
	.updatedAt = @"updatedAt",
};

const struct KPParseObjectRelationships KPParseObjectRelationships = {
};

const struct KPParseObjectFetchedProperties KPParseObjectFetchedProperties = {
};

@implementation KPParseObjectID
@end

@implementation _KPParseObject

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ParseObject" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ParseObject";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ParseObject" inManagedObjectContext:moc_];
}

- (KPParseObjectID*)objectID {
	return (KPParseObjectID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic createdAt;






@dynamic objectId;






@dynamic parseClassName;






@dynamic tempId;






@dynamic updatedAt;











@end
