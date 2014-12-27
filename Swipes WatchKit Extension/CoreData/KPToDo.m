//
//  SWAToDo.m
//  Swipes
//
//  Created by demosten on 12/27/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "SWACoreDataModel.h"
#import "KPToDo.h"
#import "SWAIncludes.h"
#import "NSDate-Utilities.h"

@implementation KPToDo

+(KPToDo *)newObjectInContext:(NSManagedObjectContext*)context{
    KPToDo* todo = [[SWACoreDataModel sharedInstance] newToDo];
    [todo getTempId];
    [[SWACoreDataModel sharedInstance] saveContext];
    return todo;
}

+(NSString*)generateIdWithLength:(NSInteger)length{
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:length];
    for (NSUInteger i = 0; i < length; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return s;
}

-(NSString *)getTempId{
    if(!self.tempId){
        self.tempId = [KPToDo generateIdWithLength:14];
    }
    return self.tempId;
}

-(KPToDo*)deepCopyInContext:(NSManagedObjectContext*)context{
    KPToDo *newToDo = [KPToDo newObjectInContext:context];
    newToDo.completionDate = self.completionDate;
    newToDo.notes = self.notes;
    newToDo.order = self.order;
    newToDo.schedule = self.schedule;
    [newToDo setTags:self.tags];
    newToDo.tagString = self.tagString;
    newToDo.title = self.title;
    return newToDo;
}

-(NSDate *)nextDateFrom:(NSDate*)date{
    NSDate *returnDate;
    switch ([self.repeatOption integerValue]) {
        case RepeatEveryDay:
            returnDate = [date dateByAddingDays:1];
            break;
        case RepeatEveryMonFriOrSatSun:
            if(date.isTypicallyWeekend) returnDate = [date dateAtNextWeekendDay];
            else returnDate = [date dateAtNextWorkday];
            break;
        case RepeatEveryWeek:
            returnDate = [date dateByAddingWeeks:1];
            break;
        case RepeatEveryMonth:
            returnDate = [date dateByAddingMonths:1];
            break;
        case RepeatEveryYear:
            returnDate = [date dateByAddingYears:1];
            break;
    }
    return returnDate;
}

-(void)scheduleForDate:(NSDate*)date
{
    if (self.location)
        self.location = nil;
    
    if (!date) {
        self.repeatedDate = nil;
        self.repeatOption = RepeatNever;
    }
    self.schedule = date;
    /* If this task was completed less than 15 minutes ago - don't put at the top of the stack but in it's old place */
    if (!self.parent && !(self.completionDate && [self.completionDate minutesBeforeDate:[NSDate date]] < 15))
        self.order = @(-1);
    self.completionDate = nil;
}

-(void)copyActionStepsToCopy:(KPToDo*)copy inContext:(NSManagedObjectContext *)context{
    for (KPToDo *actionStep in self.subtasks ){
        KPToDo *newToDo = [KPToDo newObjectInContext:context];
        newToDo.completionDate = actionStep.completionDate;
        newToDo.order = actionStep.order;
        newToDo.schedule = actionStep.schedule;
        newToDo.parent = copy;
        newToDo.title = actionStep.title;
        
        if(actionStep.completionDate)
            [actionStep scheduleForDate:nil];
    }
}

-(void)completeRepeatedTaskInContext:(NSManagedObjectContext*)context{
    if (self.repeatOption == RepeatNever)
        return;
    
    NSDate *next = [self nextDateFrom:self.repeatedDate];
    
    int32_t numberOfRepeated = [self.numberOfRepeated intValue];
    while ([next isInPast]) {
        next = [self nextDateFrom:next];
    }
    KPToDo *toDoCopy = [self deepCopyInContext:context];
    [self copyActionStepsToCopy:toDoCopy inContext:context];
    toDoCopy.numberOfRepeated = @(++numberOfRepeated);
    [toDoCopy completeInContext:context];
    [self scheduleForDate:next];
    self.repeatedDate = next;
    self.numberOfRepeated = [NSNumber numberWithInteger:numberOfRepeated];
}

-(void)completeInContext:(NSManagedObjectContext*)context{
    if (self.location)
        self.location = nil;
    if ([self.repeatOption intValue] > RepeatNever) {
        [self completeRepeatedTaskInContext:context];
    }
    else {
        self.schedule = nil;
        self.completionDate = [NSDate date];
    }
}

-(void)complete
{
    [self completeInContext:[SWACoreDataModel sharedInstance].managedObjectContext];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"KPToDo -> title: %@, order: %@, origin: %@ - %@", self.title, self.order, self.origin, self.originIdentifier];
}


@end
