//
//  KPTag.h
//  Swipes
//
//  Created by demosten on 12/27/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "_KPParseObject.h"

@class _KPToDo;

@interface _KPTag : _KPParseObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *todos;
@end

@interface _KPTag (CoreDataGeneratedAccessors)

- (void)addTodosObject:(_KPToDo *)value;
- (void)removeTodosObject:(_KPToDo *)value;
- (void)addTodos:(NSSet *)values;
- (void)removeTodos:(NSSet *)values;

@end
