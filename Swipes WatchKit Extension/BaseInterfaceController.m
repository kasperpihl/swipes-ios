//
//  BaseInterfaceController.m
//  Swipes
//
//  Created by demosten on 12/25/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "CoreData/KPToDo.h"
#import "BaseInterfaceController.h"

NSString * const ROW_TYPE_NAME = @"SWATodoCell";

@interface BaseInterfaceController()

@property (nonatomic, weak) IBOutlet WKInterfaceTable* table;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel* noDataLabel;

@end


@implementation BaseInterfaceController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _selected = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];

    [self reloadData];
//    NSLog(@"printing type %lu", self.page);
//    for (KPToDo* todo in _todos) {
//        NSLog(@"%@", todo);
//    }
//    int i = 5;
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    NSLog(@"Selected index: %lu", rowIndex);
    SWATodoCell* cell = [self.table rowControllerAtIndex:rowIndex];
    KPToDo* todo = _todos[rowIndex];
    if ([_selected containsObject:todo]) {
        [_selected removeObject:todo];
        [cell.group setBackgroundColor:[UIColor clearColor]];
    }
    else {
        [_selected addObject:todo];
        [cell.group setBackgroundColor:[UIColor yellowColor]];
    }
}

- (void)reloadData {
    NSError* error;
    _todos = [[SWACoreDataModel sharedInstance] loadTodosForPage:self.page withError:&error oneResult:NO];
    [self fillData];
}

- (void)fillData {
    [self.noDataLabel setHidden:_todos.count > 0];
    [self.table setNumberOfRows:_todos.count withRowType:ROW_TYPE_NAME];
    for (NSUInteger i = 0; i < _todos.count; i++) {
        SWATodoCell* cell = [self.table rowControllerAtIndex:i];
        KPToDo* todo = _todos[i];
        [cell.label setText:todo.title];
        if ([_selected containsObject:todo]) {
            [cell.group setBackgroundColor:[UIColor yellowColor]];
        }
        else {
            [cell.group setBackgroundColor:[UIColor clearColor]];
        }
    }
    
    // clear unknown selected todos
    for (KPToDo* todo in _selected) {
        if (![_todos containsObject:todo]) {
            [_selected removeObject:todo];
        }
    }
}

- (void)onDelete:(id)sender {
    // TODO this deletion might not be enough
    NSLog(@"Delete");
    SWACoreDataModel* dataModel = [SWACoreDataModel sharedInstance];
    for (KPToDo* todo in self.selected) {
        [dataModel deleteObject:todo];
    }
    [self reloadData];
}

@end



