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
#import <Parse/PFRelation.h>
#import "Reachability.h"

#define kFetchLimit 0

/*

*/
@interface KPParseCoreData ()
@property (nonatomic,assign) BOOL isPerformingOperation;
@property (nonatomic,assign) BOOL didLogout;
@property (nonatomic) Reachability *reach;
@property (nonatomic) NSMutableDictionary *tmpUpdatingObjects;
@property (nonatomic) NSMutableDictionary *deleteObjects;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property BOOL needSync;
@property BOOL syncAgain;
@property BOOL isSyncing;
@property BOOL lockSaving;
@end
@implementation KPParseCoreData
-(NSManagedObjectContext *)context{
    return [NSManagedObjectContext MR_defaultContext];
}
-(NSMutableDictionary *)deleteObjects{
    if(!_deleteObjects){
        _deleteObjects = [[NSUserDefaults standardUserDefaults] objectForKey:@"deleteObjects"];
        if(!_deleteObjects) _deleteObjects = [NSMutableDictionary dictionary];
    }
    return _deleteObjects;
}
-(void)deleteObject:(KPParseObject*)object{
    [self.deleteObjects setObject:object.parseClassName forKey:object.objectId];
}
-(void)saveInContext:(NSManagedObjectContext*)context{
    if(!context) context = [self context];
    [context performBlockAndWait:^{
        //NSSet *insertedObjects = [context insertedObjects];
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
        for(KPParseObject *object in deletedObjects){
            if(object.objectId) [self deleteObject:object];
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
-(void)parseTest{
    return;
    PFQuery *query = [PFQuery queryWithClassName:@"ToDo"];
    [query whereKey:@"updatedAt" greaterThan:[[NSDate date] dateBySubtractingMinutes:1]];
    NSArray *objects = [query findObjects];
    for (PFObject *object in objects) {
        NSLog(@"obj:%@",objects);
    }
    
    /*NSInteger testNumber = 1;
    
    PFObject *class = [PFObject objectWithClassName:@"TestClass"];
    [class setObject:[@"testing-" stringByAppendingFormat:@"%i",testNumber] forKey:@"title"];

    PFObject *target1 = [PFObject objectWithClassName:@"TestTarget"];
    
    [target1 setObject:[@"testing-1-" stringByAppendingFormat:@"%i",testNumber] forKey:@"title"];
    PFObject *target2 = [PFObject objectWithClassName:@"TestTarget"];
    [target2 setObject:[@"testing-2-" stringByAppendingFormat:@"%i",testNumber] forKey:@"title"];
    
    [class addUniqueObject:target1 forKey:@"targetArray"];
    [class addUniqueObject:target2 forKey:@"targetArray"];
    NSMutableArray *array = [NSMutableArray array];
    for(NSInteger i = 0 ; i < 1300 ; i++){
        PFObject *object = [PFObject objectWithClassName:@"TestTarget"];
        [object setObject:[@"Testing-" stringByAppendingFormat:@"%i",i] forKey:@"title"];
        [array addObject:object];
    }
    PFRelation *relation = [class relationforKey:@"targetsRelation"];
    [relation addObject:target1];
    [relation addObject:target2];
    NSError *error;
    [PFObject saveAll:array error:&error];
    if(error){
        NSLog(@"error:%@",error);
    }*/
}
#pragma mark Core data stuff
-(void)initialize{
    self.backgroundTask = UIBackgroundTaskInvalid;
    [self loadDatabase];
    sharedObject.reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    // Set the blocks
    sharedObject.reach.reachableBlock = ^(Reachability*reach)
    {
        if(sharedObject.needSync) [sharedObject synchronize];
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [sharedObject.reach startNotifier];
    [self parseTest];
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
    [[NSUserDefaults standardUserDefaults] setObject:self.deleteObjects forKey:@"deleteObjects"];
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
    
    /* Testing for network connection */
    if(self.needSync) self.needSync = NO;
    if(!self.reach.isReachable){
        self.needSync = YES;
        return;
    }
    
    self.isSyncing = YES;
    CGFloat startTime = CACurrentMediaTime();
    [self updateTMPObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(objectId IN %@) OR (objectId = nil)",[self.updateObjects allKeys]];
    NSFetchRequest *request = [KPParseObject MR_requestAllWithPredicate:predicate inContext:[self context]];
    if(kFetchLimit) [request setFetchLimit:kFetchLimit];
    NSArray *changedObjects = [KPParseObject MR_executeFetchRequest:request inContext:[self context]];
    if(kFetchLimit && changedObjects.count == kFetchLimit) self.syncAgain = YES;
    __block NSMutableArray *updatePFObjects = [NSMutableArray array];
    __block NSMutableArray *updatedObjects = [NSMutableArray array];
    [self startBackgroundHandler];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        for(KPParseObject *oldContextObject in changedObjects){
            KPParseObject *object = [oldContextObject MR_inContext:localContext];
            PFObject *pfObj = [object objectToSaveInContext:localContext];
            if(!pfObj){
                NSLog(@"skipped object:%@",object.objectId);
                if(object && object.objectId) [self.updateObjects removeObjectForKey:object.objectId];
                continue;
            }
            [updatePFObjects addObject:pfObj];
            [updatedObjects addObject:object];
        }
        for(NSString *objectIdKey in self.deleteObjects){
            NSString *className = [self.deleteObjects objectForKey:objectIdKey];
            PFObject *deleteObject = [KPParseObject objectForDeletionWithClassName:className objectId:objectIdKey];
            [updatePFObjects addObject:deleteObject];
        }
        if(updatePFObjects.count > 0){
            NSLog(@"saving %i objects",updatePFObjects.count);
            NSError *error;
            [PFObject saveAll:updatePFObjects error:&error];
            if(error){
                self.syncAgain = YES;
                NSLog(@"error saving updated:%@",error);
            }
            NSInteger index = 0;
            for (KPParseObject *object in updatedObjects) {
                PFObject *savedPFObject = [updatePFObjects objectAtIndex:index];
                if(savedPFObject.updatedAt){
                    [object updateWithObject:savedPFObject context:localContext];
                    [self.updateObjects removeObjectForKey:savedPFObject.objectId];
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
        if(self.syncAgain){
            self.isSyncing = NO;
            self.syncAgain = NO;
            [self synchronize];
        }
        else{
            [self update];
        }
    }];
        
}
-(void)update{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdate"];
        PFQuery *tagQuery = [PFQuery queryWithClassName:@"Tag"];
        [tagQuery whereKey:@"owner" equalTo:kCurrent];
        [tagQuery setLimit:1000];
        if(lastUpdate) [tagQuery whereKey:@"updatedAt" greaterThanOrEqualTo:lastUpdate];
        PFQuery *taskQuery = [PFQuery queryWithClassName:@"ToDo"];
        [taskQuery whereKey:@"owner" equalTo:kCurrent];
        [taskQuery setLimit:1000];
        if(lastUpdate) [taskQuery whereKey:@"updatedAt" greaterThanOrEqualTo:lastUpdate];
        NSLog(@"lastUpdate:%@",lastUpdate);
        NSError *error;
        NSArray *tags = [tagQuery findObjects:&error];
        NSArray *tasks = [taskQuery findObjects:&error];
        NSArray *allObjects = [tags arrayByAddingObjectsFromArray:tasks];
        if(error){
            NSLog(@"error query:%@",error);
            [self endBackgroundHandler];
            return;
        }
        for(PFObject *object in allObjects){
            if(!lastUpdate) lastUpdate = object.updatedAt;
            else if([object.updatedAt isLaterThanDate:lastUpdate]) lastUpdate = object.updatedAt;
            Class class = NSClassFromString([KPParseCoreData classNameFromParseName:object.parseClassName]);
            if(class && [class isSubclassOfClass:[KPParseObject class]]){
                BOOL shouldDelete = [[object objectForKey:@"deleted"] boolValue];
                if(shouldDelete){
                    [class deleteObjectById:object.objectId context:localContext];
                    if([self.deleteObjects objectForKey:object.objectId])[self.deleteObjects removeObjectForKey:object.objectId];
                }else{
                    KPParseObject *cdObject = [class getCDObjectFromObject:object context:localContext];
                    [cdObject updateWithObject:object context:localContext];
                }
            }
        }
        if(lastUpdate) [[NSUserDefaults standardUserDefaults] setObject:lastUpdate forKey:@"lastUpdate"];
    } completion:^(BOOL success, NSError *error) {
        if(error) NSLog(@"error from update");
        self.isSyncing = NO;
        [self endBackgroundHandler];
        if(self.syncAgain) {
            [self synchronize];
        }
        
    }];
    
    
}
-(void)endBackgroundHandler{
    
    if (self.backgroundTask != UIBackgroundTaskInvalid)
    {
        NSLog(@"Background time remaining = %f seconds", [UIApplication sharedApplication].backgroundTimeRemaining);
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}
-(void)startBackgroundHandler{
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"Background handler called. Not running background tasks anymore.");
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }];
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
    [self endBackgroundHandler];
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
        [TAGHANDLER addTag:tag save:NO];
    }
    [self saveInContext:nil];
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
        KPToDo *toDo = [TODOHANDLER addItem:item save:NO];
        if(i == 4)[TAGHANDLER updateTags:@[@"home"] remove:NO toDos:@[toDo] save:YES];
        if(i == 5)[TAGHANDLER updateTags:@[@"work"] remove:NO toDos:@[toDo] save:YES];
    }
    [self saveInContext:nil];
    NSArray *todosForTagsArray = [KPToDo MR_findAll];
    todosForTagsArray = [todosForTagsArray subarrayWithRange:NSMakeRange(0, 3)];
    
    [UTILITY.userDefaults setBool:YES forKey:@"seeded"];
}
@end
