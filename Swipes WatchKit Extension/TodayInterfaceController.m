//
//  Swipes WatchKit Extension
//
//  Created by demosten on 12/25/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "SWADefinitions.h"
#import "TodayInterfaceController.h"
#import "CoreData/KPToDo.h"
#import "SWACoreDataModel.h"
#import "SWAIncludes.h"
#import "SWATodoCell.h"

static NSString * const ROW_TYPE_NAME = @"SWATodoCell";

@interface TodayInterfaceController()

@property (nonatomic, weak) IBOutlet WKInterfaceTable* table;
@property (nonatomic, weak) IBOutlet WKInterfaceButton* refreshButton;
@property (nonatomic, weak) IBOutlet WKInterfaceImage* noDataImage;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup* group;

@property (nonatomic, readonly, strong) NSArray* todos;
@property (nonatomic, readonly, strong) NSMutableArray* todoTempIds;

@end


@implementation TodayInterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    _todoTempIds = [NSMutableArray array];
}

- (void)willActivate
{
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self reloadData];
}

- (void)didDeactivate
{
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)handleUserActivity:(NSDictionary *)userInfo
{
    DLog(@"user info: %@", userInfo);
    NSString* tempId = userInfo[kKeyCmdGlance];
    if (tempId) {
        NSError* error;
        KPToDo* todo = [[SWACoreDataModel sharedInstance] loadTodoWithTempId:tempId error:&error];
        DLog(@"found todo: %@", todo);
        if (todo) {
            [self pushControllerWithName:@"details" context:tempId];
        }
    }
}

- (BOOL)areDifferentArrays:(NSArray *)newTodos
{
    for (NSUInteger i = 0; i < newTodos.count; i++) {
        if (![((KPToDo *)newTodos[i]).tempId isEqualToString:_todoTempIds[i]]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)reloadData
{
    NSError* error;
//    DLog(@"Reloading data");
    NSArray* newTodos = [[SWACoreDataModel sharedInstance] loadTodosWithError:&error oneResult:NO];
    if (newTodos.count != _todos.count || [self areDifferentArrays:newTodos]) {
        _todos = newTodos;
        [self fillData];
    }
    else {
        _todos = newTodos;
    }
}

- (void)fillData
{
    BOOL hasTodos = _todos.count > 0;
    [_todoTempIds removeAllObjects];
    [self.table setHidden:YES];
    [self.group setHidden:hasTodos];
    [self.table setNumberOfRows:_todos.count withRowType:ROW_TYPE_NAME];
    for (NSUInteger i = 0; i < _todos.count; i++) {
        SWATodoCell* cell = [self.table rowControllerAtIndex:i];
        KPToDo* todo = _todos[i];
        [cell.group setBackgroundColor:TASKS_COLOR];
        [cell.label setText:todo.title];
        [cell.label setTextColor:TEXT_COLOR];
        [_todoTempIds addObject:todo.tempId];
        DLog(@"TODO: %@: %@", todo.title, todo.tempId);
    }
    [self.table setHidden:NO];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    [super table:table didSelectRowAtIndex:rowIndex];
}

- (IBAction)onRefreshButton:(id)sender
{
    [self reloadData];
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier
                            inTable:(WKInterfaceTable *)table
                           rowIndex:(NSInteger)rowIndex
{
    return ((KPToDo *)_todos[rowIndex]).tempId;
}

@end



