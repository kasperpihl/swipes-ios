//
//  EvernoteSyncHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 15/06/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <ENSDK/Advanced/ENSDKAdvanced.h>
#import "Underscore.h"
#import "MF_Base64Additions.h"
#import "KPToDo.h"
#import "KPAttachment.h"
#import "EvernoteToDoProcessor.h"
#import "NSDate-Utilities.h"
#import "NSString+Levenshtein.h"
#import "CoreSyncHandler.h"
#import "UtilityClass.h"
#import "CoreData+MagicalRecord.h"
#import "EvernoteView.h"
#import "KPBlurry.h"
#import "EvernoteIntegration.h"
#import "RootViewController.h"
#import "ENNoteRefInternal.h"

#import "EvernoteSyncHandler.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#define kMaxNotes 100

#define kFetchChangesTimeout 30

NSString * const kEvernoteUpdatedAtKey = @"EvernoteUpdatedAt";
NSString * const kEvernoteMoveTime = @"EvernoteMoveTime";
NSString * const kEvernoteGuidConveted = @"EvernoteGuidConverted";
NSString * const kEvernoteNoteRefConveted = @"EvernoteNoteRefConverted";

@interface EvernoteSyncHandler () <EvernoteViewDelegate>
@property (nonatomic, copy) SyncBlock block;
@property NSArray *objectsWithEvernote;
@property NSDate *lastUpdated;
@property BOOL updateNeededFromEvernote;
@property BOOL needToClearCache;

@property BOOL fullEvernoteUpdate;
@property NSInteger currentEvernoteUpdateCount;
@property NSInteger expectedEvernoteCount;


@property NSMutableSet *changedNotes;
@property (nonatomic) NSMutableArray *_updatedTasks;
@end
@implementation EvernoteSyncHandler

+(NSArray *)addAndSyncNewTasksFromNotes:(NSArray *)notes
{
    for (ENSessionFindNotesResult *note in notes){
        NSString *title;
        if (note.title) {
            title = note.title;
        }
        else {
            title = @"Untitled note";
        }
        if(title.length > kTitleMaxLength)
            title = [title substringToIndex:kTitleMaxLength];
        KPToDo *newToDo = [KPToDo addItem:title priority:NO tags:nil save:NO from:@"Evernote"];
        [newToDo attachService:EVERNOTE_SERVICE title:title identifier:[EvernoteIntegration ENNoteRefToNSString:note.noteRef] sync:YES from:@"swipes-tag"];
    }
    if (notes.count > 0)
        [KPCORE saveContextForSynchronization:nil];
    return nil;
}

-(instancetype)init{
    self = [super init];
    if( self ){
        self.changedNotes = [NSMutableSet set];
        self.lastUpdated = [USER_DEFAULTS objectForKey:kEvernoteUpdatedAtKey];
        [self convertGuidToENNoteRef];
    }
    return self;
}

-(NSMutableArray *)_updatedTasks{
    if( !__updatedTasks )
        __updatedTasks = [NSMutableArray array];
    return __updatedTasks;
}
-(BOOL)hasObjectsSyncedWithEvernote{
    NSManagedObjectContext *contextForThread = [NSManagedObjectContext MR_contextForCurrentThread];
    NSPredicate *predicateForTodosWithEvernote = [NSPredicate predicateWithFormat:@"service = %@ AND sync == 1",EVERNOTE_SERVICE];
    NSUInteger numberOfAttachmentsWithEvernote = [KPAttachment MR_countOfEntitiesWithPredicate:predicateForTodosWithEvernote inContext:contextForThread];
    return (numberOfAttachmentsWithEvernote > 0);
}
-(NSArray*)getObjectsSyncedWithEvernote{
    
    NSManagedObjectContext *contextForThread = [NSManagedObjectContext MR_contextForCurrentThread];
    
    NSPredicate *predicateForTodosWithEvernote = [NSPredicate predicateWithFormat:@"ANY attachments.service like %@ AND ANY attachments.sync == 1",EVERNOTE_SERVICE];
    NSArray *todosWithEvernote = [KPToDo MR_findAllWithPredicate:predicateForTodosWithEvernote inContext:contextForThread];
    
    return todosWithEvernote;
    
}


