//
//  SWACoreDataModel.h
//  Swipes
//
//  Created by demosten on 12/27/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

@import CoreData;
#import <Foundation/Foundation.h>
#import "SWAIncludes.h"
#import "KPToDo.h"

@interface SWACoreDataModel : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)saveContext;
- (NSArray *)loadTodosWithError:(NSError **)error oneResult:(BOOL)oneResult;
- (KPToDo *)loadTodoWithTempId:(NSString *)tempId error:(NSError **)error;
- (void)deleteObject:(id)object;
- (KPToDo *)newToDo;

@end
