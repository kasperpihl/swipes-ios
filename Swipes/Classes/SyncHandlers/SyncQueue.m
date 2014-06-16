//
//  SyncQueue.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 15/06/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "SyncQueue.h"
@interface SyncQueue ()
@property NSMutableArray *syncHandlers;
@property BOOL _needSync;
@property NSInteger syncingIndex;
@property BOOL isSyncing;
@end
@implementation SyncQueue
static SyncQueue *sharedObject;
+(SyncQueue *)sharedInstance{
    if ( !sharedObject ){
        sharedObject = [[SyncQueue allocWithZone:NULL] init];
        sharedObject.syncHandlers = [NSMutableArray array];
        sharedObject.syncingIndex = -1;
    }
    return sharedObject;
}
-(void)registerSyncHandler:(ParentSyncHandler *)handler{

    if( ![self.syncHandlers containsObject:handler])
        [self.syncHandlers addObject:handler];
    
    
}
-(void)nextHandler{
    self.syncingIndex++;
    
    if( self.syncingIndex >= self.syncHandlers.count )
        return [self done];
    
    ParentSyncHandler *nextHandler = [self.syncHandlers objectAtIndex:self.syncingIndex];
    [nextHandler synchronizeWithBlock:^(SyncStatus status, NSDictionary *userInfo, NSError *error) {
        
    }];
    
}
-(void)done{
    self.syncingIndex = -1;
    
}
-(void)synchronize{
    [self nextHandler];
}
@end
