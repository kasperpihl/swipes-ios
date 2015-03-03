//
//  TodoInterfaceController.m
//  Swipes
//
//  Created by demosten on 2/22/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "SWAIncludes.h"
#import "SWADefinitions.h"
#import "CoreData/KPToDo.h"
#import "SWACoreDataModel.h"
#import "TodoInterfaceController.h"

@interface TodoInterfaceController()

@property (nonatomic, strong) KPToDo* todo;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel* titleLabel;

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
    [WKInterfaceController openParentApplication:@{kKeyCmdComplete: _todo.tempId} reply:^(NSDictionary *replyInfo, NSError *error) {
        if (error) {
            
        }
        [self popController];
    }];
}

- (IBAction)onDelete:(id)sender
{
    [WKInterfaceController openParentApplication:@{kKeyCmdDelete: _todo.tempId} reply:^(NSDictionary *replyInfo, NSError *error) {
        if (error) {
            
        }
        [self popController];
    }];
}

- (IBAction)onSchedule:(id)sender
{
    NSLog(@"Schedule");
    //[self popController];
    [self pushControllerWithName:@"Schedule" context:_todo];
}

@end
