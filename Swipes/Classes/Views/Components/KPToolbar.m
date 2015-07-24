//
//  KPToolbar.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 22/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#import "KPToolbar.h"
#import "UtilityClass.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Utilities.h"
#import "SlowHighlightIcon.h"
#define SEP_WIDTH 0.5
#define kDEF_SEP_COLOR [UIColor whiteColor]
#define kDEF_BACK_COLOR CLEAR
@interface KPToolbar ()

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *barButtons;
@property (nonatomic, strong) CALayer *colorLayer;
@property (nonatomic, assign) NSInteger numberOfButtons;

@end

@implementation KPToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kDEF_BACK_COLOR;
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame items:(NSArray *)items delegate:(NSObject<ToolbarDelegate> *)delegate
{
    self = [self initWithFrame:frame];
    if(self){
        if (delegate)
            self.delegate = delegate;
        self.items = items;
    }
    return self;
}

-(void)setItems:(NSArray *)items
{
    if (_items != items) {
        _items = items;
        self.numberOfButtons = items.count;
        for (UIButton *button in self.barButtons) {
            [button removeFromSuperview];
        }
        
        NSMutableArray *barButtons = [NSMutableArray arrayWithCapacity:self.numberOfButtons];
        NSInteger buttonCounter = 0;
        for (id item in items){
            NSString *itemString;
            UIImage *itemImage;
            UIImage *highlightImage;
            if ([item isKindOfClass:[NSString class]]){
                if (!self.font){
                    itemImage = [UIImage imageNamed:(NSString*)item];
                    highlightImage = [UIImage imageNamed:(NSString*)[item stringByAppendingString:@"-high"]];
                }
                else itemString = item;
            }
            else if ([item isKindOfClass:[UIImage class]] && !self.font)
                itemImage = (UIImage*)item;
            else{
                DLog(@"only strings and uiimages as items");
                return;
            }
            UIButton *button = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
            
            if(!self.font){
                CIImage *cim = [highlightImage CIImage];
                CGImageRef cgref = [highlightImage CGImage];
                [button setImage:itemImage forState:UIControlStateNormal];
                if (cim != nil || cgref != NULL)
                {
                    [button setImage:highlightImage forState:UIControlStateHighlighted];
                }
            }
            else{
                
                button.titleLabel.font = self.font;
                [button setTitle:iconString(itemString) forState:UIControlStateNormal];
                if(self.titleHighlightString){
                    NSString *highItemString = [NSString stringWithFormat:@"%@%@",itemString,self.titleHighlightString];
                    [button setTitle:iconString(highItemString) forState:UIControlStateHighlighted];
                }
                if(self.titleColor)
                    [button setTitleColor:self.titleColor forState:UIControlStateNormal];
                
            }
            
            button.frame = [self frameForButtonNumber:buttonCounter];
            button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [button addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
            if ([self.delegate respondsToSelector:@selector(toolbar:editButton:forItem:)]) {
                [self.delegate toolbar:self editButton:&button forItem:buttonCounter];
            }
            [barButtons addObject:button];
            [self addSubview:button];
            buttonCounter++;
        }
        self.barButtons = [barButtons copy];
        
    }
}

-(void)setTopInset:(CGFloat)topInset
{
    if (topInset != _topInset){
        _topInset = topInset;
        for (UIButton *button in self.barButtons) {
            button.imageEdgeInsets = UIEdgeInsetsMake(topInset, 0, 0, 0);
        }
    }
}

-(void)clickedButton:(UIButton*)sender
{
    NSInteger pressedButton = [self.barButtons indexOfObject:sender];
    if(pressedButton != NSNotFound && [self.delegate respondsToSelector:@selector(toolbar:pressedItem:)])
        [self.delegate toolbar:self pressedItem:[self.barButtons indexOfObject:sender]];
}

-(CGRect)frameForButtonNumber:(NSInteger)number
{
    CGFloat buttonWidth = self.frame.size.width / self.numberOfButtons;
    CGFloat buttonHeight = self.frame.size.height;
    CGFloat x = buttonWidth * number;
    return CGRectMake(x, 0, buttonWidth, buttonHeight);
}

// NEWCODE
- (void)layoutSubviews
{
    [super layoutSubviews];
    NSInteger buttonCounter = 0;
    for (UIButton* button in self.barButtons) {
        button.frame = [self frameForButtonNumber:buttonCounter];
        buttonCounter++;
    }
}

@end
