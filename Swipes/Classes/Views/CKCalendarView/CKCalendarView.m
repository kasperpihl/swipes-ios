//
// Copyright (c) 2012 Jason Kozemczak
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
// THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//


#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "CKCalendarView.h"
#import "NSDate-Utilities.h"
#import "UIColor+Utilities.h"
#import "UtilityClass.h"
#import "SlowHighlightIcon.h"
#define BUTTON_MARGIN 4
#define TOP_HEIGHT 70
#define MONTH_BUTTON_WIDTH 60
#define DAYS_HEADER_HEIGHT 20
#define DEFAULT_CELL_WIDTH 43

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@class CALayer;
@class CAGradientLayer;


// TODO
// this is full of iOS8 related deprecation warnings
// we should fix them when we remove support for iOS7
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface DateButton : SlowHighlightIcon

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) CKDateItem *dateItem;
@property (nonatomic, strong) NSCalendar *calendar;

@end

@implementation DateButton

- (void)setDate:(NSDate *)date {
    _date = date;
    if(date != nil){
        NSDateComponents *comps = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:date];
        [self setTitle:[NSString stringWithFormat:@"%ld", (long)comps.day] forState:UIControlStateNormal];
        
    }
}
@end

@implementation CKDateItem

- (id)init {
    self = [super init];
    if (self) {
        self.textColor = tcolor(TextColor);
        self.unavailableColor = color(80,83,88,1); //,color(170,173,178,1)
        self.selectedTextColor = gray(255,1);
        self.highlightedTextColor = gray(255, 1);
        
    }
    return self;
}

@end

@interface CKCalendarView () <UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIView *highlight;
@property (nonatomic,strong) UIButton *titleButton;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIButton *prevButton;
@property(nonatomic, strong) UIButton *nextButton;
@property(nonatomic, strong) UIView *calendarContainer;
@property(nonatomic, strong) UIView *daysHeader;
@property(nonatomic, strong) NSArray *dayOfWeekLabels;
@property(nonatomic, strong) NSMutableArray *dateButtons;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSDate *monthShowing;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSCalendar *calendar;
@property(nonatomic, assign) CGFloat cellWidth;
@property (nonatomic,strong) UILongPressGestureRecognizer *longPressRecognizer;
@end

@implementation CKCalendarView

@dynamic locale;

