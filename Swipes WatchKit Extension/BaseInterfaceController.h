//
//  BaseInterfaceController.h
//  Swipes
//
//  Created by demosten on 12/25/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "SWACoreDataModel.h"
#import "SWAIncludes.h"
#import "SWATodoCell.h"

@interface BaseInterfaceController : WKInterfaceController

@property (nonatomic, assign) SWAPage page;
@property (nonatomic, readonly, strong) NSArray* todos;
@property (nonatomic, readonly, strong) NSMutableSet* selected;

- (void)reloadData;
- (void)onDelete:(id)sender;

@end
