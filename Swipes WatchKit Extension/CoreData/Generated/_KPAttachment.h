//
//  KPAttachment.h
//  Swipes
//
//  Created by demosten on 12/27/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class _KPToDo;

@interface _KPAttachment : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * service;
@property (nonatomic, retain) NSNumber * sync;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) _KPToDo *todo;

@end
