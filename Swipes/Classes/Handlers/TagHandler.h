//
//  TagHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 27/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#define TAGHANDLER [TagHandler sharedInstance]
@class KPToDo;
#import "KPTag.h"
@interface TagHandler : NSObject
+(TagHandler*)sharedInstance;
-(void)addTag:(NSString *)tag;
-(void)deleteTag:(NSString*)tag;
-(NSArray *)allTags;
//-(void)addTags:(NSArray*)addedTags andRemoveTags:(NSArray*)removedTags fromToDos:(NSArray*)toDos;
-(void)updateTags:(NSArray*)tags remove:(BOOL)remove toDos:(NSArray*)toDos;
-(NSArray *)selectedTagsForToDos:(NSArray*)toDos;
@end
