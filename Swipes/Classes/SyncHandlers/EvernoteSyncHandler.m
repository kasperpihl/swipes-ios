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

#import "NSDate+EDAMAdditions.h"
#import "CoreSyncHandler.h"
#import "UtilityClass.h"

#import "EvernoteIntegration.h"

#import "EvernoteSyncHandler.h"

NSString * const kEvernoteUpdatedAtKey = @"EvernoteUpdatedAt";

@interface EvernoteSyncHandler ()
@property (nonatomic,copy) SyncBlock block;
@property NSArray *objectsWithEvernote;
@property NSDate *lastUpdated;
@property BOOL updateNeededFromEvernote;
@property NSInteger currentEvernoteUpdateCount;
@property NSInteger expectedEvernoteCount;
@property (nonatomic) NSMutableArray *_updatedTasks;
@end
@implementation EvernoteSyncHandler

-(NSMutableArray *)_updatedTasks{
    if( !__updatedTasks )
        __updatedTasks = [NSMutableArray array];
    return __updatedTasks;
}

-(NSArray*)getObjectsSyncedWithEvernote{
    
    NSManagedObjectContext *contextForThread = [NSManagedObjectContext MR_contextForCurrentThread];
    
    NSPredicate *predicateForTodosWithEvernote = [NSPredicate predicateWithFormat:@"ANY attachments.service like %@ AND ANY attachments.sync == 1",EVERNOTE_SERVICE];
    NSArray *todosWithEvernote = [KPToDo MR_findAllWithPredicate:predicateForTodosWithEvernote inContext:contextForThread];
    
    return todosWithEvernote;

}


-(void)updateEvernoteCount:(NSInteger)newUpdateCount{
    if( newUpdateCount > self.expectedEvernoteCount ){
        self.updateNeededFromEvernote = YES;
    }
    self.currentEvernoteUpdateCount = newUpdateCount;
    self.expectedEvernoteCount = newUpdateCount;
}


+(NSArray *)addAndSyncNewTasksFromNotes:(NSArray *)notes{
    for( EDAMNote *note in notes ){
        
        NSString *title;
        if (note.titleIsSet) {
            title = note.title;
        }
        else if (note.contentIsSet) {
            title = note.content;
        }
        else {
            title = @"Untitled note";
        }
        if(title.length > 256)
            title = [title substringToIndex:255];
        KPToDo *newToDo = [KPToDo addItem:title priority:NO tags:nil save:NO];
        [newToDo attachService:EVERNOTE_SERVICE title:title identifier:note.guid sync:YES];
    }
    if(notes.count > 0)
        [KPCORE saveContextForSynchronization:nil];
    return nil;
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

-(NSArray*)filterSubtasksWithEvernote:(NSSet*)subtasks{
    NSPredicate *subtaskPredicate = [NSPredicate predicateWithFormat:@"origin == %@",EVERNOTE_SERVICE];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO];
    return [[subtasks filteredSetUsingPredicate:subtaskPredicate] sortedArrayUsingDescriptors:@[ sortDescriptor ]];
}

-(NSArray*)filterSubtasksWithoutOrigin:(NSSet*)subtasks{
    NSPredicate *subtaskPredicate = [NSPredicate predicateWithFormat:@"origin = nil"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO];
    return [[subtasks filteredSetUsingPredicate:subtaskPredicate] sortedArrayUsingDescriptors:@[ sortDescriptor ]];
}

-(BOOL)handleEvernoteToDo:(EvernoteToDo*)evernoteToDo withMatchingSubtask:(KPToDo*)subtask inNoteProcessor:(EvernoteToDoProcessor*)processor isNew:(BOOL)isNew{
    BOOL updated = NO;
    // If subtask is deleted from Swipes - mark completed in Evernote
    if ( [subtask.deleted boolValue] && !evernoteToDo.checked ){
        NSLog(@"completing evernote - subtask was deleted");
        [processor updateToDo:evernoteToDo checked:YES];
        return NO;
    }
    
    BOOL subtaskIsCompleted = ( subtask.completionDate ? YES : NO);
    
    // difference in completion
    if ( subtaskIsCompleted != evernoteToDo.checked ){
        
        // If subtask is completed in Swipes and not in Evernote
        if( subtaskIsCompleted ){
            // If subtask was completed in Swipes after last sync override evernote
            if([self.lastUpdated isEarlierThanDate:subtask.completionDate]){
                DLog(@"completing evernote");
                [processor updateToDo:evernoteToDo checked:subtaskIsCompleted];
            }
            // If not, uncomplete in Swipes
            else{
                DLog(@"uncompleting subtask");
                [KPToDo scheduleToDos:@[subtask] forDate:nil save:NO];
                updated = YES;
            }
        }
        // If task is completed in Evernote, but not in Swipes
        else{
            // If subtask is updated later than last sync override Evernote
            // There could be an error margin here, but I don't see a better solution at the moment
            if ( !isNew && [self.lastUpdated isEarlierThanDate:subtask.updatedAt] ){
                DLog(@"uncompleting evernote");
                [processor updateToDo:evernoteToDo checked:subtaskIsCompleted];
            }
            // If not, override in Swipes
            else{
                DLog(@"completing subtask");
                [KPToDo completeToDos:@[ subtask ] save:NO];
                updated = YES;
            }
        }
    }
    
    // difference in name
    if (![subtask.title isEqualToString:subtask.originIdentifier]) {
        if ([processor updateToDo:evernoteToDo title:subtask.title]) {
            DLog(@"renamed evernote");
            subtask.originIdentifier = subtask.title;
            updated = YES;
        }
    }
    
    return updated;
}


