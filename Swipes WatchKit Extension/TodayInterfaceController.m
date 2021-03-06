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
#import "SWAButtonCell.h"
#import "Global.h"
#import "SWAUtility.h"

static NSString* const ROW_TYPE_NAME = @"SWATodoCell";
static NSString* const kNotFirstRun = @"AppleWatchNotFirstRun";
//static BOOL g_isNotFirstRun = NO;

@interface TodayInterfaceController() <SWAButtonCellDelegate>

@property (nonatomic, weak) IBOutlet WKInterfaceTable* table;
@property (nonatomic, weak) IBOutlet WKInterfaceButton* refreshButton;
@property (nonatomic, weak) IBOutlet WKInterfaceButton* noDataButton;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup* group;

@property (nonatomic, readonly, strong) NSArray* todos;
@property (nonatomic, readonly, strong) NSMutableArray* todoTempIds;

@end


@implementation TodayInterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    _todoTempIds = [NSMutableArray array];
    
//    g_isNotFirstRun = [USER_DEFAULTS boolForKey:kNotFirstRun];
//    if (!g_isNotFirstRun) {
//        [USER_DEFAULTS setBool:YES forKey:kNotFirstRun];
//        [USER_DEFAULTS synchronize];
//        [WKInterfaceController openParentApplication:@{kKeyCmdAnalytics: @{kKeyAnalyticsCategory: @"Onboarding", kKeyAnalyticsAction: @"Apple Watch Installation"}} reply:^(NSDictionary *replyInfo, NSError *error) {
//            if (error) {
//                [SWAUtility sendErrorToHost:error];
//                DLog(@"Error sending first run analytics %@", error);
//            }
//        }];
//    }
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
//    if ((nil == _todos) || (newTodos.count != _todos.count) || [self areDifferentArrays:newTodos]) {
        _todos = newTodos;
        [self fillData];
//    }
//    else {
//        _todos = newTodos;
//    }
}

- (void)fillData
{
    BOOL hasTodos = _todos.count > 0;
    [_todoTempIds removeAllObjects];
    [self.table setHidden:YES];
    [self.group setHidden:hasTodos];
    
    if (hasTodos) {
        // create rows
        NSMutableArray* rowTypes = [NSMutableArray array];
        for (NSUInteger i = 0; i < _todos.count; i++) {
            [rowTypes addObject:ROW_TYPE_NAME];
        }
        [rowTypes addObject:@"SWAButtonCell"];
        [self.table setRowTypes:rowTypes];
        
        for (NSUInteger i = 0; i < _todos.count; i++) {
            SWATodoCell* cell = [self.table rowControllerAtIndex:i];
            KPToDo* todo = _todos[i];
            [cell.group setBackgroundColor:TASKS_COLOR];
            [cell.label setText:todo.title];
            [cell.label setTextColor:TEXT_COLOR];
            if (nil == todo.tempId) {
                todo.tempId = [KPToDo generateIdWithLength:14];
            }
            [_todoTempIds addObject:todo.tempId];
            DLog(@"TODO: %@: %@", todo.title, todo.tempId);
        }

        // buttons
        SWAButtonCell* buttonCell = [self.table rowControllerAtIndex:rowTypes.count - 1];
        buttonCell.delegate = self;
        
        [self.table setHidden:NO];
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

- (IBAction)onButton1Touch
{
    [self presentTextInputControllerWithSuggestions:@[NSLocalizedString(@"Email a colleague", nil), NSLocalizedString(@"Meeting today", nil)]
                                   allowedInputMode:WKTextInputModePlain completion:^(NSArray *results) {
        DLog(@"Input: %@", results);
        if (results && 0 < results[0]) {
            [WKInterfaceController openParentApplication:@{kKeyCmdAdd: results[0]} reply:^(NSDictionary *replyInfo, NSError *error) {
                if (error) {
                    [SWAUtility sendErrorToHost:error];
                    DLog(@"Error adding task %@", error);
                }
                else {
                    [self reloadData];
                }
            }];
        }
    }];
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier
                            inTable:(WKInterfaceTable *)table
                           rowIndex:(NSInteger)rowIndex
{
    return ((KPToDo *)_todos[rowIndex]).tempId;
}

@end



