//
//  AnalyticsHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 06/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ANALYTICS [AnalyticsHandler sharedInstance]
@interface AnalyticsHandler : NSObject
+(AnalyticsHandler*)sharedInstance;
@end
