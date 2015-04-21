//
//  SWAIncludes.h
//  Swipes
//
//  Created by demosten on 12/27/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#ifndef Swipes_SWAIncludes_h
#define Swipes_SWAIncludes_h

#import <Foundation/Foundation.h>

#define color(r,g,b,a) [UIColor colorWithRed: r/255.0 green: g/255.0 blue: b/255.0 alpha:a]
#define TASKS_COLOR                    color(255,193,7,1)
#define DONE_COLOR                     color(134,211,110,1)
#define TEXT_COLOR                     color(27,30,35,1)
#define LATER_COLOR                    color(255,86,55,1)

#ifdef DEBUG
#    define DLog(__FORMAT__, ...) NSLog((@"%s [Line %d]\n" __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#    define DLog(...) /* */
#endif

typedef NS_ENUM(NSUInteger, RepeatOptions) {
    RepeatNever = 0,
    RepeatEveryDay,
    RepeatEveryMonFriOrSatSun,
    RepeatEveryWeek,
    RepeatEveryMonth,
    RepeatEveryYear,
    RepeatOptionsTotal
};

typedef NS_ENUM(NSUInteger, CellType) {
    CellTypeNone = 0,
    CellTypeToday,
};

#endif
