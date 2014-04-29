//
//  SubtaskController.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 29/04/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KPToDo.h"
#import "KPReorderTableView.h"
#define kSubtaskHeight 36
@interface SubtaskController : NSObject
@property (nonatomic) KPToDo *model;
@property KPReorderTableView *tableView;
@end
