//
//  SWASubtaskCell.m
//  Swipes
//
//  Created by demosten on 3/3/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import "SWASubtaskCell.h"

@implementation SWASubtaskCell

- (IBAction)onButtonTouch:(id)sender
{
    if (_todo && _delegate) {
        [_delegate onCompleteButtonTouch:_todo];
    }
}

@end
