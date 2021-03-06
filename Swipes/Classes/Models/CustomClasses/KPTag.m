
#import "CoreSyncHandler.h"
#import "AnalyticsHandler.h"
#import "KPToDo.h"
#import "CoreSyncHandler.h"
#import "KPTag.h"

@interface KPTag ()

// Private interface goes here.

@end


@implementation KPTag

+(KPTag*)addTagWithString:(NSString *)string save:(BOOL)save from:(NSString *)from
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (string.length == 0)
        return nil;
    NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"title = %@",string];
    NSInteger counter = [KPTag MR_countOfEntitiesWithPredicate:tagPredicate];
    if (counter > 0)
        return nil;
    KPTag *newTag = [KPTag newObjectInContext:nil];
    newTag.title = string;
    if (save)
        [KPCORE saveContextForSynchronization:nil];
    if(from){
        [ANALYTICS trackEvent:@"Added Tag" options:@{@"Length":@(string.length),@"From":from}];
        [ANALYTICS trackCategory:@"Tags" action:@"Added" label:from value:@(string.length)];
    }
    return newTag;
}

+(void)deleteTagWithString:(NSString *)string save:(BOOL)save from:(NSString *)from
{
    NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@",@"title",@[string]];
    KPTag *tagObj = [KPTag MR_findFirstWithPredicate:tagPredicate];
    NSPredicate *toDoPredicate = [NSPredicate predicateWithFormat:@"ANY tags = %@",tagObj];
    NSArray *toDos = [KPToDo MR_findAllWithPredicate:toDoPredicate];
    [KPToDo updateTags:@[string] forToDos:toDos remove:YES save:YES from:@"Delete Tag"];
    [tagObj MR_deleteEntity];
    if (save)
        [KPCORE saveContextForSynchronization:nil];
    if(from){
        [ANALYTICS trackEvent:@"Deleted Tag" options:@{@"From":from}];
        [ANALYTICS trackCategory:@"Tags" action:@"Deleted" label:from value:nil];
    }
}

+(NSArray *)allTagsAsStrings
{
    NSArray *tagObjs = [KPTag MR_findAll];
    NSMutableArray *tags = [NSMutableArray array];
    for (KPTag *tagObj in tagObjs){
        if (tagObj.title && tagObj.title.length > 0)
            [tags addObject:tagObj.title];
    }
    return tags;
}

+(NSArray *)findByTitle:(NSString *)title
{
    if (title) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@", title];
        NSArray* result = [KPTag MR_findAllWithPredicate:predicate];
        if (result && (0 == result.count))
            return nil;
        return result;
    }
    return nil;
}

-(void)moveObjectIdToTemp{
    if ( self.objectId ){
        self.tempId = self.objectId;
        self.objectId = nil;
    }
}

-(BOOL)setAttributesForSavingObject:(NSMutableDictionary *__autoreleasing *)object changedAttributes:(NSArray *)changedAttributes
{
    BOOL isNewObject = ( !self.objectId );
    if (changedAttributes && [changedAttributes containsObject:@"all"])
        isNewObject = YES;
    
    NSDictionary *keyMatch = @{ @"title": @"title" };
    
    BOOL shouldUpdate = NO;
    for (NSString *cdKey in keyMatch) {
        NSString *pfKey = [keyMatch objectForKey:cdKey];
        if (isNewObject || [changedAttributes containsObject:cdKey]){
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
    [super updateWithObjectFromServer:object context:context];
    [context performBlockAndWait:^{
        if (![self.title isEqualToString:[object objectForKey:@"title"]])
            self.title = [object objectForKey:@"title"];
    }];
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"KPTag -> title: %@", self.title];
}

@end
