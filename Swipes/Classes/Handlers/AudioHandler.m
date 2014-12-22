//
//  AudioHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 11/12/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "AudioHandler.h"
@interface AudioHandler ()
@property (nonatomic) NSMutableDictionary *sounds;
@end
@implementation AudioHandler
static AudioHandler *sharedObject;
-(NSDictionary *)sounds{
    if(!_sounds){
        _sounds = [NSMutableDictionary dictionary];
    }
    return _sounds;
}
+(AudioHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[AudioHandler allocWithZone:NULL] init];
    }
    return sharedObject;
}
-(void)playSoundWithName:(NSString *)name{
    SystemSoundID soundId = [self soundWithName:name];
    AudioServicesPlaySystemSound(soundId);
}
-(void)cancelSoundWithName:(NSString *)name{
    SystemSoundID soundId = (SystemSoundID)[[self.sounds objectForKey:name] unsignedLongValue];
    if(soundId){
        AudioServicesDisposeSystemSoundID(soundId);
        [self.sounds removeObjectForKey:name];
    }
}
-(SystemSoundID)soundWithName:(NSString *)name{
    SystemSoundID soundId;
    if([self.sounds objectForKey:name]){
        soundId = (SystemSoundID)[[self.sounds objectForKey:name] unsignedLongValue];
    }
    else{
        soundId = [AudioHandler createSoundID:name];
        [self.sounds setObject:[NSNumber numberWithUnsignedLong:soundId] forKey:name];
    }
    return soundId;
}
+ (SystemSoundID) createSoundID: (NSString*)name
{
    NSString *path = [NSString stringWithFormat: @"%@/%@",
                      [[NSBundle mainBundle] resourcePath], name];
    
    
    NSURL* filePath = [NSURL fileURLWithPath: path isDirectory: NO];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    return soundID;
}

-(void)dealloc{
    for (NSString *key in [self.sounds allKeys]){
        SystemSoundID soundId = (SystemSoundID)[[self.sounds objectForKey:key] unsignedLongValue];
        AudioServicesDisposeSystemSoundID(soundId);
    }
}
@end