- (BOOL) isTypicallyWeekend:(NSDate*)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    if ((components.weekday == 1) ||
        (components.weekday == 7))
        return YES;
    return NO;
}
-(void)setFormatForDate:(NSDate*)date{
    if([date isSameYearAsDate:[NSDate date]]) self.dateFormatter.dateFormat = @"d LLL";
    else self.dateFormatter.dateFormat = @"d LLL  '´'yy";
}
- (void)_init {
    CKCalendarStartDay firstDay;
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    firstDay = (CKCalendarStartDay)[[NSCalendar currentCalendar] firstWeekday];
    [self.calendar setLocale:[NSLocale currentLocale]];
    self.userInteractionEnabled = YES;
    self.cellWidth = self.bounds.size.width/7;

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    self.calendarStartDay = firstDay;
    self.onlyShowCurrentMonth = YES;
    self.adaptHeightToNumberOfWeeksInMonth = YES;

    // SET UP THE HEADER
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UIButton *titleButton = [[UIButton alloc] initWithFrame:CGRectZero];
    titleButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [titleButton addTarget:self action:@selector(pressedTitleButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:titleButton];
    self.titleButton = titleButton;

    UIColor *buttonColor = tcolor(TextColor);
    SlowHighlightIcon *prevButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
    prevButton.titleLabel.font = iconFont(17);
    [prevButton setTitleColor:buttonColor forState:UIControlStateNormal];
    [prevButton setTitleColor:alpha(buttonColor, .2) forState:UIControlStateDisabled];
    [prevButton setTitle:iconString(@"rightArrow") forState:UIControlStateNormal];
    [prevButton setTitle:iconString(@"rightArrowFull") forState:UIControlStateHighlighted];
    prevButton.transform = CGAffineTransformMakeRotation(2*M_PI/2);
    prevButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [prevButton addTarget:self action:@selector(_moveCalendarToPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:prevButton];
    self.prevButton = prevButton;

    SlowHighlightIcon *nextButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
    nextButton.titleLabel.font = iconFont(17);
    [nextButton setTitleColor:buttonColor forState:UIControlStateNormal];
    [nextButton setTitle:iconString(@"rightArrow") forState:UIControlStateNormal];
    [nextButton setTitle:iconString(@"rightArrowFull") forState:UIControlStateHighlighted];
    nextButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [nextButton addTarget:self action:@selector(_moveCalendarToNextMonth) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextButton];
    self.nextButton = nextButton;

    // THE CALENDAR ITSELF
    UIView *calendarContainer = [[UIView alloc] initWithFrame:CGRectZero];
    calendarContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    calendarContainer.clipsToBounds = YES;
    [self addSubview:calendarContainer];
    self.calendarContainer = calendarContainer;

    UIView *daysHeader = [[UIView alloc] initWithFrame:CGRectZero];
    daysHeader.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self.calendarContainer addSubview:daysHeader];
    self.daysHeader = daysHeader;

    NSMutableArray *labels = [NSMutableArray array];
    for (int i = 0; i < 7; ++i) {
        UILabel *dayOfWeekLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        dayOfWeekLabel.textAlignment = NSTextAlignmentCenter;
        dayOfWeekLabel.backgroundColor = [UIColor clearColor];
        [labels addObject:dayOfWeekLabel];
        [self.calendarContainer addSubview:dayOfWeekLabel];
    }
    self.dayOfWeekLabels = labels;
    [self _updateDayOfWeekLabels];

    // at most we'll need 42 buttons, so let's just bite the bullet and make them now...
    NSMutableArray *dateButtons = [NSMutableArray array];
    self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
    self.longPressRecognizer.allowableMovement = 15.0f;
    self.longPressRecognizer.delegate = self;
    [self.calendarContainer addGestureRecognizer:self.longPressRecognizer];
    for (NSInteger i = 1; i <= 42; i++) {
        DateButton *dateButton = [DateButton buttonWithType:UIButtonTypeCustom];
        dateButton.calendar = self.calendar;
        
        dateButton.layer.masksToBounds = YES;
        [dateButton addTarget:self action:@selector(_dateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [dateButtons addObject:dateButton];
    }
    self.dateButtons = dateButtons;

    // initialize the thing
    self.monthShowing = [NSDate date];
    [self _setDefaultStyle];
    
    [self setNeedsLayout]; // TODO: this is a hack to get the first month to show properly
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)dealloc
{
    if (self.longPressRecognizer) {
        self.longPressRecognizer.delegate = nil;
    }
}

-(void)pressedTitleButton:(UIButton*)sender{
    if ([self.delegate respondsToSelector:@selector(calendar:pressedTitleButton:)])
        [self.delegate calendar:self pressedTitleButton:sender];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat containerWidth = self.bounds.size.width;
    self.cellWidth = (containerWidth / 7.0);

    NSInteger numberOfWeeksToShow = 6;
    if (self.adaptHeightToNumberOfWeeksInMonth) {
        numberOfWeeksToShow = [self _numberOfWeeksInMonthContainingDate:self.monthShowing];
    }
    CGFloat containerHeight = (numberOfWeeksToShow * (self.cellWidth) + DAYS_HEADER_HEIGHT);

    CGRect newFrame = self.frame;
    newFrame.size.height = containerHeight + TOP_HEIGHT;
    self.frame = newFrame;

    [self setFormatForDate:self.selectedDate];
    NSString *monthYearString = [[self.dateFormatter stringFromDate:self.selectedDate] uppercaseString];
    self.titleLabel.text = [NSString stringWithFormat:@"%@  |  %@",monthYearString, [UtilityClass timeStringForDate:self.selectedDate]];
    self.titleButton.frame = CGRectMake(MONTH_BUTTON_WIDTH, 0, self.bounds.size.width-2*MONTH_BUTTON_WIDTH, TOP_HEIGHT);
    self.titleLabel.frame = CGRectMake(0, 0, self.bounds.size.width, TOP_HEIGHT);
    self.prevButton.frame = CGRectMake(0,0 , MONTH_BUTTON_WIDTH, TOP_HEIGHT);
    self.nextButton.frame = CGRectMake(self.bounds.size.width - MONTH_BUTTON_WIDTH, 0, MONTH_BUTTON_WIDTH, TOP_HEIGHT);

    self.calendarContainer.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), self.bounds.size.width, containerHeight);
    
    self.daysHeader.frame = CGRectMake(0, 0, self.calendarContainer.frame.size.width, DAYS_HEADER_HEIGHT);
    

    CGRect lastDayFrame = CGRectZero;
    for (UILabel *dayLabel in self.dayOfWeekLabels) {
        CGSize size = sizeWithFont(dayLabel.text,dayLabel.font);
        dayLabel.frame = CGRectMake(CGRectGetMaxX(lastDayFrame), lastDayFrame.origin.y, self.cellWidth, size.height);
        lastDayFrame = dayLabel.frame;
    }

    for (DateButton *dateButton in self.dateButtons) {
        dateButton.date = nil;
        [dateButton removeFromSuperview];
    }

    NSDate *date = [self _firstDayOfMonthContainingDate:self.monthShowing];
    if (!self.onlyShowCurrentMonth) {
        while ([self _placeInWeekForDate:date] != 0) {
            date = [self _previousDay:date];
        }
    }

    NSDate *endDate = [self _firstDayOfNextMonthContainingDate:self.monthShowing];
    if (!self.onlyShowCurrentMonth) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setWeekOfYear:numberOfWeeksToShow];
        endDate = [self.calendar dateByAddingComponents:comps toDate:date options:0];
    }

    NSUInteger dateButtonPosition = 0;
    while ([date laterDate:endDate] != date) {
        DateButton *dateButton = [self.dateButtons objectAtIndex:dateButtonPosition];
        dateButton.date = date;
        dateButton = [self layoutButton:dateButton];
        
        dateButton.frame = [self _calculateDayCellFrame:date];
        [self.calendarContainer addSubview:dateButton];
        
        date = [self _nextDay:date];
        dateButtonPosition++;
    }
    BOOL isEarliestMonth = [self.selectedDate isSameMonthAsDate:[NSDate date]];
    self.prevButton.enabled = !isEarliestMonth;
    if ([self.delegate respondsToSelector:@selector(calendar:didLayoutInRect:)]) {
        [self.delegate calendar:self didLayoutInRect:self.frame];
    }
}
-(void)longPressRecognized:(UILongPressGestureRecognizer*)sender{
    if(sender.state == UIGestureRecognizerStateBegan){
        UIView *view = [self.calendarContainer hitTest:[sender locationInView:self.calendarContainer] withEvent:nil];
        NSDate *date;
        if([view isKindOfClass:[DateButton class]]){
            DateButton *button = (DateButton*)view;
            date = button.date;
        }
        else return;
        if([self.delegate respondsToSelector:@selector(calendar:updateTimeForDate:)])
            [self.delegate calendar:self updateTimeForDate:&date];
        if ([self _compareByMonth:date toDate:self.monthShowing] == NSOrderedSame && [date isLaterThanDate:[[NSDate date] dateAtStartOfDay]]){
            if([self.delegate respondsToSelector:@selector(calendar:longPressForDate:)]){
                [self.delegate calendar:self longPressForDate:date];
            }
        }
    }
}
-(DateButton*)layoutButton:(DateButton*)button{
    CKDateItem *item = [[CKDateItem alloc] init];
    NSDate *date = button.date;
    button.alpha = 1;
    button.enabled = YES;
    button.selected = NO;
    NSInteger cornerRadius = self.cellWidth/2;
    button.layer.cornerRadius = cornerRadius;
    button.layer.masksToBounds = YES;
    UIImage *highlightedImage = [tcolor(LaterColor) image];//[UIImage imageNamed:@"selected_circle"];//[UtilityClass imageWithName: scaledToSize:CGSizeMake(kSelectedImageSize, kSelectedImageSize)];
    item.titleFont = KP_REGULAR(17);
    if([date isTypicallyWeekend]) item.titleFont = KP_SEMIBOLD(17);
    
    /* Days out of the current month */
    if (!self.onlyShowCurrentMonth && [self _compareByMonth:date toDate:self.monthShowing] != NSOrderedSame) {
        if([self _compareByMonth:date toDate:self.monthShowing] == NSOrderedAscending && [self _compareByMonth:[NSDate date] toDate:self.monthShowing] == NSOrderedSame){
            button.alpha = 0.0;
            button.enabled = NO;
        }
        item.textColor = item.unavailableColor;
    }
    /* Days earlier than current */
    else if([date isEarlierThanDate:[[NSDate date] dateAtStartOfDay]]){
        item.textColor = item.highlightedTextColor = item.unavailableColor; //color(160,169,179,1);
        highlightedImage = [UIImage new];
        button.alpha = 0.5;
        //item.textColor = gray(200, 1);
    }
    /* If the day is the selected day */
    if (self.selectedDate && [self date:self.selectedDate isSameDayAsDate:date]) {
        item.textColor = item.selectedTextColor;
        button.selected = YES;
    }
    [button setTitleColor:item.textColor forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedImage forState:UIControlStateSelected | UIControlStateHighlighted];
    [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:highlightedImage forState:UIControlStateSelected];
    [button setTitleColor:item.highlightedTextColor forState:UIControlStateHighlighted];
    [button.titleLabel setFont:item.titleFont];
    //button.backgroundColor = item.backgroundColor;
    return button;
}
- (void)_updateDayOfWeekLabels {
    NSArray *weekdays = [self.dateFormatter shortWeekdaySymbols];
    // adjust array depending on which weekday should be first
    NSUInteger firstWeekdayIndex = [self.calendar firstWeekday] - 1;
    if (firstWeekdayIndex > 0) {
        weekdays = [[weekdays subarrayWithRange:NSMakeRange(firstWeekdayIndex, 7 - firstWeekdayIndex)]
                    arrayByAddingObjectsFromArray:[weekdays subarrayWithRange:NSMakeRange(0, firstWeekdayIndex)]];
    }

    NSUInteger i = 0;
    for (NSString *day in weekdays) {
        [[self.dayOfWeekLabels objectAtIndex:i] setText:[day lowercaseString]];
        i++;
    }
}

