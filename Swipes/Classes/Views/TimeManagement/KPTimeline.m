//
//  KPTimeline.m
//  Swipes
//
//  Created by demosten on 6/29/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "ThemeHandler.h"
#import "KPTimeline.h"

static const CGFloat kTimelineWidth = 2.0f;
static const CGFloat kTimelineSpacing = 7.0f;
static const CGFloat kTimelineEventWidth = 5.0f;
static const CGFloat kTextBoundX = 10.f;
static const CGFloat kTextBoundY = 3.f;

@interface KPTimeline ()

@property (nonatomic, strong) UIFont* titleFont;

@end

@implementation KPTimeline {
    NSDictionary* _mainEventTimeAttr;
    NSDictionary* _mainEventTitleAttr;
    NSDateFormatter* _timeFormatter;
    NSArray * _events;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // defaults
        self.backgroundColor = tcolor(BackgroundColor);
        self.timeColor = tcolor(LaterColor);
        self.titleColor = tcolor(TextColor);
        self.subtitleColor = tcolor(SubTextColor);
        _timespan = 12 * 60 * 60; // 12h +/-
        
        // setup
        self.layer.allowsEdgeAntialiasing = YES;
        self.layer.drawsAsynchronously = YES;
        
        _timeFormatter = [[NSDateFormatter alloc] init];
        [_timeFormatter setLocale:[NSLocale currentLocale]];
        [_timeFormatter setDateStyle:NSDateFormatterNoStyle];
        [_timeFormatter setTimeStyle:NSDateFormatterShortStyle];

        NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
        textStyle.alignment = NSTextAlignmentRight;
        _mainEventTimeAttr = @{ NSFontAttributeName: KP_REGULAR(15), NSForegroundColorAttributeName: _timeColor, NSParagraphStyleAttributeName: textStyle };
        _mainEventTitleAttr = @{ NSFontAttributeName: KP_SEMIBOLD(14), NSForegroundColorAttributeName: _titleColor, NSParagraphStyleAttributeName: textStyle };
    }
    return self;
}

- (void)setTimespan:(NSTimeInterval)timespan
{
    _timespan = fabs(timespan);
    [self reloadData];
}

- (void)setDataSource:(id<KPTimelineDataSource> __nullable)dataSource
{
    _dataSource = dataSource;
    [self reloadData];
}

- (void)reloadData
{
    if (_dataSource && _timespan) {
        [_dataSource timeline:self eventsFromDate:[NSDate dateWithTimeInterval:-_timespan sinceDate:self.event.startDate] toDate:[NSDate dateWithTimeInterval:_timespan sinceDate:self.event.startDate]];
    }
    [self setNeedsDisplay];
}

#pragma mark - Utilities

- (NSString *)textForTime:(id<KPTimelineEventProtocol>)event
{
    NSMutableString* result = [NSMutableString stringWithString:[_timeFormatter stringFromDate:event.startDate]];
    if (60 <= event.duration) {
        [result appendString:@"-"];
        [result appendString:[_timeFormatter stringFromDate:[NSDate dateWithTimeInterval:event.duration sinceDate:event.startDate]]];
    }
    return result;
}

- (CGFloat)heightForDuration:(NSTimeInterval)duration inRect:(CGRect)rect
{
    CGFloat totalMul = rect.size.height / _timespan;
    return totalMul * duration;
}

#pragma mark - Drawing

- (void)drawTimeLineInContext:(CGContextRef)context withHeight:(CGFloat)height atOffset:(CGFloat)offset withColor:(UIColor *)color inRect:(CGRect)rect
{
    // draw the space
    [self.backgroundColor setStroke];
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextSetLineWidth(context, kTimelineWidth);
    CGContextMoveToPoint(context, rect.origin.x + rect.size.width / 2, offset - kTimelineSpacing);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width / 2, offset + height + kTimelineSpacing);
    CGContextStrokePath(context);
    
    // draw the line itself
    [color setStroke];
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, kTimelineEventWidth);
    CGContextMoveToPoint(context, rect.origin.x + rect.size.width / 2, offset);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width / 2, offset + height);
    CGContextStrokePath(context);
}

- (CGFloat)drawText:(NSString *)text attributes:(NSDictionary *)attributes context:(CGContextRef)context offset:(CGFloat)offset rect:(CGRect)rect
{
    CGFloat width = rect.size.width - kTextBoundX * 2;
    CGFloat textHeight = [text boundingRectWithSize: CGSizeMake(width, INFINITY)  options: NSStringDrawingUsesLineFragmentOrigin attributes: attributes context: nil].size.height;
    CGContextSaveGState(context);
    CGRect textRect = CGRectMake(kTextBoundX, offset - textHeight / 2, width, textHeight);
    CGContextClipToRect(context, textRect);
    [text drawInRect: textRect withAttributes: attributes];
    CGContextRestoreGState(context);
    return textHeight;
}

- (void)drawRect:(CGRect)rect
{
    // get the current context
    CGContextRef context = UIGraphicsGetCurrentContext();

    // general setup
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    // draw the initial line
    [_titleColor setStroke];
    CGContextSetLineWidth(context, kTimelineWidth);
    CGContextMoveToPoint(context, rect.origin.x + rect.size.width / 2, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height);
    CGContextStrokePath(context);
    
    // draw our title line
    CGFloat height = [self heightForDuration:self.event.duration inRect:rect] + 1;
    [self drawTimeLineInContext:context withHeight:height atOffset:rect.origin.y + rect.size.height / 2 - height / 2 withColor:_timeColor inRect:rect];
    
    CGFloat textHeight = [self drawText:[self textForTime:self.event] attributes:_mainEventTimeAttr context:context offset:rect.origin.y + rect.size.height / 2 rect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width / 2, rect.size.height)];
    
    [self drawText:_event.title attributes:_mainEventTitleAttr context:context offset:rect.origin.y + rect.size.height / 2 + textHeight + kTextBoundY rect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width / 2, rect.size.height)];
    
}


@end
