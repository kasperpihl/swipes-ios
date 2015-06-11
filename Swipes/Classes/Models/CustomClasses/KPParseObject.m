
#import "KPParseObject.h"
#import "CoreSyncHandler.h"
#import "UtilityClass.h"
#import "KPToDo.h"

@interface KPParseObject ()

@property NSMutableDictionary *savingObject;

@end


@implementation KPParseObject

@synthesize savingObject = _savingObject;

#pragma mark - Forward declarations

-(BOOL)setAttributesForSavingObject:(NSMutableDictionary**)object changedAttributes:(NSArray *)changedAttributes{ return NO; }
-(BOOL)shouldDeleteForce:(BOOL)force{ return YES; }

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
-(void)moveObjectIdToTemp{
    if ( self.objectId ){
        self.tempId = self.objectId;
        self.objectId = nil;
    }
}
#pragma mark - Handling of changes
-(NSArray*)updateWithObjectFromServer:(NSDictionary *)object context:(NSManagedObjectContext*)context{
    if(!context) context = [KPCORE context];
    [context performBlockAndWait:^{
        self.savingObject = nil;
        NSDateFormatter *dateFormatter = [Global isoDateFormatter];
        if(!self.objectId){
            self.objectId = [object objectForKey:@"objectId"];
            [KPCORE tempId:self.tempId gotObjectId:self.objectId];
            self.createdAt = [dateFormatter dateFromString:[object objectForKey:@"createdAt"]];
        }
        self.updatedAt = [dateFormatter dateFromString:[object objectForKey:@"updatedAt"]];
    }];
    return nil;
}
#pragma mark - Instantiate object
+(KPParseObject *)newObjectInContext:(NSManagedObjectContext*)context{
    if(!context) context = [KPCORE context];
    KPParseObject *coreDataObject;
    coreDataObject = [[self class] MR_createEntityInContext:context];
    [coreDataObject getTempId];
    return coreDataObject;
}
+(KPParseObject *)getCDObjectFromObject:(NSDictionary*)object context:(NSManagedObjectContext *)context{
    if(!context) context = [KPCORE context];
    __block KPParseObject *coreDataObject;
    coreDataObject = [self checkForObject:object context:context];
    if(!coreDataObject) coreDataObject = [[self class] MR_createEntityInContext:context];
    return coreDataObject;
}
+(KPParseObject*)checkForObject:(NSDictionary*)object context:(NSManagedObjectContext*)context{
    KPParseObject *coreDataObject;
    coreDataObject = [[self class] MR_findFirstByAttribute:@"objectId" withValue:[object objectForKey:@"objectId"] inContext:context];
    if(!coreDataObject && [object objectForKey:@"tempId"]) coreDataObject = [[self class] MR_findFirstByAttribute:@"tempId" withValue:[object objectForKey:@"tempId"] inContext:context];
    return coreDataObject;
}
+(BOOL)deleteObject:(NSDictionary *)object context:(NSManagedObjectContext *)context{
    if(!context) context = [KPCORE context];
    KPParseObject *coreDataObject = [self checkForObject:object context:context];
    BOOL successful = YES;
    if(coreDataObject){
        successful = [coreDataObject deleteInContext:context];
    }
    return successful;
}
-(BOOL)deleteInContext:(NSManagedObjectContext *)context{
    BOOL successful = YES;
    if ([self isKindOfClass:KPToDo.class]) {
        [(KPToDo *)self deleteToDoSave:NO force:NO];
    }
    else if([self shouldDeleteForce:NO]) {
        successful = [self MR_deleteEntityInContext:context];
    }
    return successful;
}
#pragma mark - Save to server
-(NSDictionary*)objectToSaveInContext:(NSManagedObjectContext *)context changedAttributes:(NSArray *)attributes{
    if(!context) context = [KPCORE context];
    
    __block BOOL shouldUpdate = NO;
    __block NSMutableDictionary *objectToSave = (self.savingObject) ? self.savingObject : [NSMutableDictionary dictionary];
    
    [context performBlockAndWait:^{
        if(self.objectId)
            [objectToSave setObject:self.objectId forKey:@"objectId"];
        else{
            [objectToSave setObject:[self getTempId] forKey:@"tempId"];
        }
        
        /*if(self.deleted){
            [objectToSave setObject:@(YES) forKey:@"deleted"];
            shouldUpdate = YES;
        }*/
        /*
         Loading changed attributes from the sync handler
         and calls the subclass (KPToDo/KPTag) to set them proberly on the object
        
        else{*/
        shouldUpdate = [self setAttributesForSavingObject:&objectToSave changedAttributes:attributes];
        //}
        
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
