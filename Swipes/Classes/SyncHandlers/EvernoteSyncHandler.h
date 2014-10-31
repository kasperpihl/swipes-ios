//
//  EvernoteSyncHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 15/06/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "ParentSyncHandler.h"

@interface EvernoteSyncHandler : ParentSyncHandler
+(NSArray*)addAndSyncNewTasksFromNotes:(NSArray*)notes;
//-(void)getSwipesTagGuidBlock:(StringBlock)block;
-(NSArray*)getObjectsSyncedWithEvernote;
-(BOOL)hasObjectsSyncedWithEvernote;
-(void)clearCache;
-(void)setUpdatedAt:(NSDate*)updatedAt;
@end
