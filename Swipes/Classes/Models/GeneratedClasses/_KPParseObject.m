// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KPParseObject.m instead.

#import "_KPParseObject.h"

const struct KPParseObjectAttributes KPParseObjectAttributes = {
	.createdAt = @"createdAt",
	.isLocallyDeleted = @"isLocallyDeleted",
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

	if ([key isEqualToString:@"isLocallyDeletedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isLocallyDeleted"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic createdAt;

@dynamic isLocallyDeleted;

- (BOOL)isLocallyDeletedValue {
	NSNumber *result = [self isLocallyDeleted];
	return [result boolValue];
}

- (void)setIsLocallyDeletedValue:(BOOL)value_ {
	[self setIsLocallyDeleted:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsLocallyDeletedValue {
	NSNumber *result = [self primitiveIsLocallyDeleted];
	return [result boolValue];
}

- (void)setPrimitiveIsLocallyDeletedValue:(BOOL)value_ {
	[self setPrimitiveIsLocallyDeleted:[NSNumber numberWithBool:value_]];
}

@dynamic objectId;

@dynamic parseClassName;

@dynamic tempId;

@dynamic updatedAt;

@end

