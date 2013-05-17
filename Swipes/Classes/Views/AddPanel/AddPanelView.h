//
//  AddPanelView.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 20/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPPickerView.h"
@class AddPanelView;
@protocol AddPanelDelegate
-(void)closeAddPanel:(AddPanelView*)addPanel;
@optional
-(void)didAddItem:(NSString*)item;
@end
@interface AddPanelView : UIView
@property (nonatomic,weak) NSObject<AddPanelDelegate> *addDelegate;
@property (nonatomic,weak) NSObject<KPPickerViewDataSource> *forwardDatasource;
-(void)show:(BOOL)show;

@end
