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
    SyncStatusError
    
} SyncStatus;

typedef void (^SyncBlock) (SyncStatus status, NSDictionary *userInfo, NSError *error);

@interface ParentSyncHandler : NSObject
-(void)synchronizeWithBlock:(SyncBlock)block;
@end
