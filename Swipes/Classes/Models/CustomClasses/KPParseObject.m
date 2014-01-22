#import "KPParseObject.h"
#import "KPParseCoreData.h"
#import "UtilityClass.h"
@interface KPParseObject ()
@property NSMutableDictionary *savingObject;
@end



@implementation KPParseObject
@synthesize savingObject = _savingObject;
#pragma mark - Forward declarations
-(BOOL)setAttributesForSavingObject:(NSMutableDictionary**)object changedAttributes:(NSArray *)changedAttributes{ return NO; }
-(NSString *)getParseClassName{
    NSString *className = NSStringFromClass ([self class]);
    NSString *parseClassName = [className substringFromIndex:2];
    return parseClassName;
}
-(NSString *)getTempId{
    if(!self.tempId){
        self.tempId = [UtilityClass generateIdWithLength:14];
    }
    return self.tempId;
}
#pragma mark - Handling of changes
-(void)updateWithObject:(PFObject *)object context:(NSManagedObjectContext*)context{
    if(!context) context = [KPCORE context];
    [context performBlockAndWait:^{
        self.savingObject = nil;
        if(!self.objectId){
            self.objectId = object.objectId;
            self.createdAt = object.createdAt;
            self.parseClassName = object.parseClassName;
        }
        self.updatedAt = object.updatedAt;
    }];
}
#pragma mark - Instantiate object
+(KPParseObject *)newObjectInContext:(NSManagedObjectContext*)context{
    if(!context) context = [KPCORE context];
    KPParseObject *coreDataObject;
    coreDataObject = [[self class] MR_createInContext:context];
    [coreDataObject getTempId];
    return coreDataObject;
}
+(KPParseObject *)getCDObjectFromObject:(PFObject*)object context:(NSManagedObjectContext *)context{
    if(!context) context = [KPCORE context];
    __block KPParseObject *coreDataObject;
    coreDataObject = [self checkForObject:object context:context];
    if(!coreDataObject) coreDataObject = [[self class] MR_createInContext:context];
    return coreDataObject;
}
+(KPParseObject*)checkForObject:(PFObject*)object context:(NSManagedObjectContext*)context{
    KPParseObject *coreDataObject;
    coreDataObject = [[self class] MR_findFirstByAttribute:@"objectId" withValue:object.objectId inContext:context];
    if(!coreDataObject && [object objectForKey:@"tempId"]) coreDataObject = [[self class] MR_findFirstByAttribute:@"tempId" withValue:[object objectForKey:@"tempId"] inContext:context];
    return coreDataObject;
}
+(BOOL)deleteObject:(PFObject *)object context:(NSManagedObjectContext *)context{
    if(!context) context = [KPCORE context];
    KPParseObject *coreDataObject = [self checkForObject:object context:context];
    BOOL successful = YES;
    if(coreDataObject) successful = [coreDataObject MR_deleteInContext:context];
    return successful;
}
#pragma mark - Save to server
-(NSDictionary*)objectToSaveInContext:(NSManagedObjectContext *)context{
    if(!context) context = [KPCORE context];
    
    __block BOOL shouldUpdate = NO;
    __block NSMutableDictionary *objectToSave = (self.savingObject) ? self.savingObject : [NSMutableDictionary dictionary];
    
    [context performBlockAndWait:^{
        if(self.objectId)
            [objectToSave setObject:self.objectId forKey:@"objectId"];
        else{
            [objectToSave setObject:[self getTempId] forKey:@"tempId"];
        }
        
        /*
         Loading changed attributes from the sync handler
         and calls the subclass (KPToDo/KPTag) to set them proberly on the object
        */
        NSMutableSet *changeSet = [KPCORE.updateObjects objectForKey:self.objectId];
        NSArray *changedAttributes = changeSet ? [changeSet allObjects] : nil;

        shouldUpdate = [self setAttributesForSavingObject:&objectToSave changedAttributes:changedAttributes];
    }];
    if(shouldUpdate) return objectToSave;
    else return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"KPParseObject -> createdAt: %@, objectId: %@, parseClassName: %@, tempId: %@, updatedAt: %@",
            self.createdAt, self.objectId, self.parseClassName, self.tempId, self.updatedAt];
}

@end
