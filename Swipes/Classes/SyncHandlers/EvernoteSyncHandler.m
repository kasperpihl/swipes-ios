//
//  EvernoteSyncHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 15/06/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "Underscore.h"

#import "KPToDo.h"
#import "KPAttachment.h"
#import "EvernoteSyncHandler.h"
@interface EvernoteSyncHandler ()
@property (nonatomic,copy) SyncBlock block;
@property NSArray *objectsWithEvernote;
@end
@implementation EvernoteSyncHandler

-(NSArray*)getObjectsSyncedWithEvernote{
    
    NSManagedObjectContext *contextForThread = [NSManagedObjectContext MR_contextForCurrentThread];
    
    NSPredicate *predicateForTodosWithEvernote = [NSPredicate predicateWithFormat:@"ANY attachments.service like %@ AND ANY attachments.sync == 1",EVERNOTE_SERVICE];
    NSArray *todosWithEvernote = [KPToDo MR_findAllWithPredicate:predicateForTodosWithEvernote inContext:contextForThread];
    
    return todosWithEvernote;

}

// Just testing
-(void)didDelay{
    self.block(SyncStatusSuccess, @{@"userInfoStuff": @"blabla"}, nil);
}

-(void)synchronizeWithBlock:(SyncBlock)block{
    self.block = block;
    self.objectsWithEvernote = [self getObjectsSyncedWithEvernote];
    
    // If no objects has attachments - send a success back to caller
    if (self.objectsWithEvernote.count == 0){
        return self.block(SyncStatusSuccess, nil, nil);
    }
    
    // Tell caller that Evernote will be syncing
    self.block(SyncStatusStarted, nil, nil);
    
    NSLog(@"performing magic");
    /* Perform the magic syncing here */
    
    for ( KPToDo *todoWithEvernote in self.objectsWithEvernote ){
        
        // Adding a subtask - use save NO for saving all in the end
        [todoWithEvernote addSubtask:@"subtask title" save:NO];
        
        // How to delete a subtask - use save NO for saving in end
        for ( KPToDo *subtask in todoWithEvernote.subtasks ){
            [KPToDo deleteToDos:@[subtask] save:NO];
        }
        
    }
    [KPToDo saveToSync];
    
    // Just testing the top notification
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(didDelay) userInfo:nil repeats:NO];
    
    
    
    // Call this upon successful evernote sync
    //self.block(SyncStatusSuccess, @{@"userInfoStuff": @"blabla"}, nil);

    // Call this upon error evernote sync
   // NSError *error;
   // self.block(SyncStatusError, nil, error);
    
}
@end
