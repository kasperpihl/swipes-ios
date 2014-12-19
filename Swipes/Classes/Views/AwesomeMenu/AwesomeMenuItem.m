//
//  AwesomeMenuItem.m
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.
//

#import "AwesomeMenuItem.h"
@interface AwesomeMenuItem ()

@end

static inline CGRect ScaleRect(CGRect rect, float n) {return CGRectMake((rect.size.width - rect.size.width * n)/ 2, (rect.size.height - rect.size.height * n) / 2, rect.size.width * n, rect.size.height * n);}
@implementation AwesomeMenuItem


@synthesize startPoint = _startPoint;
@synthesize endPoint = _endPoint;
@synthesize nearPoint = _nearPoint;
@synthesize farPoint = _farPoint;
@synthesize delegate  = _delegate;

#pragma mark - initialization & cleaning up
-(id)initWithImageString:(NSString *)imgStr{
    if(self = [super init]){
        self.buttonSize = 38;
        self.imageString = imgStr;
        self.font = iconFont(22);
        self.text = self.imageString;
        self.textColor = tcolor(TextColor);
        self.backgroundColor = tcolor(BackgroundColor);
        self.textAlignment = NSTextAlignmentCenter;
        self.userInteractionEnabled = YES;
        self.layer.borderColor = tcolor(TextColor).CGColor;
        self.layer.borderWidth = 1;
        [self layoutSubviews];
    }
    return self;
}


#pragma mark - UIView's methods
- (void)layoutSubviews
{
    [super layoutSubviews];
    float width = self.buttonSize;
    float height = self.buttonSize;
    self.bounds = CGRectMake(0, 0, width, height);
    self.layer.cornerRadius = width/2;
    self.layer.masksToBounds = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = YES;
    if ([_delegate respondsToSelector:@selector(AwesomeMenuItemTouchesBegan:)])
    {
       [_delegate AwesomeMenuItemTouchesBegan:self];
    }
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // if move out of 2x rect, cancel highlighted.
    CGPoint location = [[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(ScaleRect(self.bounds, 2.0f), location))
    {
        self.highlighted = NO;
    }
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
    // if stop in the area of 2x rect, response to the touches event.
    CGPoint location = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(ScaleRect(self.bounds, 2.0f), location))
    {
        if ([_delegate respondsToSelector:@selector(AwesomeMenuItemTouchesEnd:)])
        {
            [_delegate AwesomeMenuItemTouchesEnd:self];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
}

#pragma mark - instant methods
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.backgroundColor = highlighted ? tcolor(TextColor) : tcolor(BackgroundColor);
    self.textColor = highlighted ? tcolor(BackgroundColor) : tcolor(TextColor);
}


@end
