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

NSString * const ROW_TYPE_NAME = @"SWATodoCell";

@interface TodayInterfaceController()

@property (nonatomic, weak) IBOutlet WKInterfaceTable* table;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel* noDataLabel;

@property (nonatomic, readonly, strong) NSArray* todos;

@end


@implementation TodayInterfaceController

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

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
    [self updateMenuItems];
}

- (void)updateMenuItems
{
    [self clearAllMenuItems];
    
    // add items if there is anything selected
//    if (self.selected.count > 0) {
//        [self addMenuItemWithItemIcon:WKMenuItemIconAccept title:NSLocalizedString(@"Complete", nil) action:@selector(onMarkAsDone:)];
//        [self addMenuItemWithItemIcon:WKMenuItemIconPause title:NSLocalizedString(@"Schedule", nil) action:@selector(onSchedule:)];
//        [self addMenuItemWithItemIcon:WKMenuItemIconDecline title:NSLocalizedString(@"Delete", nil) action:@selector(onDelete:)];
//        [self addMenuItemWithItemIcon:WKMenuItemIconMore title:NSLocalizedString(@"Back", nil) action:@selector(onBack:)];
//    }
}

- (void)onMarkAsDone:(id)sender
{

}

- (void)onSchedule:(id)sender
{
}

- (void)onDelete:(id)sender
{

}

- (void)onBack:(id)sender
{
    NSLog(@"Back");
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier
                            inTable:(WKInterfaceTable *)table
                           rowIndex:(NSInteger)rowIndex
{
    return _todos[rowIndex];
}

@end



