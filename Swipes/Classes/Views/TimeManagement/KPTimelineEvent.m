//
//  KPTimelineElement.m
//  Swipes
//
//  Created by demosten on 6/29/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "KPTimelineEvent.h"

@implementation KPTimelineEvent

- (instancetype)initWithTitle:(NSString *)title startDate:(NSDate *)startDate duration:(NSTimeInterval)duration
{
    self = [super init];
    if (self) {
        _title = title;
        _startDate = startDate;
        _duration = duration;
    }
    return self;
}

@end