-(KPToDo*)findAndHandleMatchesForToDo:(KPToDo*)parentToDo withEvernoteToDos:(NSArray *)evernoteToDos inNoteProcessor:(EvernoteToDoProcessor*)processor{
    // search for our TODO (comparing only title)
    NSArray *subtasks = [self filterSubtasksWithEvernote:parentToDo.subtasks];
    
    // Creating helper arrays for determining which ones has already been matched
    NSMutableArray *subtasksLeftToBeFound = [subtasks mutableCopy];
    NSMutableArray *evernoteToDosLeftToBeFound = [evernoteToDos mutableCopy];
    
    BOOL updated = NO;
    /* Match and clean all direct matches */
    for ( EvernoteToDo *evernoteToDo in evernoteToDos ){
        
        KPToDo* matchingSubtask = nil;
        
        for ( KPToDo* subtask in subtasks ) {
            if ( [subtask.originIdentifier isEqualToString: evernoteToDo.title] ) {
                
                matchingSubtask = subtask;
                [subtasksLeftToBeFound removeObject:subtask];
                subtasks = [subtasksLeftToBeFound copy];
                [evernoteToDosLeftToBeFound removeObject:evernoteToDo];
                
                if( [self handleEvernoteToDo:evernoteToDo withMatchingSubtask:subtask inNoteProcessor:processor isNew:NO] )
                    updated = YES;
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
        BOOL isNew = NO;
        //DLog(@"bestScore:%f",bestScore);
        //DLog(@"best Levenshtein score: %f (%@ to %@)", bestScore, evernoteToDo.title, bestMatch ? bestMatch.originIdentifier : @"null");
        if( bestScore >= 120 ){
            matchingSubtask = bestMatch;
        }
        
        if ( !matchingSubtask ){
            //NSLog(@"creating subtask from Evernote");
            matchingSubtask = [parentToDo addSubtask:evernoteToDo.title save:YES];
            matchingSubtask.origin = EVERNOTE_SERVICE;
            matchingSubtask.originIdentifier = evernoteToDo.title;
            updated = YES;
            isNew = YES;
        }
        
        [subtasksLeftToBeFound removeObject:matchingSubtask];
        subtasks = [subtasksLeftToBeFound copy];
        [evernoteToDosLeftToBeFound removeObject:evernoteToDo];
        
        BOOL didUpdateSubtask = [self handleEvernoteToDo:evernoteToDo withMatchingSubtask:matchingSubtask inNoteProcessor:processor isNew:isNew];
        if( didUpdateSubtask )
            updated = YES;
        
    }
    
    // remove evernote subtasks not found in the evernote from our task
    subtasks = [subtasksLeftToBeFound copy];
    if ( subtasks && subtasks.count > 0 ){
        updated = YES;
        DLog(@"delete: %@",subtasks);
        [KPToDo deleteToDos:subtasks save:NO force:YES];
    }
    
    // add newly added tasks to evernote
    subtasks = [self filterSubtasksWithoutOrigin:parentToDo.subtasks];
    for ( KPToDo* subtask in subtasks ) {
        if ([processor addToDoWithTitle:subtask.title]) {
            subtask.originIdentifier = subtask.title;
            subtask.origin = EVERNOTE_SERVICE;
            updated = YES;
        }
    }

    if( updated && parentToDo.objectId) {
        [self._updatedTasks addObject:parentToDo.objectId];
    }
    
    return nil;
}

-(void)setUpdatedAt:(NSDate*)updatedAt{
    [[NSUserDefaults standardUserDefaults] setObject:updatedAt forKey:kEvernoteUpdatedAtKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.lastUpdated = updatedAt;
}

-(void)synchronizeWithBlock:(SyncBlock)block{
    self.block = block;
    
    self.block(SyncStatusStarted, nil, nil);
    
    [self findUpdatedNotesWithTag:@"swipes" block:^(SyncStatus status, NSDictionary *userInfo, NSError *error) {
        if(error){
            block(SyncStatusError, nil, error);
        }
        else{
            [self syncEvernoteWithBlock:block];
        }
    }];
    
}


-(void)findUpdatedNotesWithTag:(NSString*)tag block:(SyncBlock)block{
    
    EDAMNoteFilter* filter = [EDAMNoteFilter new];
    NSMutableString *mutWords = [NSMutableString stringWithFormat:@"tag:%@",tag];
    if(self.lastUpdated){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
        NSString *isoString = [dateFormatter stringFromDate:self.lastUpdated];
        [mutWords appendFormat:@" updated:%@",isoString];
    }
    
    filter.words = [mutWords copy];
    
    filter.order = NoteSortOrder_UPDATED;
    filter.ascending = NO;
    
    [kEnInt fetchNotesForFilter:filter offset:0 maxNotes:100 block:^(EDAMNoteList *list, NSError *error) {
        if(list){
            DLog(@"%lu",(long)list.updateCount);
            [self updateEvernoteCount:list.updateCount];
            if( kEnInt.autoFindFromTag ){
                NSMutableArray *newNotes = [NSMutableArray array];
                for( EDAMNote *note in list.notes ){
                    NSArray *existingTasks = [KPAttachment findAttachmentsForService:EVERNOTE_SERVICE identifier:note.guid context:nil];
                    if(existingTasks.count == 0){
                        [newNotes addObject:note];
                    }
                }
                [EvernoteSyncHandler addAndSyncNewTasksFromNotes:newNotes];
            }
            [self syncEvernoteWithBlock:block];
        }
        else if(error){
            block(SyncStatusError, nil ,error);
        }
    }];
}

-(void)syncEvernoteWithBlock:(SyncBlock)block{
    self.objectsWithEvernote = [self getObjectsSyncedWithEvernote];
    
    // If no objects has attachments - send a success back to caller
    if (self.objectsWithEvernote.count == 0){
        return self.block(SyncStatusSuccess, nil, nil);
    }

    // ensure evernote authentication
    NSError* error = [NSError errorWithDomain:@"Evernote not authenticated" code:601 userInfo:nil];
    EvernoteSession *session = [EvernoteSession sharedSession];
    if (!session.isAuthenticated || [EvernoteSession isTokenExpiredWithError:error]) {
        return self.block(SyncStatusError, nil, error);
    }
    
    // Tell caller that Evernote will be syncing
    
    
    NSDate *date = [NSDate date];
    __block NSInteger returnCount = 0;
    __block NSInteger targetCount = self.objectsWithEvernote.count;
    __block NSError *runningError;
    for ( KPToDo *todoWithEvernote in self.objectsWithEvernote ){
        BOOL hasLocalChanges = [todoWithEvernote hasChangesSinceDate:self.lastUpdated];
        if( !hasLocalChanges && !self.updateNeededFromEvernote )
            return self.block(SyncStatusSuccess, nil, nil);
        NSLog(@"running the sync");
        KPAttachment *evernoteAttachment = [todoWithEvernote firstAttachmentForServiceType:EVERNOTE_SERVICE];
        NSString *guid = evernoteAttachment.identifier;
        [EvernoteToDoProcessor processorWithGuid:guid block:^(EvernoteToDoProcessor *processor, NSError *error) {
            
            //NSLog(@"guid:%@",guid);
            if( processor ){
                returnCount++;
                //NSLog(@"processing:%@",processor.toDoItems);
                
                NSArray *evernoteToDos = [[processor.toDoItems reverseObjectEnumerator] allObjects];
                [self findAndHandleMatchesForToDo:todoWithEvernote withEvernoteToDos:evernoteToDos inNoteProcessor:processor];
                if( processor.needUpdate ){
                    [processor saveToEvernote:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            self.expectedEvernoteCount++;
                            //NSLog(@"succeeded save");
                        }
                        else {
                            [UtilityClass sendError:error type:@"Evernote save error"];
                        }
                    }];
                }
            }
            else{
                if(!runningError){
                    runningError = error;
                }
                returnCount++;
                
                // it is strange that evernote returns this code (1) when the note is removed
                // to remove a note on evernote.com first delete it and then remove it from trash too!
                // this will still give you sync error once (because there is an error after all)
                if (error && (1 == error.code)) {
                    [todoWithEvernote removeAllAttachmentsForService:EVERNOTE_SERVICE];
                }
            }
            if(returnCount == targetCount){
                //NSLog(@"hit the target");
                if(runningError){
                    self.block(SyncStatusError, nil, runningError);
                    
                    return;
                }
                // If changes to Core Data - make sure it gets synced to our server.
                if([[KPCORE context] hasChanges]){
                    [KPToDo saveToSync];
                }
                [self setUpdatedAt:date];
                self.updateNeededFromEvernote = NO;
                self.block(SyncStatusSuccess, @{@"updated": [self._updatedTasks copy]}, nil);
                [self._updatedTasks removeAllObjects];
            }
            
        }];
        
    }
}

@end
