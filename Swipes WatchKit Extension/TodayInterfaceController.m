//
//  Swipes WatchKit Extension
//
//  Created by demosten on 12/25/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "CoreData/KPToDo.h"
#import "TodayInterfaceController.h"


@interface TodayInterfaceController()

@end


@implementation TodayInterfaceController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self becomeCurrentPage];
    }
    return self;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (SWAPage)page {
    return SWAPageToday;
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    [super table:table didSelectRowAtIndex:rowIndex];
    [self updateMenuItems];
}

- (void)updateMenuItems {
    [self clearAllMenuItems];
    
    // add items if there is anything selected
    if (self.selected.count > 0) {
        [self addMenuItemWithItemIcon:WKMenuItemIconAccept title:NSLocalizedString(@"Complete", nil) action:@selector(onMarkAsDone:)];
        [self addMenuItemWithItemIcon:WKMenuItemIconPause title:NSLocalizedString(@"Schedule", nil) action:@selector(onSchedule:)];
        [self addMenuItemWithItemIcon:WKMenuItemIconDecline title:NSLocalizedString(@"Delete", nil) action:@selector(onDelete:)];
        [self addMenuItemWithItemIcon:WKMenuItemIconMore title:NSLocalizedString(@"Back", nil) action:@selector(onBack:)];
    }
}

- (void)onMarkAsDone:(id)sender {
    NSLog(@"Marking as done");
    for (KPToDo* todo in self.selected) {
        [todo complete];
    }
    [[SWACoreDataModel sharedInstance] saveContext];
    [self reloadData];
}

- (void)onSchedule:(id)sender {
    NSLog(@"Schedule");
    [self reloadData];
}

- (void)onDelete:(id)sender {
    [super onDelete:nil];
}

- (void)onBack:(id)sender {
    NSLog(@"Back");
}

@end



