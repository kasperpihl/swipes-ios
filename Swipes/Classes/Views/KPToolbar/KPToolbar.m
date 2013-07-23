//
//  KPToolbar.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 22/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#import "KPToolbar.h"
#import "UtilityClass.h"
#define SEP_WIDTH 0.5
#define kDEF_SEP_COLOR [UIColor whiteColor]
#define kDEF_BACK_COLOR [UIColor blackColor]
@interface KPToolbar ()
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *barButtons;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *seperators;
@property (nonatomic) NSInteger numberOfButtons;
@end
@implementation KPToolbar
-(id)initWithFrame:(CGRect)frame items:(NSArray *)items{
    self = [self initWithFrame:frame];
    if(self){
        self.items = items;
    }
    return self;
}
-(void)setItems:(NSArray *)items{
    if(_items != items){
        _items = items;
        self.numberOfButtons = items.count;
        for(UIButton *button in self.barButtons) [button removeFromSuperview];
        NSMutableArray *barButtons = [NSMutableArray arrayWithCapacity:self.numberOfButtons];
        NSInteger buttonCounter = 0;
        for(id item in items){
            UIImage *itemImage;
            if([item isKindOfClass:[NSString class]]) itemImage = [UIImage imageNamed:(NSString*)item];
            else if([item isKindOfClass:[UIImage class]]) itemImage = (UIImage*)item;
            else{
                NSLog(@"only strings and uiimages as items");
                return;
            }
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:itemImage forState:UIControlStateNormal];
            button.frame = [self frameForButtonNumber:buttonCounter];
            button.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
            [button addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
            [barButtons addObject:button];
            [self addSubview:button];
            buttonCounter++;
        }
        
        for(UIView *view in self.seperators) [view removeFromSuperview];
        CGFloat buttonWidth = (self.frame.size.width / self.numberOfButtons);
        CGFloat y = (self.frame.size.height - self.seperatorHeight)/2;
        NSMutableArray *seperators = [NSMutableArray arrayWithCapacity:self.numberOfButtons];
        for(NSInteger i = 1 ; i < self.numberOfButtons ; i++){
            
            CGFloat x = buttonWidth * i-(SEP_WIDTH/2);
            
            UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(x, y, SEP_WIDTH, self.seperatorHeight)];
            seperatorView.backgroundColor = self.seperatorColor;
            //[self addSubview:seperatorView];
            [seperators addObject:seperatorView];
        }
        self.seperators = [seperators copy];
        self.barButtons = [barButtons copy];
    }
}
-(void)setSeperatorColor:(UIColor *)seperatorColor{
    _seperatorColor = seperatorColor;
    for(UIView *seperator in self.seperators) seperator.backgroundColor = seperatorColor;
}
-(void)setSeperatorHeight:(CGFloat)seperatorHeight{
    _seperatorHeight = seperatorHeight;
    for(UIView *seperator in self.seperators){
        CGRectSetHeight(seperator, seperatorHeight);
        CGRectSetY(seperator, (self.frame.size.height-seperatorHeight)/2);
    }
}
-(void)clickedButton:(UIButton*)sender{
    NSInteger pressedButton = [self.barButtons indexOfObject:sender];
    if(pressedButton != NSNotFound && [self.delegate respondsToSelector:@selector(toolbar:pressedItem:)])
        [self.delegate toolbar:self pressedItem:[self.barButtons indexOfObject:sender]];
}
-(CGRect)frameForButtonNumber:(NSInteger)number{
    CGFloat buttonWidth = self.frame.size.width / self.numberOfButtons;
    CGFloat buttonHeight = self.frame.size.height;
    CGFloat x = buttonWidth * number;
    return CGRectMake(x, 0, buttonWidth, buttonHeight);
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.seperatorHeight = self.frame.size.height/2;
        self.seperatorColor = kDEF_SEP_COLOR;
        self.backgroundColor = kDEF_BACK_COLOR;
    }
    return self;
}


@end
