//
//  NotificationController.m
//  Swipes WatchKit Extension
//
//  Created by demosten on 12/25/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "Global.h"
#import "SWAIncludes.h"
#import "CoreData/KPToDo.h"
#import "CoreData/KPTag.h"
#import "CoreData/KPAttachment.h"
#import "SWAUtility.h"
#import "SWACoreDataModel.h"
#import "SWADetailCell.h"
#import "SWASubtaskCell.h"
#import "NotificationController.h"

NSString* const kCellTypeTitle = @"SWADetailCell";
NSString* const kCellTypeSubtask = @"SWASubtaskCell";

@interface NotificationController()

@property (nonatomic, weak) IBOutlet WKInterfaceTable* table;

@end

@implementation NotificationController

- (instancetype)init {
    self = [super init];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
        
    }
    return self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (NSUInteger)loadTodoData:(KPToDo *)todo offset:(NSUInteger)offset
{
    NSUInteger totalRows = 1;
    SWADetailCell* cell = [_table rowControllerAtIndex:offset];
    [cell.label setText:todo.title];
    if (todo.tags.count || todo.attachments.count) {
        NSMutableString* str = [[NSMutableString alloc] initWithString:@" "];
        if (todo.tags.count) {
            for (KPTag* tag in todo.tags) {
                if (str.length) {
                    [str appendString:@","];
                }
                [str appendString:tag.title];
            }
        }
        else {
            [str appendString:LOCALIZE_STRING(@"(no tags)")];
        }
        NSUInteger index = 0;
        for (KPAttachment* attachment in todo.attachments) {
            if ([attachment.service isEqualToString:EVERNOTE_SERVICE]) {
                [str insertString:@"\ue64d" atIndex:index++];
            }
            else if ([attachment.service isEqualToString:GMAIL_SERVICE]) {
                [str insertString:@"\ue606" atIndex:index++];
            }
        }
        
        // set attributes
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:str];
        UIFont *swipesFont = iconFont(10);
        [attributedString addAttribute:NSFontAttributeName value:swipesFont range:NSMakeRange(0,index)];
        [cell.tags setAttributedText:attributedString];
    }
    else {
        [cell.tags setHidden:YES];
    }

    // load subtasks
    NSArray* subtasks;
    if (0 < todo.subtasks.count) {
        NSPredicate *uncompletedPredicate = [NSPredicate predicateWithFormat:@"completionDate == nil"];
        NSSortDescriptor *orderedItemsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        subtasks = [[todo.subtasks filteredSetUsingPredicate:uncompletedPredicate] sortedArrayUsingDescriptors:@[orderedItemsSortDescriptor]];
        if (0 < subtasks.count) {
            NSUInteger index = offset + totalRows;
            for (KPToDo* subtask in subtasks) {
                SWASubtaskCell* subtaskCell = [self.table rowControllerAtIndex:index++];
                [subtaskCell.label setText:subtask.title];
            }
            totalRows += subtasks.count;
        }
    }
    
    return totalRows;
}

- (NSArray *)cellTypesForTodo:(KPToDo *)todo
{
    NSMutableArray* cellTypes = @[kCellTypeTitle].mutableCopy;
    if (todo.subtasks) {
        for (NSUInteger i = 0; i < todo.subtasks.count; i++) {
            [cellTypes addObject:kCellTypeSubtask];
        }
    }
    return cellTypes;
}

- (void)loadDataForToDos:(NSArray *)toDos
{
    // load cell types
    NSMutableArray* cellTypes = [NSMutableArray array];
    for (KPToDo* todo in toDos) {
        [cellTypes addObjectsFromArray:[self cellTypesForTodo:todo]];
    }
    [_table setRowTypes:cellTypes];
    
    // load data
    NSUInteger offset = 0;
    for (KPToDo* todo in toDos) {
        offset += [self loadTodoData:todo offset:offset];
    }
}

- (WKUserNotificationInterfaceType)displayTasks:(NSString *)category taskIdentifiers:(NSArray *)taskIdentifiers alert:(NSString *)alert
{
    if (alert && taskIdentifiers && ([category isEqualToString:@"OneTaskCategory"] || [category isEqualToString:@"BatchTasksCategory"])) {
        NSArray *toDos;
        if (taskIdentifiers && taskIdentifiers.count > 0){
            NSError* error;
            toDos = [[SWACoreDataModel sharedInstance] loadTodoWithTempIds:taskIdentifiers error:&error];
            if (toDos && 0 < toDos.count) {
                return WKUserNotificationInterfaceTypeCustom;
            }
        }
    }
    return WKUserNotificationInterfaceTypeDefault;
}

- (void)didReceiveLocalNotification:(UILocalNotification *)localNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    NSArray *taskIdentifiers = [localNotification.userInfo objectForKey:@"identifiers"];
    WKUserNotificationInterfaceType result = [self displayTasks:localNotification.category taskIdentifiers:taskIdentifiers alert:localNotification.alertBody];
    
    // After populating your dynamic notification interface call the completion block.
    completionHandler(result);
}

- (void)didReceiveRemoteNotification:(NSDictionary *)remoteNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    // This method is called when a remote notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification inteface as quickly as possible.
    NSDictionary* aps = remoteNotification[@"aps"];
    NSArray* taskIdentifiers = remoteNotification[@"identifiers"];
    if (aps && taskIdentifiers && (0 < taskIdentifiers.count)) {
        WKUserNotificationInterfaceType result = [self displayTasks:aps[@"category"] taskIdentifiers:taskIdentifiers alert:aps[@"alert"]];
        completionHandler(result);
    }
    else {
        completionHandler(WKUserNotificationInterfaceTypeDefault);
    }
}


@end