- (void)setCalendarStartDay:(CKCalendarStartDay)calendarStartDay {
    _calendarStartDay = calendarStartDay;
    [self.calendar setFirstWeekday:self.calendarStartDay];
    [self _updateDayOfWeekLabels];
    [self setNeedsLayout];
}

- (void)setLocale:(NSLocale *)locale {
    [self.dateFormatter setLocale:locale];
    [self _updateDayOfWeekLabels];
    [self setNeedsLayout];
}

- (NSLocale *)locale {
    return self.dateFormatter.locale;
}

- (NSArray *)datesShowing {
    NSMutableArray *dates = [NSMutableArray array];
    // NOTE: these should already be in chronological order
    for (DateButton *dateButton in self.dateButtons) {
        if (dateButton.date) {
            [dates addObject:dateButton.date];
        }
    }
    return dates;
}

- (void)setMonthShowing:(NSDate *)aMonthShowing {
    _monthShowing = [self _firstDayOfMonthContainingDate:aMonthShowing];
    [self setNeedsLayout];
}

- (void)setOnlyShowCurrentMonth:(BOOL)onlyShowCurrentMonth {
    _onlyShowCurrentMonth = onlyShowCurrentMonth;
    [self setNeedsLayout];
}

- (void)setAdaptHeightToNumberOfWeeksInMonth:(BOOL)adaptHeightToNumberOfWeeksInMonth {
    _adaptHeightToNumberOfWeeksInMonth = adaptHeightToNumberOfWeeksInMonth;
    [self setNeedsLayout];
}
-(void)updateTimeForDate:(NSDate**)date{
    
}
- (void)selectDate:(NSDate *)date makeVisible:(BOOL)visible {
    NSMutableArray *datesToReload = [NSMutableArray array];
    if([date isEarlierThanDate:[NSDate date]]) date = [NSDate date];
    if (self.selectedDate) {
        [datesToReload addObject:self.selectedDate];
    }
    if (date) {
        [datesToReload addObject:date];
    }
    if([self.delegate respondsToSelector:@selector(calendar:updateTimeForDate:)])
        [self.delegate calendar:self updateTimeForDate:&date];
    self.selectedDate = date;
    [self reloadDates:datesToReload];
    if (visible && date) {
        self.monthShowing = date;
    }
}

