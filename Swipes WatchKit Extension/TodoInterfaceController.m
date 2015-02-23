//
//  TodoInterfaceController.m
//  Swipes
//
//  Created by demosten on 2/22/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "CoreData/KPToDo.h"
#import "SWACoreDataModel.h"
#import "SWAIncludes.h"
#import "TodoInterfaceController.h"


@interface TodoInterfaceController()

@property (nonatomic, strong) KPToDo* todo;
@property (nonatomic, strong) IBOutlet WKInterfaceLabel* titleLabel;

@end


@implementation TodoInterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    _todo = context;
    [_titleLabel setText:_todo.title];
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

- (IBAction)onMarkDone:(id)sender
{
    NSLog(@"Marking as done");
    [_todo complete];
    [[SWACoreDataModel sharedInstance] saveContext];
    [self popController];
}

- (IBAction)onDelete:(id)sender
{
    // TODO this deletion does not work properly
    NSLog(@"Delete");
    SWACoreDataModel* dataModel = [SWACoreDataModel sharedInstance];
    [dataModel deleteObject:_todo];
    [self popController];
}

- (IBAction)onSchedule:(id)sender
{
    NSLog(@"Schedule");
    [self popController];
}

@end



