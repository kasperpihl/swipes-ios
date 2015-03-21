//
//  TodoInterfaceController.m
//  Swipes
//
//  Created by demosten on 2/22/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "Global.h"
#import "SWAIncludes.h"
#import "SWADefinitions.h"
#import "CoreData/KPToDo.h"
#import "CoreData/KPTag.h"
#import "CoreData/KPAttachment.h"
#import "SWAUtility.h"
#import "SWASubtaskCell.h"
#import "SWADetailCell.h"
#import "SWACoreDataModel.h"
#import "TodoInterfaceController.h"

static NSInteger const kTotalRows = 1;

@interface TodoInterfaceController() <SWASubtaskCellDelegate>

@property (nonatomic, strong) KPToDo* todo;

@property (nonatomic, weak) IBOutlet WKInterfaceTable* table;
@property (nonatomic, strong) NSMutableSet* todosToCheck;

@end


@implementation TodoInterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    if ([context isKindOfClass:KPToDo.class])
        _todo = context;
    else {
        NSError* error;
        _todo = [[SWACoreDataModel sharedInstance] loadTodoWithTempId:context error:&error];
    }
    DLog(@"TODO is: %@", _todo);
    _todosToCheck = [NSMutableSet set];
    [self reloadData];
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
    if (0 < _todosToCheck.count) {
        NSDictionary* data = @{kKeyCmdComplete: [_todosToCheck allObjects]};
        [WKInterfaceController openParentApplication:data reply:^(NSDictionary *replyInfo, NSError *error) {
            if (error) {
                DLog(@"Error didDeactivate %@", error);
            }
        }];
    }
}

//- (NSAttributedString *)stringForSubtask:(KPToDo *)todo
//{
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"\ue654 %@", todo.title]];
//    UIFont* swipesFont = iconFont(10);
//    UIColor* cyrcleColor = todo.completionDate ? DONE_COLOR : TASKS_COLOR;
//    [attributedString addAttribute:NSFontAttributeName value:swipesFont range:NSMakeRange(0, 1)];
//    [attributedString addAttribute:NSForegroundColorAttributeName value:cyrcleColor range:NSMakeRange(0,1)];
//    return attributedString;
//}
//
- (void)reloadData
{
    // gather data about rows
    NSInteger totalRows = kTotalRows;
    BOOL hasTags = NO;
    if (_todo.tags.count || _todo.attachments.count) {
        hasTags = YES;
    }
    NSArray* subtasks;
    if (0 < _todo.subtasks.count) {
        NSPredicate *uncompletedPredicate = [NSPredicate predicateWithFormat:@"completionDate == nil"];
        NSSortDescriptor *orderedItemsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        subtasks = [[_todo.subtasks filteredSetUsingPredicate:uncompletedPredicate] sortedArrayUsingDescriptors:@[orderedItemsSortDescriptor]];
        if (0 < subtasks.count) {
            totalRows += subtasks.count;
        }
    }

    // create rows
    NSMutableArray* rowTypes = @[@"SWADetailCell"].mutableCopy;
    for (NSUInteger i = kTotalRows; i < totalRows; i++) {
        [rowTypes addObject:@"SWASubtaskCell"];
    }
    [self.table setRowTypes:rowTypes];

    // fill rows
    SWADetailCell* cell = [self.table rowControllerAtIndex:0];
    [cell.label setText:_todo.title];
    if (hasTags) {
        NSMutableString* str = [[NSMutableString alloc] init];
        if (_todo.tags.count) {
            for (KPTag* tag in _todo.tags) {
                if (str.length) {
                    [str appendString:@","];
                }
                [str appendString:tag.title];
            }
        }
        else {
            [str appendString:LOCALIZE_STRING(@"(no tags)")];
        }
        
        if (_todo.attachments && _todo.attachments.count) {
            [str insertString:@" " atIndex:0];
        }
        
        NSUInteger index = 0;
        for (KPAttachment* attachment in _todo.attachments) {
            if ([attachment.service isEqualToString:EVERNOTE_SERVICE]) {
                [str insertString:@"\ue64d" atIndex:index++];
            }
            else if ([attachment.service isEqualToString:GMAIL_SERVICE]) {
                [str insertString:@"\ue606" atIndex:index++];
            }
        }
        
        // set attributes
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:str];
        UIFont *swipesFont = iconFont(10);
        [attributedString addAttribute:NSFontAttributeName value:swipesFont range:NSMakeRange(0,index)];
        [cell.tags setAttributedText:attributedString];
    }
    else {
        [cell.tags setHidden:YES];
    }

    if (0 < subtasks.count) {
        NSUInteger index = kTotalRows;
        for (KPToDo* todo in subtasks) {
            SWASubtaskCell* subtaskCell = [self.table rowControllerAtIndex:index++];
            //[subtaskCell.button setTitle:@"\ue62c"];
            subtaskCell.todo = todo;
            subtaskCell.delegate = self;
            [subtaskCell.label setText:todo.title];
        }
    }
    
}

- (IBAction)onMarkDone:(id)sender
{
    [WKInterfaceController openParentApplication:@{kKeyCmdComplete: _todo.tempId} reply:^(NSDictionary *replyInfo, NSError *error) {
        if (error) {
            DLog(@"Error onMarkDone %@", error);
        }
        [self popController];
    }];
}

//- (IBAction)onDelete:(id)sender
//{
//    [WKInterfaceController openParentApplication:@{kKeyCmdDelete: _todo.tempId} reply:^(NSDictionary *replyInfo, NSError *error) {
//        if (error) {
//            
//        }
//        [self popController];
//    }];
//}
//
- (IBAction)onSchedule:(id)sender
{
    [self pushControllerWithName:@"Schedule" context:_todo];
}

- (void)onCompleteButtonTouch:(KPToDo *)todo checked:(BOOL)checked
{
    if (checked) {
        [_todosToCheck addObject:todo.tempId];
    }
    else {
        [_todosToCheck removeObject:todo.tempId];
    }
}

@end
