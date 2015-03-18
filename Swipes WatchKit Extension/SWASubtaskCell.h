//
//  SWASubtaskCell.h
//  Swipes
//
//  Created by demosten on 3/3/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

@import WatchKit;
#import <Foundation/Foundation.h>
#import "CoreData/KPToDo.h"

@protocol SWASubtaskCellDelegate <NSObject>

- (void)onCompleteButtonTouch:(KPToDo *)todo checked:(BOOL)checked;

@end

@interface SWASubtaskCell : NSObject

@property (nonatomic, weak) IBOutlet WKInterfaceLabel* label;
@property (nonatomic, weak) IBOutlet WKInterfaceButton* button;
@property (nonatomic, weak) id<SWASubtaskCellDelegate> delegate;
@property (nonatomic, strong) KPToDo* todo;
@property (nonatomic, readonly, assign) BOOL checked;

@end
