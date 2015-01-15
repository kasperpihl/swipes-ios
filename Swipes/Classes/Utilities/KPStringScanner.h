//
//  KPStringScanner.h
//  Swipes
//
//  Created by demosten on 1/15/15.
//  Copyright (c) 2015 Swipes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KPStringScanner : NSObject

+ (instancetype)scannerWithString:(NSString *)string;

- (instancetype)initWithString:(NSString *)string;

@property (nonatomic, assign) NSUInteger scanLocation;

- (BOOL)scanUpToString:(NSString *)string;
- (BOOL)scanToAfterString:(NSString *)string;

@end