- (void)reloadData {
    self.selectedDate = nil;
    [self setNeedsLayout];
}

- (void)reloadDates:(NSArray *)dates {
    // TODO: only update the dates specified
    [self setNeedsLayout];
}

- (void)_setDefaultStyle {
    self.backgroundColor = UIColorFromRGB(0x393B40);

    [self setTitleColor:[UIColor whiteColor]];
    [self setTitleFont:KP_SEMIBOLD(16)];

    [self setDayOfWeekFont:KP_SEMIBOLD(12)];
    [self setDayOfWeekTextColor:UIColorFromRGB(0x999999)];

}

- (CGRect)_calculateDayCellFrame:(NSDate *)date {
    NSInteger numberOfDaysSinceBeginningOfThisMonth = [self _numberOfDaysFromDate:self.monthShowing toDate:date];
    NSInteger row = (numberOfDaysSinceBeginningOfThisMonth + [self _placeInWeekForDate:self.monthShowing]) / 7;
	
    NSInteger placeInWeek = [self _placeInWeekForDate:date];

    return CGRectMake(placeInWeek * (self.cellWidth), (row * (self.cellWidth)) + CGRectGetMaxY(self.daysHeader.frame), self.cellWidth, self.cellWidth);
}

- (void)_moveCalendarToNextMonth {
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setMonth:1];
    NSDate *newMonth = [self.calendar dateByAddingComponents:comps toDate:self.monthShowing options:0];
    [self selectDate:[self.calendar dateByAddingComponents:comps toDate:self.selectedDate options:0] makeVisible:YES];
    self.monthShowing = newMonth;
}

