//
//  AudioHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 11/12/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#define kAudio [AudioHandler sharedInstance]
@interface AudioHandler : NSObject
+ (AudioHandler*) sharedInstance;
- (void)playSoundWithName:(NSString*)name;
-(void)cancelSoundWithName:(NSString *)name;
@end
