/*
 Copyright (c) 2013 Katsuma Tanaka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "QBPopupMenu.h"

#import "QBPopupMenuOverlayView.h"

@interface QBPopupMenu ()

@property (nonatomic, strong) QBPopupMenuOverlayView *overlayView;

@property (nonatomic, strong) UIImage *popupImage;
@property (nonatomic, strong) UIImage *highlightedPopupImage;
@property (nonatomic) NSInteger overflowX;

- (void)performAction:(id)sender;
- (CGSize)actualSize;
- (UIImage *)croppedImageFromImage:(UIImage *)image rect:(CGRect)rect;
- (UIImage *)popupImageForState:(QBPopupMenuState)state;
@end

@implementation QBPopupMenu

- (instancetype)init
{
    return [self initWithItems:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithItems:nil];
}

- (instancetype)initWithItems:(NSArray *)items
{
    self = [super initWithFrame:CGRectZero];
    
    if (self) {

        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];

        self.items = items;
        self.cornerRadius = 8;
        self.arrowSize = 12;
        self.animationEnabled = YES;
        self.unselectedColor = [UIColor blackColor];
        self.selectedColor = [UIColor blueColor];
        self.textColor = [UIColor whiteColor];
        self.popupImage = nil;
        self.highlightedPopupImage = nil;
    }
    
    return self;
}
-(void)render{

}
- (void)setItems:(NSArray *)items
{
    _items = [items copy];
    
    if (items) {
        CGSize actualSize = [self actualSize];
        actualSize.height = actualSize.height + self.arrowSize;
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, actualSize.width, actualSize.height);
        
        self.popupImage = [self popupImageForState:QBPopupMenuStateNormal];
        self.highlightedPopupImage = [self popupImageForState:QBPopupMenuStateHighlighted];

        for (UIView *subview in self.subviews) {
            [subview removeFromSuperview];
        }
        
        CGSize frameSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height - self.arrowSize);
        CGFloat middle = round(frameSize.height / 2);
        
        CGFloat itemOffset = 0;
        
        for (NSUInteger i = 0; i < self.items.count; i++) {
            QBPopupMenuItem *item = [self.items objectAtIndex:i];
            CGSize itemSize = [item actualSize];
            CGRect itemFrame = CGRectMake(itemOffset, 0, itemSize.width, actualSize.height);
            
            UIImage *image = [self croppedImageFromImage:self.popupImage rect:itemFrame];
            UIImage *highlightedImage = [self croppedImageFromImage:self.highlightedPopupImage rect:itemFrame];
        
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = i;
            button.frame = itemFrame;
            button.autoresizingMask = UIViewAutoresizingNone;
            button.enabled = item.enabled;
            
            [button setImage:image forState:UIControlStateNormal];
            [button setImage:highlightedImage forState:UIControlStateHighlighted];
            [button setImage:image forState:UIControlStateDisabled];
            
            [button addTarget:self action:@selector(performAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:button];
            
            if (item.customView) {
                item.customView.frame = CGRectMake(itemOffset, 0, itemSize.width, frameSize.height);
                
                [self addSubview:item.customView];
            } else {
                if (item.title && item.image) {
                    // Image
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(itemOffset, 4, itemSize.width, middle - 4)];
                    imageView.image = item.image;
                    imageView.clipsToBounds = YES;
                    imageView.contentMode = UIViewContentModeCenter;
                    imageView.autoresizingMask = UIViewAutoresizingNone;
                    
                    [self addSubview:imageView];
                    
                    // Title
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemOffset, middle, itemSize.width, middle)];
                    titleLabel.text = item.title;
                    titleLabel.font = [item actualFont];
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    titleLabel.highlightedTextColor = self.unselectedColor;
                    titleLabel.textColor = self.textColor;
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.autoresizingMask = UIViewAutoresizingNone;
                    
                    [self addSubview:titleLabel];
                } else if (item.title) {
                    // Title
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemOffset, 0, itemSize.width, frameSize.height)];
                    titleLabel.text = item.title;
                    titleLabel.font = [item actualFont];
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    titleLabel.textColor = self.textColor;
                    titleLabel.highlightedTextColor = self.unselectedColor;
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.autoresizingMask = UIViewAutoresizingNone;
                    
                    [self addSubview:titleLabel];
                } else if (item.image) {
                    // Image
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(itemOffset, 4, itemSize.width, frameSize.height - 4)];
                    imageView.image = item.image;
                    imageView.clipsToBounds = YES;
                    imageView.contentMode = UIViewContentModeCenter;
                    imageView.autoresizingMask = UIViewAutoresizingNone;
                    
                    [self addSubview:imageView];
                }
            }
            
            itemOffset = itemOffset + itemSize.width;
        }
    }
}



#pragma mark -

- (void)showInView:(UIView *)view atPoint:(CGPoint)point;
{
    if ([self.delegate respondsToSelector:@selector(popupMenuWillAppear:)]) {
        [self.delegate popupMenuWillAppear:self];
    }
    
    
    CGRect frame = self.frame;
    frame.origin.x = round(point.x - frame.size.width / 2);
    CGFloat minCheck = frame.origin.x-self.sidePadding;
    CGFloat maxCheck = (frame.origin.x+frame.size.width+self.sidePadding)-view.frame.size.width;
    
    if(minCheck < 0){
        self.overflowX = minCheck;
        frame.origin.x = self.sidePadding;
    }
    else if(maxCheck > 0){
        self.overflowX = maxCheck;
        frame.origin.x = frame.origin.x-maxCheck;
    }
    if(self.overflowX != 0){
        self.items = self.items;
    }
    frame.origin.y = round(point.y - frame.size.height);
    self.frame = frame;
    
    QBPopupMenuOverlayView *overlayView = [[QBPopupMenuOverlayView alloc] initWithFrame:view.bounds];
    overlayView.popupMenu = self;
    
    self.overlayView = overlayView;

    self.layer.shadowOpacity = 0.5;
    self.layer.shadowOffset = CGSizeMake(0, 1.6);
    self.layer.shadowRadius = 1.5;

    if (self.animationEnabled) {
        self.layer.opacity = 0;
    }

    [self.overlayView addSubview:self];
    [view addSubview:self.overlayView];
    
    if (self.animationEnabled) {
        [UIView animateWithDuration:0.2 animations:^(void) {
            self.layer.opacity = 1.0;
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(popupMenuDidAppear:)]) {
                [self.delegate popupMenuDidAppear:self];
            }
        }];
    } else {
        if ([self.delegate respondsToSelector:@selector(popupMenuDidAppear:)]) {
            [self.delegate popupMenuDidAppear:self];
        }
    }
}

- (void)dismiss
{
    if ([self.delegate respondsToSelector:@selector(popupMenuWillDisappear:)]) {
        [self.delegate popupMenuWillDisappear:self];
    }

    if (self.animationEnabled) {

        [UIView animateWithDuration:0.2 animations:^(void) {
            self.layer.opacity = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [self.overlayView removeFromSuperview];

            if ([self.delegate respondsToSelector:@selector(popupMenuDidDisappear:)]) {
                [self.delegate popupMenuDidDisappear:self];
            }
        }];
    } else {

        [self removeFromSuperview];
        [self.overlayView removeFromSuperview];

        if ([self.delegate respondsToSelector:@selector(popupMenuDidDisappear:)]) {
            [self.delegate popupMenuDidDisappear:self];
        }
    }
}

- (void)performAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    QBPopupMenuItem *item = [self.items objectAtIndex:button.tag];
    
    [item performAction];
    
    [self dismiss];
}

- (CGSize)actualSize
{
    CGFloat width = 0, height = 0;
    
    for (NSUInteger i = 0; i < self.items.count; i++) {
        QBPopupMenuItem *item = [self.items objectAtIndex:i];
        CGSize actualItemSize = [item actualSize];
        
        width = width + actualItemSize.width;
        
        if (actualItemSize.height > height) {
            height = actualItemSize.height;
        }
    }
    
    return CGSizeMake(width, height);
}

- (UIImage *)croppedImageFromImage:(UIImage *)image rect:(CGRect)rect
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGRect scaledRect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * 2);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], scaledRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    
    return croppedImage;
}

- (UIImage *)popupImageForState:(QBPopupMenuState)state
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat cornerRadius = self.cornerRadius;
    CGFloat arrowSize = self.arrowSize;
    CGSize frameSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height - arrowSize);
    CGPoint point = CGPointMake(round(self.bounds.size.width / 2 - 1), self.bounds.size.height - 1);
    CGFloat inset = 1;
    CGFloat cornerInset = 1;

    CGMutablePathRef basePath = CGPathCreateMutable();
    
    CGPathMoveToPoint(basePath, NULL, 0, cornerRadius);
    CGPathAddArcToPoint(basePath, NULL, 0, 0, cornerRadius, 0, cornerRadius);
    
    CGPathAddLineToPoint(basePath, NULL, frameSize.width - cornerRadius, 0);
    CGPathAddArcToPoint(basePath, NULL, frameSize.width, 0, frameSize.width, cornerRadius, cornerRadius);
    
    CGPathAddLineToPoint(basePath, NULL, frameSize.width, frameSize.height - cornerRadius);
    CGPathAddArcToPoint(basePath, NULL, frameSize.width, frameSize.height, frameSize.width - cornerRadius, frameSize.height, cornerRadius);
    
    CGFloat xCoordinate = point.x + self.overflowX;
    CGPathAddLineToPoint(basePath, NULL, xCoordinate + arrowSize, frameSize.height);
    CGPathAddLineToPoint(basePath, NULL, xCoordinate, point.y);
    CGPathAddLineToPoint(basePath, NULL, xCoordinate - arrowSize, frameSize.height);
    
    CGPathAddLineToPoint(basePath, NULL, cornerRadius, frameSize.height);
    CGPathAddArcToPoint(basePath, NULL, 0, frameSize.height, 0, frameSize.height - cornerRadius, cornerRadius);
    
    CGPathCloseSubpath(basePath);
    
    CGContextAddPath(context, basePath);
    // TODO: Border color + arrow color
    CGContextSetFillColorWithColor(context, self.unselectedColor.CGColor);
    CGContextFillPath(context);
    
    CGPathRelease(basePath);
    CGMutablePathRef basePath2 = CGPathCreateMutable();
    
    CGPathMoveToPoint(basePath2, NULL, inset, cornerRadius);
    CGPathAddArcToPoint(basePath2, NULL, inset, inset, cornerRadius, inset, cornerRadius - cornerInset);
    
    CGPathAddLineToPoint(basePath2, NULL, frameSize.width - cornerRadius, inset);
    CGPathAddArcToPoint(basePath2, NULL, frameSize.width - inset, inset, frameSize.width - inset, cornerRadius, cornerRadius - cornerInset);
    
    CGPathAddLineToPoint(basePath2, NULL, frameSize.width-inset,frameSize.height - cornerRadius);
    CGPathAddArcToPoint(basePath2, NULL, frameSize.width - inset, frameSize.height-inset, frameSize.width-cornerRadius, frameSize.height-inset, cornerRadius - cornerInset);
    CGPathAddLineToPoint(basePath2, NULL, 0+cornerRadius, frameSize.height-inset);
    CGPathAddArcToPoint(basePath2, NULL, inset, frameSize.height-inset, inset, frameSize.height-cornerRadius, cornerRadius-cornerInset);
    
    CGPathCloseSubpath(basePath2);
    
    CGContextAddPath(context, basePath2);
    switch(state) {
        case QBPopupMenuStateNormal:
            CGContextSetFillColorWithColor(context, self.unselectedColor.CGColor);
            break;
        case QBPopupMenuStateHighlighted:
            CGContextSetFillColorWithColor(context, self.selectedColor.CGColor);
            break;
    }
    CGContextFillPath(context);
    
    CGPathRelease(basePath2);
    
    CGFloat separatorOffset = 0;
    CGFloat seperatorInset = 10;
    if (self.items.count > 1) {
        for (NSUInteger i = 0; i < self.items.count; i++) {
            QBPopupMenuItem *item = [self.items objectAtIndex:i];
            CGSize actualSize = [item actualSize];
            if (i != self.items.count - 1) {
                separatorOffset = separatorOffset + actualSize.width;
                [self drawSeparatorInContext:context startPoint:CGPointMake(separatorOffset-1, inset + seperatorInset) endPoint:CGPointMake(separatorOffset-1, frameSize.height - inset -seperatorInset) state:state];
            }
        }
    }
    

    UIImage *popupImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return popupImage;
}
- (void)drawSeparatorInContext:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint state:(QBPopupMenuState)state
{
    CGContextSaveGState(context);
    CGContextAddRect(context, CGRectMake(startPoint.x, startPoint.y, 2, endPoint.y - startPoint.y));
    CGContextSetFillColorWithColor(context, self.textColor.CGColor);
    CGContextFillPath(context);
}


@end
