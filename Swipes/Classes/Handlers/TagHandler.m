//
//  TagHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 27/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "TagHandler.h"
#import "ToDoHandler.h"
#import "AnalyticsHandler.h"
@implementation TagHandler
static TagHandler *sharedObject;
+(TagHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[TagHandler allocWithZone:NULL] init];
    }
    return sharedObject;
}
-(void)addTag:(NSString *)tag{
    KPTag *newTag = [KPTag newObjectInContext:nil];
    newTag.title = tag;
    [self save];
    [ANALYTICS incrementKey:NUMBER_OF_ADDED_TAGS_KEY withAmount:1];
}
-(void)updateTags:(NSArray *)tags remove:(BOOL)remove toDos:(NSArray *)toDos{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@",@"title",tags];
    NSSet *tagsSet = [NSSet setWithArray:[KPTag MR_findAllWithPredicate:predicate]];
    for(KPToDo *toDo in toDos){
        [toDo updateTagSet:tagsSet withTags:tags remove:remove];
    }
    [self save];
    if(remove) [ANALYTICS incrementKey:NUMBER_OF_RESIGNED_TAGS_KEY withAmount:toDos.count];
    else [ANALYTICS incrementKey:NUMBER_OF_ASSIGNED_TAGS_KEY withAmount:toDos.count];
}
-(void)save{
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
}
-(NSArray *)allTags{
    NSArray *tagObjs = [KPTag MR_findAll];
    NSMutableArray *tags = [NSMutableArray array];
    for(KPTag *tagObj in tagObjs){
        [tags addObject:tagObj.title];
    }
    return tags;
}
-(void)deleteTag:(NSString*)tag{
    NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@",@"title",@[tag]];
    KPTag *tagObj = [KPTag MR_findFirstWithPredicate:tagPredicate];
    NSPredicate *toDoPredicate = [NSPredicate predicateWithFormat:@"ANY tags = %@",tagObj];
    NSArray *toDos = [KPToDo MR_findAllWithPredicate:toDoPredicate];
    [self updateTags:@[tag] remove:YES toDos:toDos];
    [tagObj MR_deleteEntity];
    [self save];
}
-(NSArray *)selectedTagsForToDos:(NSArray *)toDos{
    NSMutableArray *commonTags = [NSMutableArray array];
    NSMutableArray *common2Tags = [NSMutableArray array];
    NSInteger counter = 0;
    for(KPToDo *toDo in toDos){
        if(counter > 1){
            commonTags = common2Tags;
            common2Tags = [NSMutableArray array];
        }
        for(KPTag *tag in toDo.tags){
            if(counter == 0) [commonTags addObject:tag.title];
            else{
                if([commonTags containsObject:tag.title]) [common2Tags addObject:tag.title];
            }
        }
        counter++;
    }
    if(counter > 1) commonTags = common2Tags;
    return commonTags;
}
@end
