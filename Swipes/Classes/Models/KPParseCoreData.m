//
//  CoreDataClass.m
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPParseCoreData.h"
#import "UtilityClass.h"
#import "ToDoHandler.h"
#import "TagHandler.h"
#import "NSDate-Utilities.h"
#import <Parse/PFQuery.h>
#define kFetchLimit 0

/*

*/
@interface KPParseCoreData ()
@property (nonatomic,assign) BOOL isPerformingOperation;
@property (nonatomic,assign) BOOL didLogout;
@property (nonatomic) NSMutableDictionary *tmpUpdatingObjects;
@property (nonatomic) NSMutableArray *deletingObjects;
@property BOOL syncAgain;
@property BOOL isSyncing;
@property BOOL lockSaving;
@end
@implementation KPParseCoreData
-(NSManagedObjectContext *)context{
    return [NSManagedObjectContext MR_defaultContext];
}
-(void)saveInContext:(NSManagedObjectContext*)context{
    if(!context) context = [self context];
    [context performBlockAndWait:^{
        NSSet *insertedObjects = [context insertedObjects];
        NSSet *updatedObjects = [context updatedObjects];
        NSSet *deletedObjects = [context deletedObjects];
        for(KPParseObject *object in updatedObjects){
            if(!object.objectId) continue;
            NSArray *attributeArray = [self.tmpUpdatingObjects objectForKey:object.objectId];
            NSMutableSet *attributeSet = [NSMutableSet set];
            if(attributeArray) [attributeSet addObjectsFromArray:attributeArray];
            if(object.changedValues) [attributeSet addObjectsFromArray:[object.changedValues allKeys]];
            [self.tmpUpdatingObjects setObject:[attributeSet allObjects] forKey:object.objectId];
        }
    }];
    [context MR_saveToPersistentStoreAndWait];
    [self synchronize];
    return;
}
+(NSString *)classNameFromParseName:(NSString *)parseClassName{
    return [NSString stringWithFormat:@"KP%@",parseClassName];
}
#pragma mark Instantiation
static KPParseCoreData *sharedObject;
+(KPParseCoreData *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[KPParseCoreData allocWithZone:NULL] init];
        [sharedObject initialize];
    }
    return sharedObject;
}
#pragma mark Core data stuff
-(void)initialize{
    [self loadDatabase];
}   
-(void)loadDatabase{
    @try {
        [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"swipes"];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
}
-(void)updateTMPObjects{
    for(NSString *identifier in self.tmpUpdatingObjects){
        NSArray *attributeArray = [self.updateObjects objectForKey:identifier];
        NSArray *newAttributeArray = [self.tmpUpdatingObjects objectForKey:identifier];
        NSMutableSet *newAttributeSet = [NSMutableSet set];
        if(attributeArray) [newAttributeSet addObjectsFromArray:attributeArray];
        if(newAttributeArray) [newAttributeSet addObjectsFromArray:newAttributeArray];
        [self.updateObjects setObject:[newAttributeSet allObjects] forKey:identifier];
    }
    [self saveUpdatingObjects];
    self.tmpUpdatingObjects = nil;
}
-(NSMutableDictionary *)tmpUpdatingObjects{
    if(!_tmpUpdatingObjects) _tmpUpdatingObjects = [NSMutableDictionary dictionary];
    return _tmpUpdatingObjects;
}
-(void)saveUpdatingObjects{
    [[NSUserDefaults standardUserDefaults] setObject:self.updateObjects forKey:@"updateObjects"];
}
-(NSMutableDictionary*)updateObjects{
    if(!_updateObjects){
        _updateObjects = [[NSUserDefaults standardUserDefaults] objectForKey:@"updateObjects"];
        if(!_updateObjects) _updateObjects = [NSMutableDictionary dictionary];
    }
    return _updateObjects;
}
-(void)synchronize{
    if(self.isSyncing){
        self.syncAgain = YES;
        return;
    }
    self.isSyncing = YES;

    NSLog(@"synchronizing");
    NSDate *syncStart = [[NSDate date] dateByAddingTimeInterval:-1];
    CGFloat startTime = CACurrentMediaTime();
    [self updateTMPObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(objectId IN %@) OR (objectId = nil)",[self.updateObjects allKeys]];
    NSFetchRequest *request = [KPParseObject MR_requestAllWithPredicate:predicate inContext:[self context]];
    if(kFetchLimit) [request setFetchLimit:kFetchLimit];
    NSArray *changedObjects = [KPParseObject MR_executeFetchRequest:request inContext:[self context]];
    if(kFetchLimit && changedObjects.count == kFetchLimit) self.syncAgain = YES;
    __block NSMutableArray *updatePFObjects = [NSMutableArray array];
    __block NSMutableArray *updatedObjects = [NSMutableArray array];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        for(KPParseObject *oldContextObject in changedObjects){
            KPParseObject *object = [oldContextObject MR_inContext:localContext];
            PFObject *pfObj = [object objectToSaveInContext:localContext];
            if(!pfObj){
                NSLog(@"skipped object:%@",object.objectId);
                [self.updateObjects removeObjectForKey:object.objectId];
                continue;
            }
            [updatePFObjects addObject:pfObj];
            [updatedObjects addObject:object];
            //if(!object.changedAttributes)
        }
        if(updatePFObjects.count > 0){
            NSLog(@"saving %i objects",updatePFObjects.count);
            NSError *error;
            BOOL saved = [PFObject saveAll:updatePFObjects error:&error];
            if(error){
                NSLog(@"error saving updated:%@",error);
            }
            if(!saved) NSLog(@"didn't save");
            
            NSInteger index = 0;
            for (KPParseObject *object in updatedObjects) {
                PFObject *savedPFObject = [updatePFObjects objectAtIndex:index];
                if([savedPFObject.createdAt isLaterThanDate:syncStart]){
                    [object updateWithObject:savedPFObject context:localContext];
                    [self.updateObjects removeObjectForKey:object.objectId];
                }
                else if([savedPFObject.updatedAt isLaterThanDate:syncStart]){
                    [object updateWithObject:savedPFObject context:localContext];
                    NSLog(@"successfuly updating");
                    [self.updateObjects removeObjectForKey:object.objectId];
                }
                else{
                    NSLog(@"updated %@ lower %@ - %@",savedPFObject, savedPFObject.updatedAt,syncStart);
                }
                index++;
            }
            
        }
    } completion:^(BOOL success, NSError *localError) {
        if(localError) NSLog(@"error happened in the first save:%@",localError);
        [self saveUpdatingObjects];
        CGFloat endTime = CACurrentMediaTime();
        CGFloat takenTime = endTime - startTime;
        NSLog(@"sync completed in seconds: %f",takenTime);
        self.isSyncing = NO;
        if(self.syncAgain){
            self.syncAgain = NO;
            [self synchronize];
        }
        else{
            
        }
    }];
        /*PFQuery *taskQuery = [PFQuery queryWithClassName:@"ToDo"];
        [taskQuery setLimit:1000];
        PFQuery *tagQuery = [PFQuery queryWithClassName:@"Tag"];
        [tagQuery setLimit:1000];
*/
    
    
}
-(void)cleanUp{
    NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:@"swipes"];
    NSError *error;
    BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    if(removed){
        [MagicalRecord cleanUp];
        [self loadDatabase];
    }
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}
-(void)dealloc{
    [MagicalRecord cleanUp];
}

-(void)seedObjects{
    NSArray *tagArray = @[
                        @"home",
                        @"shopping",
                        @"work"
    ];
    for(NSString *tag in tagArray){
        [TAGHANDLER addTag:tag];
    }
    NSArray *toDoArray = @[
                           @"Tap to select me",
                           @"Swipe right to complete me",
                           @"Swipe left to schedule me",
                           @"Double-tap to edit me",
                           @"Hold to drag me up and down",
                           @"Pull down for search & filter",
                           @"Swipe the menu for settings"
                       ];
    for(NSInteger i = toDoArray.count-1 ; i >= 0  ; i--){
        NSString *item = [toDoArray objectAtIndex:i];
        KPToDo *toDo = [TODOHANDLER addItem:item];
        if(i == 4)[TAGHANDLER updateTags:@[@"home"] remove:NO toDos:@[toDo]];
        if(i == 5)[TAGHANDLER updateTags:@[@"work"] remove:NO toDos:@[toDo]];
    }
    
    NSArray *todosForTagsArray = [KPToDo MR_findAll];
    todosForTagsArray = [todosForTagsArray subarrayWithRange:NSMakeRange(0, 3)];
    
    [UTILITY.userDefaults setBool:YES forKey:@"seeded"];
}
@end
