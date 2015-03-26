//
//  GlanceController.m
//  Swipes WatchKit Extension
//
//  Created by demosten on 12/25/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "Global.h"
#import "SWAIncludes.h"
#import "SWADefinitions.h"
#import "CoreData/KPToDo.h"
#import "SWACoreDataModel.h"
#import "SWAUtility.h"
#import "GlanceController.h"

@interface GlanceController()

@property (nonatomic, weak) IBOutlet WKInterfaceLabel* taskStatus;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel* taskStatus2;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel* taskText;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel* taskText2;
@property (nonatomic, weak) IBOutlet WKInterfaceImage* noTasksImage;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel* subtaskLabel1;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup* subtaskGroup1;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel* subtaskLabel2;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup* subtaskGroup2;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel* subtaskLabel3;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup* subtaskGroup3;

@end


@implementation GlanceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate
{
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self reloadData];
}

- (void)loadTodo:(KPToDo *)todo isScheduled:(BOOL)isScheduled
{
    BOOL hasSubtasks = (0 < todo.subtasks.count);
    [_taskText setHidden:isScheduled || (!hasSubtasks)];
    [_taskText2 setHidden:isScheduled || hasSubtasks];
    [_taskStatus setHidden:!hasSubtasks];
    [_taskStatus2 setHidden:hasSubtasks];
    [_noTasksImage setHidden:!isScheduled];
    WKInterfaceLabel* nextLabel = hasSubtasks ? _taskStatus : _taskStatus2;
    
    if (hasSubtasks) {
        [_taskText setText:todo.title];
        NSArray* subtasks;
        NSPredicate *uncompletedPredicate = [NSPredicate predicateWithFormat:@"completionDate == nil"];
        NSSortDescriptor *orderedItemsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        subtasks = [[todo.subtasks filteredSetUsingPredicate:uncompletedPredicate] sortedArrayUsingDescriptors:@[orderedItemsSortDescriptor]];
        if (1 <= subtasks.count) {
            [_subtaskGroup1 setHidden:NO];
            [_subtaskLabel1 setText:((KPToDo *)subtasks[0]).title];
            if (2 <= subtasks.count) {
                [_subtaskGroup2 setHidden:NO];
                [_subtaskLabel2 setText:((KPToDo *)subtasks[1]).title];
                if (3 <= subtasks.count) {
                    [_subtaskGroup3 setHidden:NO];
                    [_subtaskLabel3 setText:((KPToDo *)subtasks[2]).title];
                }
            }
        }
    }
    else {
        [_taskText2 setText:todo.title];
    }
    [self updateUserActivity:@"com.swipes.open.todo" userInfo:@{kKeyCmdGlance: todo.tempId} webpageURL:nil];
    
    if (isScheduled) {
        if (todo.schedule) {
            [nextLabel setText:[NSString stringWithFormat:@"%@\n%@", LOCALIZE_STRING(@"NEXT TASK"), [[SWAUtility readableTime:todo.schedule] uppercaseString]]];
        }
        else {
            [nextLabel setText:LOCALIZE_STRING(@"NEXT TASK")];
        }
        [nextLabel setTextColor:LATER_COLOR];
    }
    else {
        [nextLabel setText:LOCALIZE_STRING(@"CURRENT TASK")];
        [nextLabel setTextColor:TASKS_COLOR];
    }
}

- (void)reloadData
{
    NSError* error;
    NSArray* todos = [[SWACoreDataModel sharedInstance] loadTodosWithError:&error oneResult:YES];
    if (error) {
        [SWAUtility sendErrorToHost:error];
    }
    if (todos.count > 0) {
        KPToDo* todo = todos[0];
        [self loadTodo:todo isScheduled:NO];
    }
    else {
        KPToDo* todo = [[SWACoreDataModel sharedInstance] loadScheduledTodoWithError:&error];
        if (todo) {
            [self loadTodo:todo isScheduled:YES];
        }
        else {
            // TODO have design for that
            [_taskText setText:NSLocalizedString(@"No data", nil)];
        }
    }
}

- (void)didDeactivate
{
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



