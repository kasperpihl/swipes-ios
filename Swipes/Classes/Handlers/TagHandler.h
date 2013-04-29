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
-(NSArray *)allTags;
-(void)addTags:(NSArray*)addedTags andRemoveTags:(NSArray*)removedTags fromToDos:(NSArray*)toDos;
-(NSArray *)selectedTagsForToDos:(NSArray*)toDos;
@end
