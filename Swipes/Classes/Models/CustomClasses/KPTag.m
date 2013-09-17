#import "KPTag.h"

@interface KPTag ()

// Private interface goes here.

@end


@implementation KPTag

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
