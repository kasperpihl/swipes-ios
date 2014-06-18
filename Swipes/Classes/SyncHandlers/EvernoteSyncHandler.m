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
#import "EvernoteToDoProcessor.h"
#import "NSDate-Utilities.h"
#import "NSString+Levenshtein.h"

#import "CoreSyncHandler.h"

#import "EvernoteSyncHandler.h"

#define kEvernoteUpdatedAtKey @"EvernoteUpdatedAt"


@interface EvernoteSyncHandler ()
@property (nonatomic,copy) SyncBlock block;
@property NSArray *objectsWithEvernote;
@property NSDate *lastUpdated;
@end
@implementation EvernoteSyncHandler

-(NSArray*)getObjectsSyncedWithEvernote{
    
    NSManagedObjectContext *contextForThread = [NSManagedObjectContext MR_contextForCurrentThread];
    
    NSPredicate *predicateForTodosWithEvernote = [NSPredicate predicateWithFormat:@"ANY attachments.service like %@ AND ANY attachments.sync == 1",EVERNOTE_SERVICE];
    NSArray *todosWithEvernote = [KPToDo MR_findAllWithPredicate:predicateForTodosWithEvernote inContext:contextForThread];
    
    return todosWithEvernote;

}
-(id)init{
    self = [super init];
    if( self ){
        self.lastUpdated = [[NSUserDefaults standardUserDefaults] objectForKey:kEvernoteUpdatedAtKey];
    }
    return self;
}

// Just testing
-(void)didDelay{
    self.block(SyncStatusSuccess, @{@"userInfoStuff": @"blabla"}, nil);
}

-(NSArray*)filterSubtasks:(NSSet*)subtasks{
    NSPredicate *subtaskPredicate = [NSPredicate predicateWithFormat:@"origin == %@",EVERNOTE_SERVICE];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO];
    NSArray *evernoteSubtasks = [[subtasks filteredSetUsingPredicate:subtaskPredicate] sortedArrayUsingDescriptors:@[ sortDescriptor ]];
    return evernoteSubtasks;
}

-(BOOL)handleEvernoteToDo:(EvernoteToDo*)evernoteToDo withMatchingSubtask:(KPToDo*)subtask inNoteProcessor:(EvernoteToDoProcessor*)processor{
    BOOL updated = NO;
#warning handle newly added todos specially?
    // If subtask is deleted from Swipes - mark completed in Evernote
    if ( [subtask.deleted boolValue] && !evernoteToDo.checked ){
        NSLog(@"completing evernote - subtask was deleted");
        [processor updateToDo:evernoteToDo checked:YES];
        updated = YES;
    }
    
    BOOL subtaskIsCompleted = ( subtask.completionDate ? YES : NO);
    
    // difference in completion
    if ( subtaskIsCompleted != evernoteToDo.checked ){
        
        
        // If subtask is completed in Swipes and not in Evernote
        if( subtaskIsCompleted){
            // If subtask was completed in Swipes after last sync override evernote
            if([self.lastUpdated isEarlierThanDate:subtask.completionDate]){
                NSLog(@"completing evernote");
                [processor updateToDo:evernoteToDo checked:subtaskIsCompleted];
            }
            // If not, uncomplete in Swipes
            else{
                NSLog(@"uncompleting subtask");
                [KPToDo scheduleToDos:@[subtask] forDate:nil save:NO];
            }
        }
        // If task is completed in Evernote, but not in Swipes
        else{
            // If subtask is updated later than last sync override Evernote
            // There could be an error margin here, but I don't see a better solution at the moment
            if ( [self.lastUpdated isEarlierThanDate:subtask.updatedAt] ){
                NSLog(@"uncompleting evernote");
                [processor updateToDo:evernoteToDo checked:subtaskIsCompleted];
            }
            // If not, override in Swipes
            else{
                NSLog(@"completing subtask");
                [KPToDo completeToDos:@[ subtask ] save:NO];
            }
        }
    }
    return updated;
}


