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

@end


@implementation TodayInterfaceController

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

- (void)reloadData
{
    NSError* error;
    DLog(@"Reloading data");
    _todos = [[SWACoreDataModel sharedInstance] loadTodosWithError:&error oneResult:NO];
    [self fillData];
}

- (void)fillData
{
    BOOL hasTodos = _todos.count > 0;
    [self.noDataImage setHidden:hasTodos];
    [self.refreshButton setHidden:hasTodos];
    [self.group setBackgroundColor:hasTodos ? [UIColor blackColor] : TASKS_COLOR];
    [self.table setNumberOfRows:_todos.count withRowType:ROW_TYPE_NAME];
    for (NSUInteger i = 0; i < _todos.count; i++) {
        SWATodoCell* cell = [self.table rowControllerAtIndex:i];
        KPToDo* todo = _todos[i];
        [cell.group setBackgroundColor:TASKS_COLOR];
        [cell.label setText:todo.title];
        [cell.label setTextColor:TEXT_COLOR];
    }
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
    return _todos[rowIndex];
}

@end



