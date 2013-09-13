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
/*

*/
@interface KPParseCoreData ()
@property (nonatomic,assign) BOOL isPerformingOperation;
@property (nonatomic,assign) BOOL didLogout;
@property BOOL syncAgain;
@property BOOL isSyncing;
@property BOOL lockSaving;
@end
@implementation KPParseCoreData
-(NSManagedObjectContext *)context{
    return [NSManagedObjectContext MR_defaultContext];
}
-(void)saveInContext:(NSManagedObjectContext*)context{
    if(!context) context = [NSManagedObjectContext MR_defaultContext];
    NSSet *updatedObjects = [context updatedObjects];
    //NSSet *deletedObjects = [context deletedObjects];
    for(KPParseObject *object in updatedObjects){
        if([object isKindOfClass:[KPParseObject class]] && object.objectId){
            [object updateChangedAttributes];
        }
    }
    if([context isEqual:[NSManagedObjectContext MR_defaultContext]]) [context MR_saveOnlySelfAndWait];
    else [context MR_saveToPersistentStoreAndWait];
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
-(void)synchronize{
    if(self.isSyncing){
        self.syncAgain = YES;
        return;
    }
    self.isSyncing = YES;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        NSLog(@"synchronizing");
        CGFloat startTime = CACurrentMediaTime();
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(changedAttributes != nil AND objectId != nil) OR (objectId = nil)"];
        NSArray *changedObjects = [KPParseObject MR_findAllWithPredicate:predicate inContext:context];
        NSMutableArray *updatedObjects = [NSMutableArray array];
        NSMutableArray *updatePFObjects = [NSMutableArray array];
        NSError *error;
        NSInteger counter = 0;
        for(KPParseObject *object in changedObjects){
            PFObject *pfObj = [object objectToSave];
            if(!pfObj.objectId){
                counter++;
                [pfObj save:&error];
                if(!error){
                    [object updateWithObject:pfObj context:context];
                }
                else{
                    NSLog(@"error saving new object:%@",error);
                    error = nil;
                    continue;
                }
            }
            else{
                [updatePFObjects addObject:pfObj];
                [updatedObjects addObject:object];
            }
            if(counter == 5){
                NSLog(@"send 5 new objects");
                [context MR_saveToPersistentStoreAndWait];
                counter = 0;
            }
        }
        if(counter > 0){
            NSLog(@"saved %i new objects",counter);
            [context MR_saveToPersistentStoreAndWait];
        }
        if(updatePFObjects.count > 0){
            NSLog(@"saving %i updated objects",updatePFObjects.count);
            [PFObject saveAll:updatePFObjects error:&error];
            if(error){
                NSLog(@"error saving updated:%@",error);
            }
            else{
                [context performBlockAndWait:^{
                    for (KPParseObject *object in updatedObjects) {
                        [object setChangedAttributes:nil];
                    }
                }];
                [context MR_saveToPersistentStoreAndWait];
            }
        }
        CGFloat endTime = CACurrentMediaTime();
        CGFloat takenTime = endTime - startTime;
        NSLog(@"sync completed in seconds: %f",takenTime);
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.isSyncing = NO;
            if(self.syncAgain){
                self.syncAgain = NO;
                [self synchronize];
            }
        });
    });
    dispatch_release(queue);
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
