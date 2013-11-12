//
//  AddPanelView.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 20/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AddPanelView;
@protocol AddPanelDelegate
-(void)closeAddPanel:(AddPanelView*)addPanel;
@optional
-(void)didAddItem:(NSString*)item priority:(BOOL)priority;
@end
@interface AddPanelView : UIView
@property (nonatomic,weak) NSObject<AddPanelDelegate> *addDelegate;
@end