-(void)updateEvernoteCount:(NSInteger)newUpdateCount{
    DLog(@"new %lu exp %lu",(long)newUpdateCount,(long)self.expectedEvernoteCount);
    if( newUpdateCount > self.expectedEvernoteCount ){
        self.updateNeededFromEvernote = YES;
    }
    self.currentEvernoteUpdateCount = newUpdateCount;
    self.expectedEvernoteCount = newUpdateCount;
}

-(void)clearCache{
    self.needToClearCache = YES;
    [kEnInt cacheClear];
}

// Just testing
//-(void)didDelay{
//    self.block(SyncStatusSuccess, @{@"userInfoStuff": @"blabla"}, nil);
//}

-(NSArray*)filterSubtasks:(NSSet*)subtasks{
    NSPredicate *subtaskPredicate = [NSPredicate predicateWithFormat:@"origin == %@ OR origin = nil", EVERNOTE_SERVICE];
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
    if ( [subtask.isLocallyDeleted boolValue] && !evernoteToDo.checked ){
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
            if ( !isNew && self.lastUpdated && [self.lastUpdated isEarlierThanDate:subtask.updatedAt] ){
                DLog(@"uncompleting evernote");
                [processor updateToDo:evernoteToDo checked:subtaskIsCompleted];
            }
            // If not, override in Swipes
            else{
                DLog(@"completing subtask");
                [KPToDo completeToDos:@[ subtask ] save:NO context:nil analytics:YES];
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

-(KPToDo*)findAndHandleMatchesForToDo:(KPToDo*)parentToDo withEvernoteToDos:(NSArray *)evernoteToDos inNoteProcessor:(EvernoteToDoProcessor*)processor
{
    // search for our TODO (comparing only title)
    NSArray *subtasks = [self filterSubtasks:parentToDo.subtasks];
    
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
                
                // subtask exists but not marked as evernote yet
                if (nil == subtask.origin) {
                    subtask.originIdentifier = evernoteToDo.title;
                    subtask.origin = EVERNOTE_SERVICE;
                    [KPToDo saveToSync];
                }
                
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
            matchingSubtask = [parentToDo addSubtask:evernoteToDo.title save:YES from:@"Evernote" analytics:NO];
            matchingSubtask.origin = EVERNOTE_SERVICE;
            matchingSubtask.originIdentifier = evernoteToDo.title;
            updated = YES;
            isNew = YES;
        }
        else if (nil == matchingSubtask.origin) {
            // subtask exists but not marked as evernote yet
            matchingSubtask.originIdentifier = evernoteToDo.title;
            matchingSubtask.origin = EVERNOTE_SERVICE;
            [KPToDo saveToSync];
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
    if (subtasks && subtasks.count > 0) {
        for (KPToDo* subtask in subtasks) {
            if (nil != subtask.origin && [subtask.origin isEqualToString:EVERNOTE_SERVICE]) {
                updated = YES;
                DLog(@"delete: %@",subtask);
                [KPToDo deleteToDos:@[subtask] save:YES force:YES];
            }
        }
    }
    
    // add newly added tasks to evernote
    subtasks = [self filterSubtasksWithoutOrigin:parentToDo.subtasks];
    for ( KPToDo* subtask in subtasks ) {
        if ([processor addToDoWithTitle:subtask.title]) {
            subtask.originIdentifier = subtask.title;
            subtask.origin = EVERNOTE_SERVICE;
            updated = YES;
            [KPToDo saveToSync];
        }
    }

    if (updated && parentToDo.objectId) {
        [self._updatedTasks addObject:parentToDo.objectId];
    }
    
    return nil;
}

-(void)setUpdatedAt:(NSDate*)updatedAt{
    if (updatedAt) {
        [USER_DEFAULTS setObject:updatedAt forKey:kEvernoteUpdatedAtKey];
    }
    else {
        [USER_DEFAULTS removeObjectForKey:kEvernoteUpdatedAtKey];
    }
    [USER_DEFAULTS synchronize];
    self.lastUpdated = updatedAt;
}

-(void)synchronizeWithBlock:(SyncBlock)block{
    self.block = block;
    [self.changedNotes removeAllObjects];
    kEnInt.requestCounter = 0;
    self.block(SyncStatusStarted, nil, nil);
    BOOL hasLocalChanges = [self checkForLocalChanges];
    if(!hasLocalChanges && !self.needToClearCache){
        //DLog(@"%f > -%i",[self.lastUpdated timeIntervalSinceNow],kFetchChangesTimeout);
        if(self.lastUpdated && [self.lastUpdated timeIntervalSinceNow] > -kFetchChangesTimeout ){
            //DLog(@"returning due to caching");
            return self.block(SyncStatusSuccess, nil, nil );
        }
    }

    if (self.needToClearCache)
        self.needToClearCache = NO;
    
    if (kEnInt.autoFindFromTag) {
        [self findUpdatedNotesWithTag:@"swipes" block:^(SyncStatus status, NSDictionary *userInfo, NSError *error) {
            if(error){
                block(SyncStatusError, nil, error);
            }
            else{
                [self syncEvernoteWithBlock:block];
            }
        }];
    }
    else {
        [self fetchEvernoteChangesWithBlock:block];
    }
}

-(BOOL)checkForLocalChanges{
    BOOL result = NO;
    self.objectsWithEvernote = [self getObjectsSyncedWithEvernote];
    for ( KPToDo *todoWithEvernote in self.objectsWithEvernote ){
        if ([todoWithEvernote hasChangesSinceDate:self.lastUpdated]) {
            result = YES;
            break;
        }
    }
    return result;
}

-(void)findUpdatedNotesWithTag:(NSString*)tag block:(SyncBlock)block{
    
    NSMutableString *mutWords = [NSMutableString stringWithFormat:@"tag:%@", tag];
    if(self.lastUpdated){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
        NSString *isoString = [dateFormatter stringFromDate:self.lastUpdated];
        [mutWords appendFormat:@" updated:%@",isoString];
    }
    
    [kEnInt findNotesWithSearch:mutWords block:^(NSArray *findNotesResults, NSError *error) {
        if (findNotesResults) {
//            DLog(@"%lu",(long)list.updateCount);
            
// Should we update count somehow?
//            [self updateEvernoteCount:[list.updateCount integerValue]];
            if (kEnInt.autoFindFromTag) {
                NSMutableArray *newNotes = [NSMutableArray array];
                for (ENSessionFindNotesResult *findNoteResult in findNotesResults) {
                    if (![EvernoteIntegration hasNoteWithRef:findNoteResult.noteRef]) {
                        [newNotes addObject:findNoteResult];
                    }
                    [self.changedNotes addObject:findNoteResult];
                }
                [EvernoteSyncHandler addAndSyncNewTasksFromNotes:newNotes];
            }
//            if (self.updateNeededFromEvernote)
                [self fetchEvernoteChangesWithBlock:block];
//            else
//                [self syncEvernoteWithBlock:block];
        }
        else if(error){
            block(SyncStatusError, nil ,error);
        }
    }];
}

-(void)fetchEvernoteChangesWithBlock:(SyncBlock)block{
    NSString *searchString;
    if(self.lastUpdated){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
        NSString *isoString = [dateFormatter stringFromDate:self.lastUpdated];
        searchString = [NSString stringWithFormat:@"updated:%@",isoString];
    }
    
    DLog(@"fetching changes from Evernote");
    
    [kEnInt findNotesWithSearch:searchString block:^(NSArray *findNotesResults, NSError *error) {
        if (findNotesResults){
//            if(findNotesResults.count == kMaxNotes || [list.updateCount integerValue] != self.expectedEvernoteCount){
//                DLog(@"clearing all caches");
//                [kEnInt cacheClear];
//            }
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            NSArray *identifiers = [KPAttachment allIdentifiersForService:EVERNOTE_SERVICE sync:YES context:localContext];
            for (ENSessionFindNotesResult *findNoteResult in findNotesResults) {
                for (NSString* identifier in identifiers) {
                    if ([EvernoteIntegration isNoteRefString:identifier]) {
                        // we have a ENNoteRef
                        ENNoteRef* localNoteRef = [EvernoteIntegration NSStringToENNoteRef:identifier];
                        ENNoteRef* remoteNoteRef = findNoteResult.noteRef;
                        if ([remoteNoteRef.guid isEqualToString:localNoteRef.guid] && (remoteNoteRef.type == localNoteRef.type)) {
                            [self.changedNotes addObject:findNoteResult];
//                            [kEnInt cacheAddNote:note forGuid:note.guid];
                        }
                    }
                    else {
                        // this is the old guid
                    }
                }
            }
            [self syncEvernoteWithBlock:block];
        }
        else if(error){
            block(SyncStatusError, nil ,error);
        }
    }];
}

-(BOOL)hasChangedFromEvernoteId:(NSString*)enid
{
    for ( ENSessionFindNotesResult* note in self.changedNotes ) {
        if ([enid isEqualToString:[EvernoteIntegration ENNoteRefToNSString:note.noteRef]])
            return YES;
        else if ([enid isEqualToString:note.noteRef.guid])
            return YES;
        else {
            ENNoteRef* localNoteRef = [EvernoteIntegration NSStringToENNoteRef:enid];
            if (localNoteRef && [note.noteRef.guid isEqualToString:localNoteRef.guid] && (note.noteRef.type == localNoteRef.type))
                return YES;
        }
    }
    return NO;
}

-(void)handleUpdatedOrDeleted:(KPToDo *)todo evernoteAttachment:(KPAttachment *)evernoteAttachment
{
#ifndef NOT_APPLICATION
    
    NSDate* dateWait = [USER_DEFAULTS objectForKey:kEvernoteMoveTime];
    if (dateWait && [dateWait isLaterThanDate:[NSDate date]]) {
        return;
    }
    
    if (UIApplicationStateBackground == [[UIApplication sharedApplication] applicationState])
        return;
    
    NSString* msg = [NSString stringWithFormat:@"Evernote note attached to the task with title \"%@\" is missing. Select \"Note was moved\" to select the new note, \"Note was deleted\" to detach", todo.title];
    [UTILITY alertWithTitle:nil andMessage:msg buttonTitles:@[@"Note was moved", @"Note was deleted", @"Remind me tomorrow"] block:^(NSInteger number, NSError *error) {
        
        switch (number) {
            case 0: { // moved note
                    EvernoteView* evernoteView = [[EvernoteView alloc] initWithFrame:CGRectMake(0, 0, 320, ROOT_CONTROLLER.view.frame.size.height)];
                    evernoteView.delegate = self;
                    evernoteView.caller = ROOT_CONTROLLER;
                    evernoteView.userData = evernoteAttachment;
                
                    // we need to minimize the title to first two words max, otherwise the search filter cannot find it
                    NSArray* titleWords = [[evernoteAttachment.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@" "];
                    NSString* title = nil;
                    if (1 == titleWords.count) {
                        title = titleWords[0];
                    }
                    else if (2 <= titleWords.count) {
                        title = [NSString stringWithFormat:@"%@ %@", titleWords[0], titleWords[1]];
                    }
                    if (title)
                        evernoteView.initialText = [NSString stringWithFormat:@"intitle:\"%@\"", title];
                
                    BLURRY.showPosition = PositionBottom;
                    [BLURRY showView:evernoteView inViewController:ROOT_CONTROLLER];
                }
                break;
                
            case 1: // deleted note
                [todo removeAllAttachmentsForService:EVERNOTE_SERVICE];
                [KPToDo saveToSync];
                break;
                
            case 2: // wait one more day
                [USER_DEFAULTS setObject:[NSDate dateWithDaysFromNow:1] forKey:kEvernoteMoveTime];
                [USER_DEFAULTS synchronize];
                break;
                
            default:
                break;
        }
    }];
    
#endif
}

- (void)selectedEvernoteInView:(EvernoteView *)evernoteView noteRef:(ENNoteRef *)noteRef title:(NSString *)title sync:(BOOL)sync
{
#ifndef NOT_APPLICATION
    [BLURRY dismissAnimated:YES];
    KPAttachment* evernoteAttachment = evernoteView.userData;
    evernoteAttachment.identifier = [EvernoteIntegration ENNoteRefToNSString:noteRef];
    [KPToDo saveToSync];
#endif
}

- (void)closeEvernoteView:(EvernoteView *)evernoteView
{
#ifndef NOT_APPLICATION
    [BLURRY dismissAnimated:YES];
#endif
}


-(void)syncEvernoteWithBlock:(SyncBlock)block{
    
    self.objectsWithEvernote = [self getObjectsSyncedWithEvernote];
    DLog(@"performing sync with Evernote");
    
    // ensure evernote authentication
    NSError* error = [NSError errorWithDomain:@"Evernote not authenticated" code:601 userInfo:nil];
    ENSession *session = [ENSession sharedSession];
    if (!session.isAuthenticated) {
        return self.block(SyncStatusError, nil, error);
    }
    
    // this is needed in case you have old client synchronizing the old info
    //[self convertGuidToENNoteRef];
    
    // Tell caller that Evernote will be syncing
    
    
    __block NSDate *date = [NSDate date];
    __block NSInteger returnCount = 0;
    __block NSInteger targetCount = self.objectsWithEvernote.count;
    __block NSError *runningError;
    
    __block voidBlock finalizeBlock = ^{
        returnCount++;
        if(returnCount == targetCount){
            DLog(@"requests used for Evernote sync: %lu",(long)kEnInt.requestCounter);
            if(runningError){
                self.block(SyncStatusError, nil, runningError);
                return;
            }
            // If changes to Core Data - make sure it gets synced to our server.
            if([[KPCORE context] hasChanges]){
                @synchronized(kEvernoteUpdatedAtKey) {
                    NSUndoManager* um = [KPCORE context].undoManager;
                    BOOL state = um.isUndoRegistrationEnabled;
                    if (state)
                        [um disableUndoRegistration];
                    [KPToDo saveToSync];
                    if (state != um.isUndoRegistrationEnabled)
                        [um enableUndoRegistration];
                }
            }
            [self setUpdatedAt:date];
            self.updateNeededFromEvernote = NO;
            [self.changedNotes removeAllObjects];
            self.block(SyncStatusSuccess, @{@"updated": [self._updatedTasks copy]}, nil);
            [self._updatedTasks removeAllObjects];
        }
    };
    BOOL syncedAnything = NO;
    for (KPToDo *todoWithEvernote in self.objectsWithEvernote) {
        
        __block KPAttachment *evernoteAttachment = [todoWithEvernote firstAttachmentForServiceType:EVERNOTE_SERVICE];
        NSString *noteRefString = evernoteAttachment.identifier;
        
        BOOL hasLocalChanges = [todoWithEvernote hasChangesSinceDate:self.lastUpdated];
        if (hasLocalChanges) {
            DLog(@"local changes: %@",todoWithEvernote.title);
        }
        BOOL hasChangesFromEvernote = [self hasChangedFromEvernoteId:noteRefString];
        if (hasChangesFromEvernote) {
            DLog(@"evernote changes: %@",todoWithEvernote.title);
        }
        
        if( !hasLocalChanges && !hasChangesFromEvernote ){
            finalizeBlock();
            continue;
        }
        syncedAnything = YES;

        [EvernoteToDoProcessor processorWithNoteRefString:noteRefString block:^(EvernoteToDoProcessor *processor, NSError *error) {

            if (processor) {
                
                //DLog(@"processing:%@",processor.toDoItems);
                
                NSArray *evernoteToDos = [[processor.toDoItems reverseObjectEnumerator] allObjects];
                [self findAndHandleMatchesForToDo:todoWithEvernote withEvernoteToDos:evernoteToDos inNoteProcessor:processor];
                if( processor.needUpdate ){
                    [processor saveToEvernote:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            self.expectedEvernoteCount++;
                            //NSLog(@"succeeded save");
                        }
                        else if (error) {
                            if ([error.domain isEqualToString:ENErrorDomain] && ((error.code == ENErrorCodeNotFound) || (error.code == ENErrorCodeDataConflict))) {
                                DLog(@"Note moved or deleted");
                                [self handleUpdatedOrDeleted:todoWithEvernote evernoteAttachment:evernoteAttachment];
                            }
                            else if(!runningError){
                                runningError = error;
                            }
                            [UtilityClass sendError:error type:@"Evernote save error"];
                        }
                        finalizeBlock();
                    }];
                }
                else{
                    finalizeBlock();
                }
            }
            else{
                if ([error.domain isEqualToString:ENErrorDomain] && ((error.code == ENErrorCodeNotFound) || (error.code == ENErrorCodeDataConflict))) {
                    DLog(@"Note moved or deleted");
                    [self handleUpdatedOrDeleted:todoWithEvernote evernoteAttachment:evernoteAttachment];
                }
                else if (!runningError) {
                    runningError = error;
                }
                
                [UtilityClass sendError:error type:@"Evernote save error"];
                
                // it is strange that evernote returns this code (1) when the note is removed
                // to remove a note on evernote.com first delete it and then remove it from trash too!
                // this will still give you sync error once (because there is an error after all)
                if (error && (1 == error.code)) {
                    [todoWithEvernote removeAllAttachmentsForService:EVERNOTE_SERVICE];
                }
                finalizeBlock();
            }
            
        }];
        
    }
    if(!syncedAnything)
        return self.block(SyncStatusSuccess, nil, nil);
}

- (void)convertGuidToENNoteRef
{
    BOOL isGuidConverted = [USER_DEFAULTS boolForKey:kEvernoteGuidConveted];
    if (!isGuidConverted) {
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        NSArray *attachments = [KPAttachment MR_findByAttribute:@"service" withValue:EVERNOTE_SERVICE inContext:localContext];
        for (KPAttachment* attachment in attachments) {
            if (![EvernoteIntegration isNoteRefString:attachment.identifier]) {
                ENNoteRef* noteRef = [[ENNoteRef alloc] init];
                noteRef.guid = attachment.identifier;
                noteRef.type = ENNoteRefTypePersonal;
                noteRef.linkedNotebook = nil;
                attachment.identifier = [EvernoteIntegration ENNoteRefToNSString:noteRef];
            }
        }
        [KPToDo saveToSync];
        [USER_DEFAULTS setBool:YES forKey:kEvernoteGuidConveted];
        [USER_DEFAULTS synchronize];
    }

    BOOL isNoteRefConverted = [USER_DEFAULTS boolForKey:kEvernoteNoteRefConveted];
    if (!isNoteRefConverted) {
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        NSArray *attachments = [KPAttachment MR_findByAttribute:@"service" withValue:EVERNOTE_SERVICE inContext:localContext];
        for (KPAttachment* attachment in attachments) {
            if (![EvernoteIntegration isNoteRefJsonString:attachment.identifier]) {
                ENNoteRef* noteRef = [EvernoteIntegration NSStringToENNoteRef:attachment.identifier];
                attachment.identifier = [EvernoteIntegration ENNoteRefToNSString:noteRef];
            }
        }
        [KPToDo saveToSync];
        [USER_DEFAULTS setBool:YES forKey:kEvernoteNoteRefConveted];
        [USER_DEFAULTS synchronize];
    }
}

@end

#pragma clang diagnostic pop
