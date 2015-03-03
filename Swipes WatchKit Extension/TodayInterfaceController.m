//
//  Swipes WatchKit Extension
//
//  Created by demosten on 12/25/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "TodayInterfaceController.h"
#import "CoreData/KPToDo.h"
#import "SWACoreDataModel.h"
#import "SWAIncludes.h"
#import "SWATodoCell.h"

static NSString * const ROW_TYPE_NAME = @"SWATodoCell";

@interface TodayInterfaceController()

@property (nonatomic, weak) IBOutlet WKInterfaceTable* table;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel* noDataLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceButton* refreshButton;

@property (nonatomic, readonly, strong) NSArray* todos;

@end


@implementation TodayInterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
//    [self reloadData];
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

- (void)reloadData
{
    NSError* error;
    _todos = [[SWACoreDataModel sharedInstance] loadTodosWithError:&error oneResult:NO];
    [self fillData];
}

- (void)fillData
{
    [self.noDataLabel setHidden:_todos.count > 0];
    [self.refreshButton setHidden:_todos.count > 0];
    [self.table setNumberOfRows:_todos.count withRowType:ROW_TYPE_NAME];
    for (NSUInteger i = 0; i < _todos.count; i++) {
        SWATodoCell* cell = [self.table rowControllerAtIndex:i];
        KPToDo* todo = _todos[i];
        [cell.label setText:todo.title];
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



