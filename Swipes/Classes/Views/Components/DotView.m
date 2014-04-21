//
//  DotView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 20/10/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kDefaultDotSize 11.0f

#define kPriorityDotSize 9.0f
#define kOutlineSpace 3.5f
#define kLineSize 2.0f

#define kDefaultSize (kPriorityDotSize+2*kOutlineSpace+2*kLineSize)

#import "DotView.h"
#import <QuartzCore/QuartzCore.h>
@interface DotView ()
@property (nonatomic) UIView *dotView;
@end
@implementation DotView
-(id)init{
    return [self initWithFrame:CGRectMake(0, 0, kDefaultSize, kDefaultSize)];
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = CLEAR;
        self.userInteractionEnabled = NO;
        self.dotView = [[UIView alloc] init];
        [self addSubview:self.dotView];
        [self setSize:kDefaultSize];
        
    }
    return self;
}
-(void)setSize:(CGFloat)size{
    CGRectSetSize(self, size, size);
    self.layer.cornerRadius = size/2;
    [self adjustDot];
    
}
-(void)adjustDot{
    CGFloat size = self.priority ? kPriorityDotSize : kDefaultDotSize;
    self.dotView.layer.cornerRadius = size/2;
    CGRectSetSize(self.dotView, size, size);
    CGRectSetCenter(self.dotView,self.frame.size.width/2, self.frame.size.height/2);
    self.layer.borderWidth = self.priority ? kLineSize : 0;
}
-(void)setDotColor:(UIColor *)dotColor{
    if(_dotColor != dotColor){
        _dotColor = dotColor;
        self.dotView.backgroundColor = dotColor;
        self.layer.borderColor = dotColor.CGColor;
    }
    
}
-(void)setPriority:(BOOL)priority{
    if(_priority != priority){
        _priority = priority;
        [self adjustDot];
    }
    
}
@end