- (void)_moveCalendarToPreviousMonth {
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setMonth:-1];
    NSDate *newMonth = [self.calendar dateByAddingComponents:comps toDate:self.monthShowing options:0];
    if([newMonth isEarlierThanDate:[NSDate date]] && ![newMonth isSameMonthAsDate:[NSDate date]]) return;
    self.monthShowing = newMonth;
    NSDate *selectionDate = [self.calendar dateByAddingComponents:comps toDate:self.selectedDate options:0];
    [self selectDate:selectionDate makeVisible:YES];
}
- (void)_dateButtonPressed:(id)sender {
    DateButton *dateButton = sender;
    NSDate *date = dateButton.date;
    if ([date isEqualToDate:self.selectedDate]) {
        return;
    }

    [self selectDate:date makeVisible:YES];
    [self setNeedsLayout];
}

#pragma mark - Theming getters/setters

- (void)setTitleFont:(UIFont *)font {
    self.titleLabel.font = font;
}
- (UIFont *)titleFont {
    return self.titleLabel.font;
}

- (void)setTitleColor:(UIColor *)color {
    self.titleLabel.textColor = color;
}
- (UIColor *)titleColor {
    return self.titleLabel.textColor;
}

- (void)setMonthButtonColor:(UIColor *)color {
    [self.prevButton setTitleColor:color forState:UIControlStateNormal];
    [self.nextButton setTitleColor:color forState:UIControlStateNormal];
}

