//
//  Swipes WatchKit Extension
//
//  Created by demosten on 12/25/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "DoneInterfaceController.h"


@interface DoneInterfaceController()

@end


@implementation DoneInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
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
    return SWAPageDone;
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    [super table:table didSelectRowAtIndex:rowIndex];
    [self updateMenuItems];
}

- (void)updateMenuItems {
    [self clearAllMenuItems];
    
    // add items if there is anything selected
    if (self.selected.count > 0) {
        [self addMenuItemWithItemIcon:WKMenuItemIconPlay title:NSLocalizedString(@"Today", nil) action:@selector(onToday:)];
        [self addMenuItemWithItemIcon:WKMenuItemIconDecline title:NSLocalizedString(@"Delete", nil) action:@selector(onDelete:)];
        [self addMenuItemWithItemIcon:WKMenuItemIconMore title:NSLocalizedString(@"Back", nil) action:@selector(onBack:)];
    }
}

- (void)onToday:(id)sender {
    NSLog(@"Marking as done");
    for (KPToDo* todo in self.selected) {
        [todo complete];
    }
    [[SWACoreDataModel sharedInstance] saveContext];
    [self reloadData];
}

- (void)onDelete:(id)sender {
    [super onDelete:nil];
}

- (void)onBack:(id)sender {
    NSLog(@"Back");
}

@end



