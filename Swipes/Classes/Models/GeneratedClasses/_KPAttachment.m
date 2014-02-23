// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KPAttachment.m instead.

#import "_KPAttachment.h"

const struct KPAttachmentAttributes KPAttachmentAttributes = {
	.identifier = @"identifier",
	.service = @"service",
	.title = @"title",
};

const struct KPAttachmentRelationships KPAttachmentRelationships = {
	.todo = @"todo",
};

const struct KPAttachmentFetchedProperties KPAttachmentFetchedProperties = {
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
	

	return keyPaths;
}




@dynamic identifier;






@dynamic service;






@dynamic title;






@dynamic todo;

	






@end
