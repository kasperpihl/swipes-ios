//
//  SyncQueue.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 15/06/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParentSyncHandler.h"
#define kSyncQueue [SyncQueue sharedInstance]

typedef enum {
    SyncHandlerCore,
    SyncHandlerEvernote
} SyncHandlers;

@interface SyncQueue : NSObject
+(SyncQueue*)sharedInstance;
-(BOOL)isSyncing;

-(void)registerSyncHandler:(ParentSyncHandler*)handler;
-(void)synchronize;
@end
