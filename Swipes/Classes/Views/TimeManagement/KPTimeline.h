//
//  KPTimeline.h
//  Swipes
//
//  Created by demosten on 6/29/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KPTimeline;

@protocol KPTimelineEventProtocol <NSObject>

- (nonnull NSString *)title;
- (nonnull NSDate *)startDate;
- (NSTimeInterval)duration;

@end

@protocol KPTimelineDataSource <NSObject>

-(nonnull NSArray<KPTimelineEventProtocol> *)timeline:(nonnull KPTimeline  *)timeline eventsFromDate:(nonnull NSDate *)fromDate toDate:(nonnull NSDate *)toDate;

@end

@protocol KPTimelineDelegate <NSObject>

-(void)timeline:(nonnull KPTimeline  *)timeline didUpdateElement:(nonnull id<KPTimelineEventProtocol>)element;

@end

@interface KPTimeline : UIView

@property (nonatomic, weak, nullable) id<KPTimelineDataSource> dataSource;
@property (nonatomic, strong, nonnull) id<KPTimelineEventProtocol> event;
@property (nonatomic, assign) NSTimeInterval timespan;

// theme
@property (nonatomic, strong, nonnull) UIColor* titleColor;
@property (nonatomic, strong, nonnull) UIColor* subtitleColor;
@property (nonatomic, strong, nonnull) UIColor* timeColor;

@end
