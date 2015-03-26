//
//  SWACoreDataModel.m
//  Swipes
//
//  Created by demosten on 12/27/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

@import CoreData;
#import "KPToDo.h"
#import "SWAUtility.h"
#import "SWACoreDataModel.h"

@interface SWACoreDataModel ()

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation SWACoreDataModel

static NSString* const SHARED_GROUP_NAME = @"group.it.pihl.swipes";
static NSString* const DATABASE_NAME = @"swipes";
static NSString* const DATABASE_MODEL_NAME = @"Datamodel";
static NSString* const DATABASE_FOLDER = @"database";

+ (instancetype)sharedInstance
{
    static SWACoreDataModel* sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - Core Data stack

+ (NSURL *)coreDataUrl
{
    static NSURL *storeURL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storeURL = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:SHARED_GROUP_NAME] URLByAppendingPathComponent:DATABASE_FOLDER];
        #ifdef DEBUG
        if (nil == storeURL) {
            NSLog(@"Error getting storeURL! Check out provisioning profiles!");
            abort();
        }
        #endif
        [[NSFileManager defaultManager] createDirectoryAtURL:storeURL withIntermediateDirectories:YES attributes:nil error:nil];
        storeURL = [storeURL URLByAppendingPathComponent:DATABASE_NAME];
    });
    return storeURL;
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:DATABASE_MODEL_NAME withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [SWACoreDataModel coreDataUrl];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        if (error) {
            [SWAUtility sendErrorToHost:error];
        }
        #ifdef DEBUG
        abort();
        #endif
    }
    
    return _persistentStoreCoordinator;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            if (error) {
                [SWAUtility sendErrorToHost:error];
            }
            #ifdef DEBUG
            //abort();
            #endif
        }
    }
}

- (NSArray *)loadTodosWithError:(NSError **)error oneResult:(BOOL)oneResult
{
    _managedObjectContext = nil; // force refresh!
    //_persistentStoreCoordinator = nil; // force refresh!
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ToDo" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSDate *endDate = [NSDate date];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(schedule < %@ AND completionDate = nil AND parent = nil AND isLocallyDeleted <> YES)",endDate];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    if (oneResult)
        [request setFetchLimit:1];

    return [self.managedObjectContext executeFetchRequest:request error:error];
}

- (KPToDo *)loadTodoWithTempId:(NSString *)tempId error:(NSError **)error
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ToDo" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(tempId = %@ AND completionDate = nil AND parent = nil AND isLocallyDeleted <> YES)", tempId];
    [request setPredicate:predicate];
    [request setFetchLimit:1];
    
    NSArray* results = [self.managedObjectContext executeFetchRequest:request error:error];
    if (results && 1 <= results.count) {
        return results[0];
    }
    return nil;
}

- (NSArray *)loadTodoWithTempIds:(NSArray *)tempIds error:(NSError **)error
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ToDo" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@", @"tempId", tempIds];
    [request setPredicate:predicate];
    
    return [self.managedObjectContext executeFetchRequest:request error:error];
}

- (KPToDo *)loadScheduledTodoWithError:(NSError **)error
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ToDo" inManagedObjectContext:self.managedObjectContext];
    
    // check specified
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSDate *startDate = [NSDate date];
    NSPredicate *schedulePredicate = [NSPredicate predicateWithFormat:@"(schedule > %@ AND completionDate = nil AND parent = nil AND isLocallyDeleted <> YES)", startDate];
    
    [request setPredicate:schedulePredicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"schedule" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setFetchLimit:1];
    
    NSArray* results = [self.managedObjectContext executeFetchRequest:request error:error];
    if (results && 1 <= results.count) {
        return results[0];
    }
    
    // check unspecified
    request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *unspecifiedPredicate = [NSPredicate predicateWithFormat:@"(schedule = nil AND completionDate = nil) AND parent = nil AND isLocallyDeleted <> YES"];
    
    [request setPredicate:unspecifiedPredicate];
    [request setFetchLimit:1];
    
    results = [self.managedObjectContext executeFetchRequest:request error:error];
    if (results && 1 <= results.count) {
        return results[0];
    }
    
    return nil;
}

- (void)deleteObject:(id)object
{
    [self.managedObjectContext deleteObject:object];
}

- (KPToDo *)newToDo
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"ToDo" inManagedObjectContext:self.managedObjectContext];
}

@end
