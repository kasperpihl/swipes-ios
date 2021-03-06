//
//  ParentSyncHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 15/06/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SyncStatusNone = 0,
    SyncStatusStarted,
    SyncStatusProgress,
    SyncStatusSuccess,
    SyncStatusSuccessWithData, // there is new data
    SyncStatusError
    
} SyncStatus;

typedef void (^SyncBlock) (SyncStatus status, NSDictionary *userInfo, NSError *error);

@interface ParentSyncHandler : NSObject
@property BOOL syncIsEnabled;
@property (nonatomic, assign) BOOL isSyncing;
@property (nonatomic, copy) SyncBlock block;
-(void)synchronizeWithBlock:(SyncBlock)block;
@end
