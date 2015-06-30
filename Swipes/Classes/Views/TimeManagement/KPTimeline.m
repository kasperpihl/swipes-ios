//
//  KPTimeline.m
//  Swipes
//
//  Created by demosten on 6/29/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "ThemeHandler.h"
#import "KPTimeline.h"

static const CGFloat kTimelineWidth = 0.5f;
static const CGFloat kTimelineSpacing = 3.0f;
static const CGFloat kTimelineEventWidth = 4.0f;
static const CGFloat kTextBoundX = 10.f;
static const CGFloat kTextBoundY = 3.f;
static const CGFloat kInvalidOffset = -1000000;

@interface KPTimeline ()

@property (nonatomic, strong) UIFont* titleFont;

@end

@implementation KPTimeline {
    NSDictionary* _mainEventTimeAttr;
    NSDictionary* _mainEventTitleAttr;
    NSDictionary* _eventTimeAttr;
    NSDictionary* _eventTitleAttr;
    NSDateFormatter* _timeFormatter;
    NSArray* _events;
    NSDate* _startDate;
    NSDate* _endDate;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // defaults
        self.backgroundColor = [UIColor whiteColor]; // tcolor(BackgroundColor);
        self.timeColor = tcolor(LaterColor);
        self.titleColor = tcolor(TextColor);
        self.subtitleColor = gray(158, 1); // tcolor(SubTextColor);
        _timespan = 10 * 60 * 60; // 12h +/-
        
        // setup
        self.layer.allowsEdgeAntialiasing = YES;
        self.layer.drawsAsynchronously = YES;
        
        _timeFormatter = [[NSDateFormatter alloc] init];
        [_timeFormatter setLocale:[NSLocale currentLocale]];
        [_timeFormatter setDateStyle:NSDateFormatterNoStyle];
        [_timeFormatter setTimeStyle:NSDateFormatterShortStyle];

        NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
        textStyle.alignment = NSTextAlignmentRight;
        _mainEventTimeAttr = @{ NSFontAttributeName: KP_REGULAR(14), NSForegroundColorAttributeName: _timeColor, NSParagraphStyleAttributeName: textStyle };
        _mainEventTitleAttr = @{ NSFontAttributeName: KP_SEMIBOLD(13), NSForegroundColorAttributeName: _titleColor, NSParagraphStyleAttributeName: textStyle };
        
        textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
        textStyle.alignment = NSTextAlignmentLeft;
        _eventTimeAttr = @{ NSFontAttributeName: KP_SEMIBOLD(11), NSForegroundColorAttributeName: _subtitleColor, NSParagraphStyleAttributeName: textStyle };
        _eventTitleAttr = @{ NSFontAttributeName: KP_SEMIBOLD(11), NSForegroundColorAttributeName: _titleColor, NSParagraphStyleAttributeName: textStyle };
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

- (void)setEvent:(id<KPTimelineEventProtocol> __nonnull)event
{
    _event = event;
    [self reloadData];
}

- (void)reloadData
{
    if (_dataSource && _timespan && _event) {
        [self doUpdateTimeline];
        _events = [_dataSource timeline:self eventsFromDate:_startDate toDate:_endDate];
    }
    [self setNeedsDisplay];
}

- (void)doUpdateTimeline
{
    _startDate = [NSDate dateWithTimeInterval:-(_timespan / 2) sinceDate:_event.startDate];
    _endDate = [NSDate dateWithTimeInterval:_timespan / 2 sinceDate:_event.startDate];
}

- (void)eventUpdated
{
    // TODO improve this part
    [self reloadData];
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

- (CGFloat)offsetForEvent:(id<KPTimelineEventProtocol>)event inRect:(CGRect)rect
{
    NSTimeInterval startTI = [_startDate timeIntervalSinceReferenceDate];
    NSTimeInterval endTI = [_endDate timeIntervalSinceReferenceDate];
    NSTimeInterval startTarget = [event.startDate timeIntervalSinceReferenceDate];
    NSTimeInterval endTarget = startTarget + event.duration;
    
    if (startTarget > endTI || (endTarget < startTI)) {
        return kInvalidOffset;
    }
    
    return ((startTarget - startTI) / _timespan) * rect.size.height + rect.origin.y;
}

#pragma mark - Drawing

- (void)drawTimeLineInContext:(CGContextRef)context withHeight:(CGFloat)height atOffset:(CGFloat)offset withColor:(UIColor *)color inRect:(CGRect)rect
{
    // draw the space
    [self.backgroundColor setStroke];
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, kTimelineEventWidth + 2);
    CGContextMoveToPoint(context, rect.origin.x + rect.size.width / 2, offset - kTimelineSpacing);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width / 2, offset + height + kTimelineSpacing);
    CGContextStrokePath(context);
    
    // draw the line itself
    [color setStroke];
    //CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, kTimelineEventWidth);
    CGContextMoveToPoint(context, rect.origin.x + rect.size.width / 2, offset);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width / 2, offset + height);
    CGContextStrokePath(context);
}

- (CGFloat)drawText:(NSString *)text attributes:(NSDictionary *)attributes context:(CGContextRef)context offset:(CGFloat)offset height:(CGFloat)height rect:(CGRect)rect
{
    CGFloat width = rect.size.width - kTextBoundX * 2;
    CGFloat textHeight = [text boundingRectWithSize:CGSizeMake(width, INFINITY) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context: nil].size.height;
    CGContextSaveGState(context);
    CGFloat heightUpdate = height >= textHeight ? textHeight / 3 : textHeight / 2;
    CGRect textRect = CGRectMake(kTextBoundX + rect.origin.x, offset - heightUpdate, width, textHeight);
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
    
    // draw events
    CGRect eventDrawRect = CGRectMake(rect.origin.x + rect.size.width / 2, rect.origin.y, rect.size.width / 2, rect.size.height);
    for (id<KPTimelineEventProtocol> event in _events) {
        CGFloat height = [self heightForDuration:event.duration inRect:rect] + 1;
        CGFloat offset = [self offsetForEvent:event inRect:rect];
        if (offset != kInvalidOffset) {
            [self drawTimeLineInContext:context withHeight:height atOffset:offset withColor:_titleColor inRect:rect];
            CGFloat textHeight = [self drawText:[self textForTime:event] attributes:_eventTimeAttr context:context offset:offset height:height rect:eventDrawRect];
            [self drawText:event.title attributes:_eventTitleAttr context:context offset:offset + textHeight + kTextBoundY height:height rect:eventDrawRect];
        }
    }
    
    // draw our title line
    CGFloat height = [self heightForDuration:self.event.duration inRect:rect] + 1;
    [self drawTimeLineInContext:context withHeight:height atOffset:rect.origin.y + rect.size.height / 2 withColor:_timeColor inRect:rect];
    
    CGFloat textHeight = [self drawText:[self textForTime:self.event] attributes:_mainEventTimeAttr context:context offset:rect.origin.y + rect.size.height / 2 height:height rect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width / 2, rect.size.height)];
    
    [self drawText:_event.title attributes:_mainEventTitleAttr context:context offset:rect.origin.y + rect.size.height / 2 + textHeight + kTextBoundY height:height rect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width / 2, rect.size.height)];
}


@end
