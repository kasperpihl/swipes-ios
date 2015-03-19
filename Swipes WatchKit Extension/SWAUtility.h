//
//  SWAUtility.h
//  Swipes
//
//  Created by demosten on 3/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const EVERNOTE_SERVICE;
extern NSString* const GMAIL_SERVICE;

@interface SWAUtility : NSObject

+(NSString *)readableTime:(NSDate*)time;

@end
