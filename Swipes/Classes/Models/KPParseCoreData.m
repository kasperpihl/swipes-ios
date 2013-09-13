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
    [context performBlockAndWait:^{
        NSSet *updatedObjects = [context updatedObjects];
        //NSSet *deletedObjects = [context deletedObjects];
        NSLog(@"number of updates:%i",updatedObjects.count);
        for(KPParseObject *object in updatedObjects){
            if([object isKindOfClass:[KPParseObject class]] && object.objectId){
                NSLog(@"updates changes");
                [object updateChangedAttributes];
                NSLog(@"changes:%@",[NSKeyedUnarchiver unarchiveObjectWithData:object.changedAttributes]);
            }
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
-(void)synchronize{
    if(self.isSyncing){
        self.syncAgain = YES;
        return;
    }
    self.isSyncing = YES;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        NSLog(@"synchronizing");
        NSDate *syncStart = [[NSDate date] dateByAddingTimeInterval:-1];
        CGFloat startTime = CACurrentMediaTime();
        NSManagedObjectContext *context = [self context];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(!(changedAttributes == nil OR changedAttributes == NULL) AND objectId != nil) OR (objectId = nil)"];
        NSArray *changedObjects = [KPParseObject MR_findAllWithPredicate:predicate inContext:[self context]];
        NSMutableArray *updatePFObjects = [NSMutableArray array];
        NSMutableArray *updatedObjects = [NSMutableArray array];
        NSError *error;
        for(KPParseObject *object in changedObjects){
            PFObject *pfObj = [object objectToSave];
            if(!pfObj){
                NSLog(@"skipped object:%@",object);
                continue;
            }
            [updatePFObjects addObject:pfObj];
            [updatedObjects addObject:object];
            if(!object.changedAttributes) NSLog(@"no changed attributes, objectId: %@ object:%@",object.objectId,object);
        }
        if(updatePFObjects.count > 0){
            NSLog(@"saving %i objects",updatePFObjects.count);
            BOOL saved = [PFObject saveAll:updatePFObjects error:&error];
            if(error){
                NSLog(@"error saving updated:%@",error);
            }
            if(!saved) NSLog(@"didn't save");
            [context performBlockAndWait:^{
                NSInteger index = 0;
                for (KPParseObject *object in updatedObjects) {
                    PFObject *savedPFObject = [updatePFObjects objectAtIndex:index];
                    if([savedPFObject.createdAt isLaterThanDate:syncStart]){
                        [object updateWithObject:savedPFObject context:context];
                        NSLog(@"object was new");
                    }
                    else if([savedPFObject.updatedAt isLaterThanDate:syncStart]){
                        [object updateWithObject:savedPFObject context:context];
                        [object setChangedAttributes:nil];
                        NSLog(@"successfuly updating");
                    }
                    else{
                        NSLog(@"updated %@ lower %@ - %@",savedPFObject, savedPFObject.updatedAt,syncStart);
                    }
                    index++;
                    
                }
            }];
            [context MR_saveToPersistentStoreAndWait];
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
