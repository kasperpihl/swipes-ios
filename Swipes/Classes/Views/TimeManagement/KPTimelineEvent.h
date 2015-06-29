//
//  KPTimelineEvent.h
//  Swipes
//
//  Created by demosten on 6/29/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KPTimeline.h"

@interface KPTimelineEvent : NSObject <KPTimelineEventProtocol>

- (instancetype)initWithTitle:(NSString *)title startDate:(NSDate *)startDate duration:(NSTimeInterval)duration;

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSDate* startDate;
@property (nonatomic, assign) NSTimeInterval duration;

@end
