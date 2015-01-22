//
//  GmailSyncHandler.m
//  Swipes
//
//  Created by demosten on 1/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

/*
 TODO
 
 - fix the integration data (use the one from Kasper)
 - shall we remove the attachments on logout
 - shall we show anything special todo list
 */

#import "Global.h"
#import "KPToDo.h"
#import "KPAttachment.h"
#import "CoreSyncHandler.h"
#import "UtilityClass.h"
#import "CoreData+MagicalRecord.h"

#import "GmailIntegration.h"
#import "GmailThreadProcessor.h"
#import "GmailSyncHandler.h"

NSString * const kGmailUpdatedAtKey = @"GmailUpdatedAt";

@interface GmailSyncHandler ()

@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, strong) NSMutableArray* updatedTasks;

@end

@implementation GmailSyncHandler

+ (void)initialize
{
    // we need to logout on first run
    // we cannot discover uninstall and gmail stores its authentication token in iOS keychain
    // to the next install with be automatically logged in if we don't do this
    if ([Global isFirstRun]) {
        [kGmInt logout];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lastUpdated = [USER_DEFAULTS objectForKey:kGmailUpdatedAtKey];
        _updatedTasks = [NSMutableArray array];
    }
    return self;
}

-(void)setUpdatedAt:(NSDate*)updatedAt
{
    if (updatedAt) {
        [USER_DEFAULTS setObject:updatedAt forKey:kGmailUpdatedAtKey];
    }
    else {
        [USER_DEFAULTS removeObjectForKey:kGmailUpdatedAtKey];
    }
    [USER_DEFAULTS synchronize];
    self.lastUpdated = updatedAt;
}

-(void)synchronizeWithBlock:(SyncBlock)block
{
    block(SyncStatusStarted, nil, nil);
    if (!kGmInt.isAuthenticated) {
        NSError* error = [NSError errorWithDomain:@"Gmail not authenticated" code:702 userInfo:nil];
        return block(SyncStatusError, nil, error);
    }
    [self findUpdatedThreads:block];
}

- (void)findUpdatedThreads:(SyncBlock)block
{
    NSString *query = nil;
//    if(self.lastUpdated){
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
//        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
//        query = [NSString stringWithFormat:@"after:%@", [dateFormatter stringFromDate:self.lastUpdated]];
//    }
    
    [kGmInt listThreads:query withBlock:^(NSArray *threadListResults, NSError *error) {
        if (error) {
            block(SyncStatusError, nil, error);
        }
        else {
            [self synchronizeThreads:threadListResults withBlock:block];
        }
    }];
}

- (void)synchronizeThreads:(NSArray *)threadListResults withBlock:(SyncBlock)block
{
    __block NSDate *date = [NSDate date];
    __block NSInteger returnCount = 0;
    __block NSInteger targetCount = threadListResults.count;
    __block NSError *runningError;
    
    __block voidBlock finalizeBlock = ^{
        returnCount++;
        if (returnCount == targetCount){
            if (runningError){
                block(SyncStatusError, nil, runningError);
                return;
            }
            // If changes to Core Data - make sure it gets synced to our server.
            if([[KPCORE context] hasChanges]){
                @synchronized(kGmailUpdatedAtKey) {
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
            block(SyncStatusSuccess, @{@"updated": [_updatedTasks copy]}, nil);
            [_updatedTasks removeAllObjects];
        }
    };
    
    // sync with gmail
    for (__block GTLGmailThread* thread in threadListResults) {
        if (![kGmInt hasNoteWithThreadId:thread.identifier]) {
            // we don't know this thread
            [GmailThreadProcessor processorWithThreadId:thread.identifier block:^(GmailThreadProcessor *processor, NSError *error) {
                if (error) {
                    if (!runningError)
                        runningError = error;
                }
                else {
                    NSString* title = [processor title];
                    if (title) {
                        if(title.length > kTitleMaxLength)
                            title = [title substringToIndex:kTitleMaxLength];
                        NSString* identifier = [kGmInt threadIdToNSString:processor.threadId];
                        if (identifier) {
                            KPToDo *newToDo = [KPToDo addItem:title priority:NO tags:nil save:NO from:@"Gmail"];
                            [newToDo attachService:GMAIL_SERVICE title:title identifier:identifier sync:YES from:@"gmail-integration"];
                            [_updatedTasks addObject:newToDo];
                        }
                        else {
                            [UtilityClass sendError:[NSError errorWithDomain:@"Failed to create identifier" code:703 userInfo:nil] type:@"gmail:failed to create identifier"];
                        }
                    }
                }
                finalizeBlock();
            }];
        }
        else {
            // we already have the thread into task
            finalizeBlock();
        }
    }
    
    [self clearLocallyDeleted];
}

- (void)clearLocallyDeleted
{
    // find out locally deleted tasks, remove swipes tag and really delete them
    NSArray* locallyDeleted = [KPToDo findLocallyDeletedForService:GMAIL_SERVICE];
    for (__block KPToDo* todo in locallyDeleted) {
        KPAttachment* attachment = [todo firstAttachmentForServiceType:GMAIL_SERVICE];
        NSString* threadId = [kGmInt NSStringToThreadId:attachment.identifier];
        if (threadId) {
            [kGmInt removeSwipesLabelFromThread:threadId withBlock:^(NSError *error) {
                if (nil == error) {
                    [KPToDo deleteToDos:@[todo] save:YES force:YES];
                }
                else {
                    // TODO
                    // check what happens when the thread is deleted from gmail
                    // check what happens when the label is removed
                }
            }];
        }
    }
}

@end
