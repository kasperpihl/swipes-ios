//
//  DotView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 20/10/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kOutlineSize 4
#define kDefaultDotSize (GLOBAL_DOT_SIZE)
#define kDefaultSize (kDefaultDotSize+2*kOutlineSize)

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
        self.dotView = [[UIView alloc] init];
        [self addSubview:self.dotView];
        [self setSize:kDefaultSize];
        
    }
    return self;
}
-(void)setSize:(CGFloat)size{
    CGRectSetSize(self, size, size);
    self.layer.cornerRadius = size/2;
    
    CGFloat dotSize = size-2*kOutlineSize;
    CGRectSetSize(self.dotView, dotSize, dotSize);
    self.dotView.layer.cornerRadius = dotSize/2;
    
    self.dotView.center = CGPointMake(size/2,size/2);
    
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
        self.layer.borderWidth = priority ? LINE_SIZE : 0;
    }
    
}
@end
