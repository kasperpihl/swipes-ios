//
//  AddPanelView.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 20/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "UAModalPanel.h"
@protocol AddPanelDelegate
@optional
-(void)didAddItem:(NSString*)item;
@end
@interface AddPanelView : UAModalPanel
@property (nonatomic,weak) NSObject<AddPanelDelegate> *addDelegate;
@end