- (void)setDayOfWeekFont:(UIFont *)font {
    for (UILabel *label in self.dayOfWeekLabels) {
        label.font = font;
    }
}
- (UIFont *)dayOfWeekFont {
    return (self.dayOfWeekLabels.count > 0) ? ((UILabel *)[self.dayOfWeekLabels lastObject]).font : nil;
}

- (void)setDayOfWeekTextColor:(UIColor *)color {
    for (UILabel *label in self.dayOfWeekLabels) {
        label.textColor = color;
    }
}
- (UIColor *)dayOfWeekTextColor {
    return (self.dayOfWeekLabels.count > 0) ? ((UILabel *)[self.dayOfWeekLabels lastObject]).textColor : nil;
}

#pragma mark - Calendar helpers

- (NSDate *)_firstDayOfMonthContainingDate:(NSDate *)date {
    NSDateComponents *comps = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    comps.day = 1;
    return [self.calendar dateFromComponents:comps];
}

- (NSDate *)_firstDayOfNextMonthContainingDate:(NSDate *)date {
    NSDateComponents *comps = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    comps.day = 1;
    comps.month = comps.month + 1;
    return [self.calendar dateFromComponents:comps];
}

- (BOOL)dateIsInCurrentMonth:(NSDate *)date {
    return ([self _compareByMonth:date toDate:self.monthShowing] != NSOrderedSame);
}

- (NSComparisonResult)_compareByMonth:(NSDate *)date toDate:(NSDate *)otherDate {
    NSDateComponents *day = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:date];
    NSDateComponents *day2 = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:otherDate];

    if (day.year < day2.year) {
        return NSOrderedAscending;
    } else if (day.year > day2.year) {
        return NSOrderedDescending;
    } else if (day.month < day2.month) {
        return NSOrderedAscending;
    } else if (day.month > day2.month) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

- (NSInteger)_placeInWeekForDate:(NSDate *)date {
    NSDateComponents *compsFirstDayInMonth = [self.calendar components:NSWeekdayCalendarUnit fromDate:date];
    return (compsFirstDayInMonth.weekday - 1 - self.calendar.firstWeekday + 8) % 7;
}

- (BOOL)_dateIsToday:(NSDate *)date {
    return [self date:[NSDate date] isSameDayAsDate:date];
}

- (BOOL)date:(NSDate *)date1 isSameDayAsDate:(NSDate *)date2 {
    // Both dates must be defined, or they're not the same
    if (date1 == nil || date2 == nil) {
        return NO;
    }

    NSDateComponents *day = [self.calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date1];
    NSDateComponents *day2 = [self.calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date2];
    return ([day2 day] == [day day] &&
            [day2 month] == [day month] &&
            [day2 year] == [day year] &&
            [day2 era] == [day era]);
}

- (NSInteger)_numberOfWeeksInMonthContainingDate:(NSDate *)date {
    return [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:date].length;
}

- (NSDate *)_nextDay:(NSDate *)date {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    return [self.calendar dateByAddingComponents:comps toDate:date options:0];
}

- (NSDate *)_previousDay:(NSDate *)date {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:-1];
    return [self.calendar dateByAddingComponents:comps toDate:date options:0];
}

- (NSInteger)_numberOfDaysFromDate:(NSDate *)startDate toDate:(NSDate *)endDate {
    NSInteger startDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:startDate];
    NSInteger endDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:endDate];
    return endDay - startDay;
}

+ (UIImage *)_imageNamed:(NSString *)name withColor:(UIColor *)color {
    UIImage *img = [UIImage imageNamed:name];

    UIGraphicsBeginImageContextWithOptions(img.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];

    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);

    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);

    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return coloredImg;
}

@end

#pragma clang diagnostic pop
