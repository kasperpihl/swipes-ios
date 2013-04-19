//
//  LocationClass.h
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#define LOCATION [LocationClass sharedInstance]
@protocol LocationClassDelegate
-(void) locationFound:(CLLocation*)location;
-(void) locationNotFound:(NSError *)error;
@end

@interface LocationClass : NSObject <CLLocationManagerDelegate>
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) CLLocation *currentLocation;
@property (nonatomic,strong) id<LocationClassDelegate> delegate;
+(LocationClass *)sharedInstance;
-(void)startLocationWithDelegate:(NSObject<LocationClassDelegate>*)delegate;
-(void)stopLocation;
@end
