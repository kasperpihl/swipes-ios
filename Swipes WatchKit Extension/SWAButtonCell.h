//
//  SWAButtonCell.h
//  Swipes
//
//  Created by demosten on 3/3/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

@import WatchKit;
#import <Foundation/Foundation.h>

@protocol SWAButtonCellDelegate <NSObject>

- (void)onButton1Touch;

@optional

- (void)onButton2Touch;

@end


@interface SWAButtonCell : NSObject

@property (nonatomic, weak) IBOutlet WKInterfaceButton* button1;
@property (nonatomic, weak) IBOutlet WKInterfaceButton* button2;

@property (nonatomic, weak) id<SWAButtonCellDelegate> delegate;

@end
