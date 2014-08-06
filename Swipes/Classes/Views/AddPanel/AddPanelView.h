//
//  AddPanelView.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 20/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AddPanelView;

@protocol AddPanelDelegate <NSObject>
-(void)closeAddPanel:(AddPanelView*)addPanel;
@optional
-(void)didAddItem:(NSString*)item priority:(BOOL)priority tags:(NSArray *)tags;
@end

@interface AddPanelView : UIView

@property (nonatomic,weak) id<AddPanelDelegate> addDelegate;
@property (nonatomic, strong) NSArray *tags;

@end
