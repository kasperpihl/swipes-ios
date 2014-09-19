// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KPParseObject.m instead.

#import "_KPParseObject.h"

const struct KPParseObjectAttributes KPParseObjectAttributes = {
	.createdAt = @"createdAt",
	.deleted = @"deleted",
	.objectId = @"objectId",
	.parseClassName = @"parseClassName",
	.tempId = @"tempId",
	.updatedAt = @"updatedAt",
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

	if ([key isEqualToString:@"deletedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"deleted"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic createdAt;

@dynamic deleted;

- (BOOL)deletedValue {
	NSNumber *result = [self deleted];
	return [result boolValue];
}

- (void)setDeletedValue:(BOOL)value_ {
	[self setDeleted:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDeletedValue {
	NSNumber *result = [self primitiveDeleted];
	return [result boolValue];
}

- (void)setPrimitiveDeletedValue:(BOOL)value_ {
	[self setPrimitiveDeleted:[NSNumber numberWithBool:value_]];
}

@dynamic objectId;

@dynamic parseClassName;

@dynamic tempId;

@dynamic updatedAt;

@end

