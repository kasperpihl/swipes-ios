// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KPAttachment.m instead.

#import "_KPAttachment.h"

const struct KPAttachmentAttributes KPAttachmentAttributes = {
	.identifier = @"identifier",
	.service = @"service",
	.sync = @"sync",
	.title = @"title",
};

const struct KPAttachmentRelationships KPAttachmentRelationships = {
	.todo = @"todo",
};

@implementation KPAttachmentID
@end

@implementation _KPAttachment

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Attachment" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Attachment";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Attachment" inManagedObjectContext:moc_];
}

- (KPAttachmentID*)objectID {
	return (KPAttachmentID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"syncValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sync"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic identifier;

@dynamic service;

@dynamic sync;

- (BOOL)syncValue {
	NSNumber *result = [self sync];
	return [result boolValue];
}

- (void)setSyncValue:(BOOL)value_ {
	[self setSync:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveSyncValue {
	NSNumber *result = [self primitiveSync];
	return [result boolValue];
}

- (void)setPrimitiveSyncValue:(BOOL)value_ {
	[self setPrimitiveSync:[NSNumber numberWithBool:value_]];
}

@dynamic title;

@dynamic todo;

@end

