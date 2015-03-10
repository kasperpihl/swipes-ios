//
//  AudioHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 11/12/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "AudioHandler.h"
#import "SettingsHandler.h"
@interface AudioHandler ()
@property (nonatomic) NSMutableDictionary *sounds;
@property (nonatomic) BOOL soundsIsOn;
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
        [sharedObject initialize];
    }
    return sharedObject;
}
-(void)initialize{
    self.soundsIsOn = [[kSettings valueForSetting:SettingAppSounds] boolValue];
    notify(SH_UpdateSetting, updatedSetting:);
}
-(void)updatedSetting:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *setting = [userInfo objectForKey:@"Setting"];
    NSNumber *value = [userInfo objectForKey:@"Value"];
    if(setting && setting.integerValue == SettingAppSounds){
        self.soundsIsOn = value.boolValue;
    }
    
}
-(void)playSoundWithName:(NSString *)name{
    if(!self.soundsIsOn)
        return;
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
    clearNotify();
}
@end
