//
//  SWAButtonCell.m
//  Swipes
//
//  Created by demosten on 3/3/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "SWAButtonCell.h"

@implementation SWAButtonCell

- (IBAction)onButton1Touch:(id)sender
{
    if (_delegate) {
        [_delegate onButton1Touch];
    }
    
}

- (IBAction)onButton2Touch:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(onButton2Touch)]) {
        [_delegate onButton2Touch];
    }
}


@end
