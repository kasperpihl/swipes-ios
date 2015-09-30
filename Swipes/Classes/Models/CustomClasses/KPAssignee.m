
#import "CoreSyncHandler.h"
#import "AnalyticsHandler.h"
#import "KPAssignee.h"

@interface KPAssignee ()

// Private interface goes here.

@end

@implementation KPAssignee

+(KPAssignee *)addAssigneeWithUserId:(NSString *)userId save:(BOOL)save from:(NSString *)from inContext:(NSManagedObjectContext*)context
{
    userId = [userId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (userId.length == 0)
        return nil;
    
    KPAssignee *newAssignee = [KPAssignee findByUserId:userId inContext:context];
    if (newAssignee > 0)
        return newAssignee;
    
    newAssignee = [KPAssignee MR_createEntityInContext:context];
    newAssignee.userId = userId;
    if (save)
        [KPCORE saveContextForSynchronization:nil];
    if(from){
        [ANALYTICS trackEvent:@"Added Assignee" options:@{@"Length":@(userId.length),@"From":from}];
        [ANALYTICS trackCategory:@"Assignees" action:@"Added" label:from value:@(userId.length)];
    }
    return newAssignee;
}

+(KPAssignee *)findByUserId:(NSString *)userId inContext:(NSManagedObjectContext*)context
{
    if (userId) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@", userId];
        NSArray* result = [KPAssignee MR_findAllWithPredicate:predicate inContext:context];
        if (result && (0 == result.count))
            return nil;
        return result[0];
    }
    return nil;
}

-(BOOL)setAttributesForSavingObject:(NSMutableDictionary *__autoreleasing *)object changedAttributes:(NSArray *)changedAttributes
{
    NSDictionary *keyMatch = @{ @"userId": @"userId" };
    
    BOOL shouldUpdate = NO;
    for (NSString *cdKey in keyMatch) {
        NSString *pfKey = [keyMatch objectForKey:cdKey];
        if ([changedAttributes containsObject:cdKey]){
            if ([self valueForKey:cdKey])
                [*object setObject:[self valueForKey:cdKey] forKey:pfKey];
            else
                [*object setObject:[NSNull null] forKey:pfKey];
            shouldUpdate = YES;
        }
    }
    
    return shouldUpdate;
}

-(NSArray*)updateWithObjectFromServer:(NSDictionary *)object context:(NSManagedObjectContext *)context
{
    [context performBlockAndWait:^{
        if (![self.userId isEqualToString:[object objectForKey:@"userId"]])
            self.userId = [object objectForKey:@"userId"];
    }];
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"KPAssignee -> userId: %@", self.userId];
}

@end
