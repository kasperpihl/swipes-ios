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

- (instancetype)init
{
    self = [super init];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
        
    }
    return self;
}

- (void)willActivate
{
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate
{
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)loadDataForToDo:(KPToDo *)todo
{
    // load cell types
    NSMutableArray* cellTypes = @[kCellTypeTitle].mutableCopy;
    NSArray* filteredSubtasks;
    if (0 < todo.subtasks.count) {
        NSPredicate *uncompletedPredicate = [NSPredicate predicateWithFormat:@"completionDate == nil"];
        NSSortDescriptor *orderedItemsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        filteredSubtasks = [[todo.subtasks filteredSetUsingPredicate:uncompletedPredicate] sortedArrayUsingDescriptors:@[orderedItemsSortDescriptor]];
        if (0 < filteredSubtasks.count) {
            for (NSUInteger i = 0; i < filteredSubtasks.count; i++) {
                [cellTypes addObject:kCellTypeSubtask];
            }
        }
    }
    [_table setRowTypes:cellTypes];
    
    // load data
    SWADetailCell* cell = [_table rowControllerAtIndex:0];
    [cell.label setText:todo.title];
    if (todo.tags.count) {
        NSMutableString* str = [[NSMutableString alloc] init];
        for (KPTag* tag in todo.tags) {
            if (str.length) {
                [str appendString:@","];
            }
            [str appendString:tag.title];
        }
        [cell.tags setText:str];
    }
    else {
        [cell.tags setHidden:YES];
    }
    
    // load subtasks
    if (0 < filteredSubtasks.count) {
        NSUInteger index = 1;
        for (KPToDo* subtask in filteredSubtasks) {
            SWASubtaskCell* subtaskCell = [self.table rowControllerAtIndex:index++];
            [subtaskCell.label setText:subtask.title];
        }
    }
}

- (void)loadDataForToDos:(NSArray *)toDos
{
    // load cell types
    NSMutableArray* cellTypes = [NSMutableArray array];
    [cellTypes addObject:kCellTypeTitle];
    for (NSUInteger i = 0; i < toDos.count; i++) {
        [cellTypes addObject:kCellTypeSubtask];
    }
    [_table setRowTypes:cellTypes];
    
    // load data
    SWADetailCell* cell = [_table rowControllerAtIndex:0];
    [cell.label setText:[NSString stringWithFormat:@"%lu upcomming tasks", (unsigned long)toDos.count]];
    [cell.tags setHidden:YES];
    
    // load tasks
    NSInteger index = 1;
    for (KPToDo* todo in toDos) {
        SWASubtaskCell* subtaskCell = [self.table rowControllerAtIndex:index++];
        [subtaskCell.label setText:todo.title];
        [subtaskCell.image setImageNamed:@"task_circle"];
    }
}

- (WKUserNotificationInterfaceType)displayTasks:(NSString *)category taskIdentifiers:(NSArray *)taskIdentifiers alert:(NSString *)alert
{
    if (alert && taskIdentifiers && ([category isEqualToString:@"OneTaskCategory"] || [category isEqualToString:@"BatchTasksCategory"])) {
        NSArray *toDos;
        if (taskIdentifiers && taskIdentifiers.count > 0){
            NSError* error;
            toDos = [[SWACoreDataModel sharedInstance] loadTodoWithTempIds:taskIdentifiers error:&error];
            if (error) {
                [SWAUtility sendErrorToHost:error];
            }
            if (toDos && 0 < toDos.count) {
                if (1 == toDos.count)
                    [self loadDataForToDo:toDos[0]];
                else
                    [self loadDataForToDos:toDos];
                return WKUserNotificationInterfaceTypeCustom;
            }
        }
    }
    return WKUserNotificationInterfaceTypeDefault;
}

- (void)didReceiveLocalNotification:(UILocalNotification *)localNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler
{
    NSArray *taskIdentifiers = [localNotification.userInfo objectForKey:@"identifiers"];
    WKUserNotificationInterfaceType result = [self displayTasks:localNotification.category taskIdentifiers:taskIdentifiers alert:localNotification.alertBody];
    completionHandler(result);
}

- (void)didReceiveRemoteNotification:(NSDictionary *)remoteNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler
{
//    completionHandler(WKUserNotificationInterfaceTypeDefault);
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



