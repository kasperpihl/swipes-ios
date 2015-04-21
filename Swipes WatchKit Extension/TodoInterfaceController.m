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
#import "SWAButtonCell.h"
#import "SWACoreDataModel.h"
#import "TodoInterfaceController.h"

static NSInteger const kTotalRows = 1;
static NSString* const kEvernoteIntegrationIconFull = @"integrationEvernoteFull";
static NSString* const kMailIntegrationIconFull = @"integrationMailFull";

@interface TodoInterfaceController() <SWASubtaskCellDelegate, SWAButtonCellDelegate>

@property (nonatomic, weak) IBOutlet WKInterfaceTable* table;
@property (nonatomic, strong) KPToDo* todo;
@property (nonatomic, strong) id context;
@property (nonatomic, strong) NSMutableSet* todosToCheck;
@property (nonatomic, assign) BOOL shouldReload;

@end


@implementation TodoInterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    _context = context;
    _shouldReload = YES;
}

- (void)willActivate
{
    [super willActivate];
    if (_shouldReload) {
        NSError* error;
        _todo = [[SWACoreDataModel sharedInstance] loadTodoWithTempId:_context error:&error];
        if (error) {
            [SWAUtility sendErrorToHost:error];
        }
        DLog(@"TODO is: %@", _todo);
        _todosToCheck = [NSMutableSet set];
        [self reloadData];
    }
}

- (void)didDeactivate
{
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    if (0 < _todosToCheck.count) {
        NSDictionary* data = @{kKeyCmdComplete: [_todosToCheck allObjects]};
        [WKInterfaceController openParentApplication:data reply:^(NSDictionary *replyInfo, NSError *error) {
            if (error) {
                [SWAUtility sendErrorToHost:error];
                DLog(@"Error didDeactivate %@", error);
            }
        }];
        _shouldReload = YES;
    }
}

- (void)reloadData
{
    // gather data about rows
    NSInteger totalRows = kTotalRows;
    BOOL hasTags = NO;
    if (_todo.tags.count || _todo.attachments.count) {
        hasTags = YES;
    }
    NSArray* subtasks = [SWAUtility nonCompletedSubtasks:_todo.subtasks];
    if (0 < subtasks.count) {
        totalRows += subtasks.count;
    }

    // create rows
    NSMutableArray* rowTypes = @[@"SWADetailCell"].mutableCopy;
    for (NSUInteger i = kTotalRows; i < totalRows; i++) {
        [rowTypes addObject:@"SWASubtaskCell"];
    }
    [rowTypes addObject:@"SWAButtonCell"];
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
            [str appendString:NSLocalizedString(@"(no tags)", nil)];
        }
        
        if (_todo.attachments && _todo.attachments.count) {
            [str insertString:@" " atIndex:0];
        }
        
        NSUInteger index = 0;
        for (KPAttachment* attachment in _todo.attachments) {
            if ([attachment.service isEqualToString:EVERNOTE_SERVICE]) {
                [str insertString:kEvernoteIntegrationIconFull atIndex:0]; // put evernote first
                index += kEvernoteIntegrationIconFull.length;
            }
            else if ([attachment.service isEqualToString:GMAIL_SERVICE]) {
                [str insertString:kMailIntegrationIconFull atIndex:index];
                index += kMailIntegrationIconFull.length;
            }
        }
        
        // set attributes
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        UIFont *swipesFont = iconFont(10);
        NSRange iconsRange = NSMakeRange(0, index);
        [attributedString addAttribute:NSFontAttributeName value:swipesFont range:iconsRange];
        [attributedString addAttribute:NSKernAttributeName value:@(1.5) range:iconsRange];
        [cell.tags setAttributedText:attributedString];
    }
    else {
        [cell.tags setHidden:YES];
    }

    // add subtasks
    if (0 < subtasks.count) {
        NSUInteger index = kTotalRows;
        for (KPToDo* todo in subtasks) {
            SWASubtaskCell* subtaskCell = [self.table rowControllerAtIndex:index++];
            subtaskCell.todo = todo;
            subtaskCell.delegate = self;
            [subtaskCell.label setText:todo.title];
        }
    }
    
    // buttons
    SWAButtonCell* buttonCell = [self.table rowControllerAtIndex:rowTypes.count - 1];
    buttonCell.delegate = self;
    
    _shouldReload = NO;
}

- (IBAction)onMarkDone:(id)sender
{
    [WKInterfaceController openParentApplication:@{kKeyCmdComplete: _todo.tempId} reply:^(NSDictionary *replyInfo, NSError *error) {
        if (error) {
            [SWAUtility sendErrorToHost:error];
            DLog(@"Error onMarkDone %@", error);
        }
        [self popController];
    }];
}

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

- (void)onButton1Touch
{
    [self onSchedule:nil];
}

- (void)onButton2Touch
{
    [self onMarkDone:nil];
}

@end
