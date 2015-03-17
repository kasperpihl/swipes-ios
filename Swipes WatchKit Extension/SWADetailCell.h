//
//  SWADetailCell.h
//  Swipes
//
//  Created by demosten on 3/3/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

@import WatchKit;
#import <Foundation/Foundation.h>

@interface SWADetailCell : NSObject

@property (nonatomic, weak) IBOutlet WKInterfaceLabel* label;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel* tags;

@end
