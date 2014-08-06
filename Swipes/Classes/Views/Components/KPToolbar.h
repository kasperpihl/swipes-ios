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

@protocol ToolbarDelegate <NSObject>
-(void)toolbar:(KPToolbar*)toolbar pressedItem:(NSInteger)item;
@optional
-(void)toolbar:(KPToolbar*)toolbar editButton:(UIButton **)button forItem:(NSInteger)item;
@end

@interface KPToolbar : UIView

@property (nonatomic, readonly) IBOutletCollection(UIButton) NSArray *barButtons;
@property (nonatomic, weak) id<ToolbarDelegate> delegate;
@property (nonatomic, strong) UIColor *highlightedColor;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) CGFloat topInset;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) NSString *titleHighlightString;

-(id)initWithFrame:(CGRect)frame items:(NSArray*)items delegate:(NSObject<ToolbarDelegate>*)delegate;

@end
