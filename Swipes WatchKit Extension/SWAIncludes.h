//
//  SWAIncludes.h
//  Swipes
//
//  Created by demosten on 12/27/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#ifndef Swipes_SWAIncludes_h
#define Swipes_SWAIncludes_h

typedef NS_ENUM(NSUInteger, SWAPage) {
    SWAPageSchedule = 0,
    SWAPageToday = 1,
    SWAPageDone = 2
};

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
    CellTypeSchedule,
    CellTypeToday,
    CellTypeDone
};

#endif
