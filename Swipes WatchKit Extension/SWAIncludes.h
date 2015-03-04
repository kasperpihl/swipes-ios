//
//  SWAIncludes.h
//  Swipes
//
//  Created by demosten on 12/27/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#ifndef Swipes_SWAIncludes_h
#define Swipes_SWAIncludes_h

#define color(r,g,b,a) [UIColor colorWithRed: r/255.0 green: g/255.0 blue: b/255.0 alpha:a]
#define TASKS_COLOR                    color(255,200,94,1) //color(244,203,28,1) //color(237,194,0,1)
#define DONE_COLOR                     color(134,211,110,1) // color(69,217,132,1)  //

#define LOCALIZE_STRING(string) NSLocalizedString(string, nil)

#import <Foundation/Foundation.h>

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
