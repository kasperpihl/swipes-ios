//
//  KPToolbar.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 22/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    ToolbarButton1 = 0,
    ToolbarButton2,
    ToolbarButton3,
    ToolbarButton4,
} ToolbarButtons;
@class KPToolbar;
@protocol ToolbarDelegate
-(void)toolbar:(KPToolbar*)toolbar pressedItem:(NSInteger)item;
@end
@interface KPToolbar : UIView
@property (nonatomic, readonly) IBOutletCollection(UIButton) NSArray *barButtons;
@property (nonatomic,weak) NSObject<ToolbarDelegate> *delegate;
@property (nonatomic) UIColor *seperatorColor;
@property (nonatomic) UIColor *highlightedColor;
@property (nonatomic) CGFloat seperatorHeight;
@property (nonatomic) NSArray *items;
-(id)initWithFrame:(CGRect)frame items:(NSArray*)items;
@end
