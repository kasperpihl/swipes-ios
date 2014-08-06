//
//  LocationSearchView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 12/02/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionHeaderView.h"
#include <CoreLocation/CoreLocation.h>
@class LocationSearchView;
@protocol LocationSearchDelegate <NSObject>
-(void)locationSearchView:(LocationSearchView*)locationSearchView selectedLocation:(CLPlacemark*)location;
@end

@interface LocationSearchView : UIView
+(NSString*)formattedAddressForPlace:(CLPlacemark*)place;
@property (nonatomic,weak) id<LocationSearchDelegate> delegate;
@property SectionHeaderView *headerView;
@property (nonatomic) UITextField *searchField;
-(NSInteger)numberOfHistoryPlaces;
@end
