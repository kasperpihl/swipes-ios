//
//  SettingsHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 06/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "SettingsHandler.h"
#import "NSDate-Utilities.h"
@implementation SettingsHandler
static SettingsHandler *sharedObject;
+(SettingsHandler *)sharedInstance{
    if(!sharedObject) sharedObject = [[self allocWithZone:NULL] init];
    return sharedObject;
}
-(id)valueForSetting:(KPSettings)setting{
    

    return nil;
}
-(void)setValue:(id)value forSetting:(KPSettings)setting{
    
}
@end
