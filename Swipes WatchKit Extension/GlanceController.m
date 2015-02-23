//
//  GlanceController.m
//  Swipes WatchKit Extension
//
//  Created by demosten on 12/25/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "CoreData/KPToDo.h"
#import "SWACoreDataModel.h"
#import "GlanceController.h"


@interface GlanceController()

@property (nonatomic, weak) IBOutlet WKInterfaceLabel* taskText;

@end


@implementation GlanceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    NSError* error;
    NSArray* todos = [[SWACoreDataModel sharedInstance] loadTodosWithError:&error oneResult:YES];
    if (todos.count > 0) {
        KPToDo* todo = todos[0];
        [_taskText setText:todo.title];
    }
    else {
        [_taskText setText:NSLocalizedString(@"No data", nil)];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



