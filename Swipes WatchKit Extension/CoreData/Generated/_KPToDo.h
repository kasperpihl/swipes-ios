//
//  KPToDo.h
//  Swipes
//
//  Created by demosten on 12/27/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "_KPParseObject.h"

@class _KPAttachment, _KPTag, _KPToDo;

@interface _KPToDo : _KPParseObject

@property (nonatomic, retain) NSDate * alarm;
@property (nonatomic, retain) NSDate * completionDate;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * numberOfRepeated;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * origin;
@property (nonatomic, retain) NSString * originIdentifier;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSDate * repeatedDate;
@property (nonatomic, retain) NSNumber * repeatOption;
@property (nonatomic, retain) NSDate * schedule;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * tagString;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *attachments;
@property (nonatomic, retain) _KPToDo *parent;
@property (nonatomic, retain) NSSet *subtasks;
@property (nonatomic, retain) NSSet *tags;
@end

@interface _KPToDo (CoreDataGeneratedAccessors)

- (void)addAttachmentsObject:(_KPAttachment *)value;
- (void)removeAttachmentsObject:(_KPAttachment *)value;
- (void)addAttachments:(NSSet *)values;
- (void)removeAttachments:(NSSet *)values;

- (void)addSubtasksObject:(_KPToDo *)value;
- (void)removeSubtasksObject:(_KPToDo *)value;
- (void)addSubtasks:(NSSet *)values;
- (void)removeSubtasks:(NSSet *)values;

- (void)addTagsObject:(_KPTag *)value;
- (void)removeTagsObject:(_KPTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
