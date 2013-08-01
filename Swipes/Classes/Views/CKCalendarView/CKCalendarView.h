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

@protocol CKCalendarDelegate;

@interface CKDateItem : NSObject

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) UIColor *highlightedTextColor;
@property (nonatomic, strong) UIFont *titleFont;

@end

typedef struct
{
    int     hours;
    int     minutes;
} TimeRef;
typedef enum {
    startSunday = 1,
    startMonday = 2,
} CKCalendarStartDay;

@interface CKCalendarView : UIView

@property (nonatomic) CKCalendarStartDay calendarStartDay;
@property (nonatomic, strong) NSLocale *locale;
@property (nonatomic, readonly) NSDate *selectedDate;
@property (nonatomic, readonly) NSArray *datesShowing;

@property (nonatomic) BOOL onlyShowCurrentMonth;
@property (nonatomic) BOOL adaptHeightToNumberOfWeeksInMonth;

@property (nonatomic, weak) id<CKCalendarDelegate> delegate;

// Theming
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont *dateOfWeekFont;
@property (nonatomic, strong) UIColor *dayOfWeekTextColor;

- (void)setMonthButtonColor:(UIColor *)color;

- (void)selectDate:(NSDate *)date makeVisible:(BOOL)visible;
- (void)reloadData;
- (void)reloadDates:(NSArray *)dates;

// Helper methods for delegates, etc.
- (BOOL)date:(NSDate *)date1 isSameDayAsDate:(NSDate *)date2;
- (BOOL)dateIsInCurrentMonth:(NSDate *)date;

@end

@protocol CKCalendarDelegate <NSObject>

@optional
- (void)calendar:(CKCalendarView *)calendar pressedTitleButton:(UIButton*)sender;
- (void)calendar:(CKCalendarView *)calendar updateTimeForDate:(NSDate**)date;

- (void)calendar:(CKCalendarView *)calendar didLayoutInRect:(CGRect)frame;

@end