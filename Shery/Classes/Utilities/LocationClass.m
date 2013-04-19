//
//  LocationClass.m
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "LocationClass.h"

@implementation LocationClass
@synthesize
locationManager = _locationManager,
currentLocation = _currentLocation;
@synthesize delegate = _delegate;
static LocationClass *sharedObject;
+(LocationClass *)sharedInstance{
    if(!sharedObject) sharedObject = [[LocationClass allocWithZone:NULL] init];
    return sharedObject;
}
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    self.currentLocation = newLocation;
    
    if(self.delegate!=nil)
        [self.delegate locationFound:self.currentLocation];
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Error: %@", [error description]);
    
    if(self.delegate!=nil)
        [self.delegate locationNotFound:error];
}
-(void)startLocationWithDelegate:(NSObject<LocationClassDelegate>*)delegate{
    self.delegate = delegate;
    [self.locationManager startUpdatingLocation];
}
-(void)stopLocation{
    [self.locationManager stopUpdatingLocation];
}
- (id) init {
    self = [super init];
    if (self != nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self; // send loc updates to myself
    }
    return self;
}
@end

