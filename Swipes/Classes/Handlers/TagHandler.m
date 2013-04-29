//
//  TagHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 27/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "TagHandler.h"
#import "KPToDo.h"
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
}
-(void)addTags:(NSArray *)addedTags andRemoveTags:(NSArray *)removedTags fromToDos:(NSArray *)toDos{
    NSSet *addedTagsObjects;
    NSSet *removedTagsObjects;
    
    if(addedTags){
        NSPredicate *addedPredicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@",@"title",addedTags];
        addedTagsObjects = [NSSet setWithArray:[KPTag MR_findAllWithPredicate:addedPredicate]];
    }
    if(removedTags){
        NSPredicate *removedPredicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@",@"title",removedTags];
        removedTagsObjects = [NSSet setWithArray:[KPTag MR_findAllWithPredicate:removedPredicate]];
    }
    
    for(KPToDo *toDo in toDos){
        if(addedTagsObjects){
            [toDo addTags:addedTagsObjects];
        }
        if(removedTagsObjects){
            [toDo removeTags:removedTagsObjects];
        }
        [toDo updateTagsString];
    }
    [self save];
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
