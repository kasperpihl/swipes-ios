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
#import "SWATwoLineCell.h"
#import "SWACoreDataModel.h"
#import "TodoInterfaceController.h"

static NSString* const kCellIdentifier = @"SWATwoLineCell";
static NSString* const EVERNOTE_SERVICE = @"evernote";
static NSString* const GMAIL_SERVICE = @"gmail";

static NSInteger const kTotalRows = 1;

@interface TodoInterfaceController()

@property (nonatomic, strong) KPToDo* todo;

@property (nonatomic, weak) IBOutlet WKInterfaceTable* table;

@end


@implementation TodoInterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    _todo = context;
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
}

- (NSAttributedString *)stringForSubtask:(KPToDo *)todo
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"\ue654 %@", todo.title]];
    UIFont* swipesFont = iconFont(10);
    UIColor* cyrcleColor = todo.completionDate ? DONE_COLOR : TASKS_COLOR;
    [attributedString addAttribute:NSFontAttributeName value:swipesFont range:NSMakeRange(0, 1)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:cyrcleColor range:NSMakeRange(0,1)];
    return attributedString;
}

- (void)reloadData
{
    NSInteger totalRows = kTotalRows;
    BOOL hasTags = NO;
    if (_todo.tags.count || _todo.attachments.count) {
        hasTags = YES;
        totalRows++;
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

    [self.table setNumberOfRows:totalRows withRowType:kCellIdentifier];
    SWATwoLineCell* cell = [self.table rowControllerAtIndex:0];
    [cell.label setText:_todo.title];

    if (0 < subtasks.count) {
        NSUInteger index = 1;
        for (KPToDo* todo in subtasks) {
            cell = [self.table rowControllerAtIndex:index++];
            [cell.label setAttributedText:[self stringForSubtask:todo]];
        }
    }
    
    if (hasTags) {
        cell = [self.table rowControllerAtIndex:totalRows - 1];
        NSMutableString* str = [[NSMutableString alloc] init];
        for (KPTag* tag in _todo.tags) {
            if (str.length) {
                [str appendString:@","];
            }
            [str appendString:tag.title];
        }
        [str insertString:@"\ue60b " atIndex:0];
        NSUInteger index = 0;
        for (KPAttachment* attachment in _todo.attachments) {
            if ([attachment.service isEqualToString:EVERNOTE_SERVICE]) {
                [str insertString:@"\ue65c" atIndex:index++];
            }
            else if ([attachment.service isEqualToString:GMAIL_SERVICE]) {
                [str insertString:@"\ue606" atIndex:index++];
            }
        }
        index++;
        
        // set attributes
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString: str];
        UIFont *swipesFont = iconFont(10);
        [attributedString addAttribute:NSFontAttributeName value:swipesFont range:NSMakeRange(0,index)];
        
        [cell.label setAttributedText:attributedString];
    }
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
