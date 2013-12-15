#import "KPTag.h"
#import "KPParseCoreData.h"
#import "AnalyticsHandler.h"
#import "KPToDo.h"
@interface KPTag ()

// Private interface goes here.

@end


@implementation KPTag
+(KPTag*)addTagWithString:(NSString *)string save:(BOOL)save{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(string.length == 0) return nil;
    NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"title = %@",string];
    NSInteger counter = [KPTag MR_countOfEntitiesWithPredicate:tagPredicate];
    if(counter > 0) return nil;
    KPTag *newTag = [KPTag newObjectInContext:nil];
    newTag.title = string;
    if(save)[KPCORE saveInContext:nil];
    return newTag;
}
+(void)deleteTagWithString:(NSString *)string save:(BOOL)save{
    NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@",@"title",@[string]];
    KPTag *tagObj = [KPTag MR_findFirstWithPredicate:tagPredicate];
    NSPredicate *toDoPredicate = [NSPredicate predicateWithFormat:@"ANY tags = %@",tagObj];
    NSArray *toDos = [KPToDo MR_findAllWithPredicate:toDoPredicate];
    [KPToDo updateTags:@[string] forToDos:toDos remove:YES save:YES];
    [tagObj MR_deleteEntity];
    if(save)[KPCORE saveInContext:nil];
}
+(NSArray *)allTagsAsStrings{
    NSArray *tagObjs = [KPTag MR_findAll];
    NSMutableArray *tags = [NSMutableArray array];
    for(KPTag *tagObj in tagObjs){
        if(tagObj.title && tagObj.title.length > 0)
            [tags addObject:tagObj.title];
    }
    return tags;
}
-(BOOL)setAttributesForSavingObject:(PFObject *__autoreleasing *)object changedAttributes:(NSArray *)changedAttributes{
    BOOL setAll = NO;
    NSDictionary *keyMatch = @{
                               @"title": @"title"
                               };
    if(!self.objectId) setAll = YES;
    BOOL shouldUpdate = NO;
    for(NSString *cdKey in keyMatch){
        NSString *pfKey = [keyMatch objectForKey:cdKey];
        if(setAll || [changedAttributes containsObject:cdKey]){
            if([self valueForKey:cdKey]) [*object setObject:[self valueForKey:cdKey] forKey:pfKey];
            else([*object setObject:[NSNull null] forKey:pfKey]);
            shouldUpdate = YES;
        }
    }
    return shouldUpdate;
}
-(void)updateWithObject:(PFObject *)object context:(NSManagedObjectContext *)context{
    [super updateWithObject:object context:context];
    [context performBlockAndWait:^{
        if(![self.title isEqualToString:[object objectForKey:@"title"]]) self.title = [object objectForKey:@"title"];
    }];
}
@end