-(KPToDo*)findAndHandleMatchesForToDo:(KPToDo*)parentToDo withEvernoteToDos:(NSArray *)evernoteToDos inNoteProcessor:(EvernoteToDoProcessor*)processor{
    // search for our TODO (comparing only title)
    NSArray *subtasks = [self filterSubtasks:parentToDo.subtasks];
    
    // Creating helper arrays for determining
    NSMutableArray *subtasksLeftToBeFound = [subtasks mutableCopy];
    NSMutableArray *evernoteToDosLeftToBeFound = [evernoteToDos mutableCopy];
    
    
    /* Match and clean all direct matches */
    for ( EvernoteToDo *evernoteToDo in evernoteToDos ){
        
        KPToDo* matchingSubtask = nil;
        
        for ( KPToDo* subtask in subtasks ) {
            if ( [subtask.originIdentifier isEqualToString: evernoteToDo.title] ) {
                matchingSubtask = subtask;
                [subtasksLeftToBeFound removeObject:subtask];
                [evernoteToDosLeftToBeFound removeObject:evernoteToDo];
                
                [self handleEvernoteToDo:evernoteToDo withMatchingSubtask:subtask inNoteProcessor:processor];
                break;
            }
        }
        
    }
    
    subtasks = [subtasksLeftToBeFound copy];
    evernoteToDos = [evernoteToDosLeftToBeFound copy];
    
    /* Match and clean all indirect matches */
    
    for ( EvernoteToDo *evernoteToDo in evernoteToDos ){
        
        KPToDo* matchingSubtask = nil;
        
        CGFloat bestScore = 0;
        KPToDo* bestMatch = nil;
        for ( KPToDo *subtask in subtasks ){
            CGFloat match = fabsf([subtask.originIdentifier compareWithWord:evernoteToDo.title matchGain:10 missingCost:1]);
            if (match > bestScore) {
                bestScore = match;
                bestMatch = subtask;
            }
        }
        NSLog(@"bestScore:%f",bestScore);
        NSLog(@"best Levenshtein score: %f (%@ to %@)", bestScore, evernoteToDo.title, bestMatch.originIdentifier);
        if( bestScore >= 120 ){
            matchingSubtask = bestMatch;
        }
        
        if ( !matchingSubtask ){
            NSLog(@"creating subtask from Evernote");
            matchingSubtask = [parentToDo addSubtask:evernoteToDo.title save:NO];
            matchingSubtask.origin = EVERNOTE_SERVICE;
            matchingSubtask.originIdentifier = evernoteToDo.title;
        }
        
        [subtasksLeftToBeFound removeObject:matchingSubtask];
        [evernoteToDosLeftToBeFound removeObject:evernoteToDo];
        
        [self handleEvernoteToDo:evernoteToDo withMatchingSubtask:matchingSubtask inNoteProcessor:processor];
        
    }
    
    subtasks = [subtasksLeftToBeFound copy];
    if ( subtasks && subtasks.count > 0 )
        [KPToDo deleteToDos:subtasks save:NO];

    
    return nil;
}

-(void)setUpdatedAt:(NSDate*)updatedAt{
    [[NSUserDefaults standardUserDefaults] setObject:updatedAt forKey:kEvernoteUpdatedAtKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.lastUpdated = updatedAt;
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
    
    NSDate *date = [NSDate date];
    __block NSInteger returnCount = 0;
    __block NSInteger targetCount = self.objectsWithEvernote.count;
    for ( KPToDo *todoWithEvernote in self.objectsWithEvernote ){
        
        KPAttachment *evernoteAttachment = [todoWithEvernote firstAttachmentForServiceType:EVERNOTE_SERVICE];
        NSString *guid = evernoteAttachment.identifier;
        
        [EvernoteToDoProcessor processorWithGuid:guid block:^(EvernoteToDoProcessor *processor, NSError *error) {
            
            NSLog(@"guid:%@",guid);
            if( processor ){
                
                returnCount++;
                NSLog(@"processing:%@",processor.toDoItems);
                NSArray *evernoteToDos = [[processor.toDoItems reverseObjectEnumerator] allObjects];
                [self findAndHandleMatchesForToDo:todoWithEvernote withEvernoteToDos:evernoteToDos inNoteProcessor:processor];
                
            }
            else{
                returnCount++;
            }
            if(returnCount == targetCount){
                NSLog(@"hit the target");
                
                if([[KPCORE context] hasChanges])
                    [KPToDo saveToSync];
                [self setUpdatedAt:date];
                self.block(SyncStatusSuccess, @{@"userInfoStuff": @"blabla"}, nil);
            }
            
        }];
        
    }
    
}
@end
