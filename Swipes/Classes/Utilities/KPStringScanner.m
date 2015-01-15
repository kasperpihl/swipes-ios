//
//  KPStringScanner.m
//  Swipes
//
//  Created by demosten on 1/15/15.
//  Copyright (c) 2015 Swipes. All rights reserved.
//

#import "KPStringScanner.h"

@interface KPStringScanner ()

@property (nonatomic, strong) NSString* content;

@end

@implementation KPStringScanner

+ (instancetype)scannerWithString:(NSString *)string
{
    return [[KPStringScanner alloc] initWithString:string];
}

- (instancetype)initWithString:(NSString *)string
{
    self = [super init];
    if (self) {
        _content = string;
        _scanLocation = 0;
    }
    return self;
}

- (BOOL)scanUpToString:(NSString *)string
{
    if (nil == _content || nil == string || _scanLocation >= _content.length) {
        return NO;
    }
    NSRange range = [_content rangeOfString:string options:0 range:NSMakeRange(_scanLocation, _content.length - _scanLocation)];
    if (NSNotFound != range.location) {
        _scanLocation = range.location;
        return YES;
    }
    return NO;
}

- (BOOL)scanToAfterString:(NSString *)string
{
    BOOL result = [self scanUpToString:string];
    if (result) {
        _scanLocation += string.length;
    }
    return result;
}

@end
