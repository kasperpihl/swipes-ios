//
//  Global.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "Global.h"
#define iconCompare(target,result) if([iconString isEqualToString:target]) return result
@implementation Global

static NSString* const SHARED_GROUP_NAME = @"group.it.pihl.swipes";
static NSString* const DATABASE_NAME = @"swipes";
static NSString* const DATABASE_FOLDER = @"database";
static Global *sharedObject;

+(Global *)sharedInstance
{
    if (!sharedObject){
        sharedObject = [[Global allocWithZone:NULL] init];
    }
    return sharedObject;
}


-(CGFloat)fontMultiplier{
    if( !_fontMultiplier )
        _fontMultiplier = 1;
    return _fontMultiplier;
}

+(NSString *)iconStringForString:(NSString *)iconString{
    if(OSVER >= 7)
        return iconString;
    
    /* Widget icons */
    iconCompare(@"widgetAll",                   @"\ue662");
    iconCompare(@"widgetDone",                  @"\ue660");
    iconCompare(@"widgetAdd",                   @"\ue661");
    
    /* Notification bar */
    iconCompare(@"plusThick",                   @"\ue65f");
    iconCompare(@"arrowThick",                  @"\ue65b");
    
    /* Nav bar */
    iconCompare(@"settings",                    @"\ue601");
    iconCompare(@"done",                        @"\ue602");
    iconCompare(@"today",                       @"\ue603");
    iconCompare(@"later",                       @"\ue604");
    iconCompare(@"settingsFull",                @"\ue605");
    
    /* Edit mode */
    iconCompare(@"editNotes",                   @"\ue609");
    iconCompare(@"editRepeat",                  @"\ue60a");
    iconCompare(@"editTags",                    @"\ue60b");
    iconCompare(@"editSchedule",                @"\ue60c");
    iconCompare(@"editLocation",                @"\ue60d");
    iconCompare(@"editEvernote",                @"\ue65c");
    iconCompare(@"editActionRoundedArrow",      @"\ue65d");
    iconCompare(@"editActionRoundedPlus",       @"\ue65e");
    iconCompare(@"editSyncIcon",                @"\ue615");
    
    /* Social icons */
    iconCompare(@"twitter",                     @"\ue60e");
    iconCompare(@"facebook",                    @"\ue60f");
    iconCompare(@"twitterFull",                 @"\ue610");
    iconCompare(@"facebookFull",                @"\ue611");
    
    /* Menu icons */
    iconCompare(@"settingsPlus",                @"\ue613");
    iconCompare(@"settingsSync",                @"\ue632");
    iconCompare(@"settingsLogout",              @"\ue617");
    iconCompare(@"settingsSchedule",            @"\ue653");
    iconCompare(@"settingsTheme",               @"\ue618");
    iconCompare(@"settingsAccount",             @"\ue644");
    iconCompare(@"settingsPolicy",              @"\ue616");
    iconCompare(@"settingsFeedback",            @"\ue619");
    iconCompare(@"settingsWalkthrough",         @"\ue619");
    iconCompare(@"settingsNotification",        @"\ue61b");
    iconCompare(@"settingsIntegrations",        @"\ue659");
    
    /* Menu icons full */
    iconCompare(@"settingsLogoutFull",          @"\ue620");
    iconCompare(@"settingsThemeFull",           @"\ue61d");
    iconCompare(@"settingsAccountFull",         @"\ue648");
    iconCompare(@"settingsPlusFull",            @"\ue61e");
    iconCompare(@"settingsPolicyFull",          @"\ue61f");
    iconCompare(@"settingsFeedbackFull",        @"\ue621");
    iconCompare(@"settingsWalkthroughFull",     @"\ue622");
    iconCompare(@"settingsNotificationFull",    @"\ue624");
    
    /* Action menu awesomemenu */
    iconCompare(@"actionMenuIcon",              @"\ue651");
    iconCompare(@"actionMenuSettings",          @"\ue655");
    iconCompare(@"actionMenuSearch",            @"\ue656");
    iconCompare(@"actionMenuFilter",            @"\ue657");
    iconCompare(@"actionMenuSelect",            @"\ue658");
    
    /* Filter icons */
    iconCompare(@"filterPriority",              @"\ue65a");
    
    iconCompare(@"plus",                        @"\ue626");
    iconCompare(@"back",                        @"\ue63f");
    iconCompare(@"rightArrow",                  @"\ue628");
    iconCompare(@"roundClose",                  @"\ue629");
    iconCompare(@"roundAdd",                    @"\ue62a");
    iconCompare(@"roundBack",                   @"\ue62b");
    iconCompare(@"roundConfirm",                @"\ue62c");
    iconCompare(@"rightArrowFull",              @"\ue62d");
    iconCompare(@"roundCloseFull",              @"\ue62e");
    iconCompare(@"roundAddFull",                @"\ue62f");
    iconCompare(@"roundBackFull",               @"\ue630");
    iconCompare(@"roundConfirmFull",            @"\ue631");
    iconCompare(@"actionShare",                 @"\ue633");
    iconCompare(@"actionTag",                   @"\ue634");
    iconCompare(@"actionDelete",                @"\ue635");
    iconCompare(@"actionEdit",                  @"\ue636");
    iconCompare(@"actionAttach",                @"\ue637");
    iconCompare(@"actionShareFull",             @"\ue639");
    iconCompare(@"actionTagFull",               @"\ue63a");
    iconCompare(@"actionDeleteFull",            @"\ue63b");
    iconCompare(@"actionEditFull",              @"\ue63c");
    iconCompare(@"actionSearch",                @"\ue654");
    
    /* Schedule */
    iconCompare(@"scheduleCalendar",            @"\ue63d");
    iconCompare(@"scheduleLocation",            @"\ue63e");
    iconCompare(@"scheduleCloud",               @"\ue612");
    iconCompare(@"scheduleCircle",              @"\ue640");
    iconCompare(@"scheduleGlass",               @"\ue641");
    iconCompare(@"scheduleLogbook",             @"\ue652");
    iconCompare(@"scheduleSun",                 @"\ue643");
    iconCompare(@"scheduleMoon",                @"\ue638");
    iconCompare(@"scheduleCoffee",              @"\ue645");
    
    /* Schedule full*/
    iconCompare(@"scheduleCalendarFull",        @"\ue646");
    iconCompare(@"scheduleLocationFull",        @"\ue647");
    iconCompare(@"scheduleCloudFull",           @"\ue614");
    iconCompare(@"scheduleCircleFull",          @"\ue649");
    iconCompare(@"scheduleGlassFull",           @"\ue64a");
    iconCompare(@"scheduleLogbookFull",         @"\ue64b");
    iconCompare(@"scheduleSunFull",             @"\ue64c");
    iconCompare(@"scheduleMoonFull",            @"\ue61c");
    iconCompare(@"scheduleCoffeeFull",          @"\ue64e");
    
    /* Integrations */
    iconCompare(@"integrationEvernote",         @"\ue642");
    
    /* Integrations full */
    iconCompare(@"integrationEvernoteFull",     @"\ue64d");
    
    iconCompare(@"logo",                        @"\ue600");
    iconCompare(@"signature",                   @"\ue623");
    return iconString;
}
+(NSDateFormatter *)isoDateFormatter{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
    return dateFormatter;
}

+ (NSInteger)OSVersion
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

+(BOOL)is24Hour{
    static BOOL _is24hour = YES;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
        NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
        _is24hour = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
    });
    return _is24hour;
}

+(UILabel *)iconLabelWithString:(NSString *)iconString height:(CGFloat)height{
    UILabel *label = [[UILabel alloc] init];
    label.font = iconFont(height);
    label.backgroundColor = CLEAR;
    label.textAlignment = NSTextAlignmentCenter;
    [label setText:iconString(iconString)];
    [label sizeToFit];
    return label;
}

+(BOOL)supportsOrientation:(UIDeviceOrientation)orientation{
    NSArray *supportedOrientations = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISupportedInterfaceOrientations"];
    NSString *orientationString;
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            orientationString = @"UIInterfaceOrientationPortrait";
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientationString = @"UIInterfaceOrientationPortraitUpsideDown";
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientationString = @"UIInterfaceOrientationLandscapeLeft";
            break;
        case UIDeviceOrientationLandscapeRight:
            orientationString = @"UIInterfaceOrientationLandscapeRight";
            break;
        default:
            orientationString = @"Invalid Interface Orientation";
    }
    return [supportedOrientations containsObject:orientationString];
}

+ (NSURL *)coreDataUrl
{
    static NSURL *storeURL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storeURL = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:SHARED_GROUP_NAME] URLByAppendingPathComponent:DATABASE_FOLDER];
        #ifdef DEBUG
        if (nil == storeURL) {
            NSLog(@"Error getting storeURL! Check out provisioning profiles!");
            abort();
        }
        #endif
        [[NSFileManager defaultManager] createDirectoryAtURL:storeURL withIntermediateDirectories:YES attributes:nil error:nil];
        storeURL = [storeURL URLByAppendingPathComponent:DATABASE_NAME];
    });
    return storeURL;
}

+ (NSString *)applicationStorageDirectory
{
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
    return [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:applicationName];
}

+ (NSString *)filePathForStoreName:(NSString *)storeFileName
{
    NSArray *paths = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], [self applicationStorageDirectory], nil];
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    for (NSString *path in paths) {
        NSString *filepath = [path stringByAppendingPathComponent:storeFileName];
        if ([fm fileExistsAtPath:filepath]) {
            return path;
        }
    }
    
    return nil;
}

+ (void)initCoreData
{
    NSURL* coreDataURL = [Global coreDataUrl];
    NSFileManager *fm = [[NSFileManager alloc] init];
    if (![fm fileExistsAtPath:[coreDataURL path]]) {
        // move the database file if they exists
        NSString* oldPath = [self filePathForStoreName:DATABASE_NAME];
        if (oldPath) {
            NSArray* oldPathFiles = [fm contentsOfDirectoryAtPath:oldPath error:nil];
            if (oldPathFiles) {
                NSString* coreDataPath = [[[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:SHARED_GROUP_NAME]
                                            URLByAppendingPathComponent:DATABASE_FOLDER] path];
                for (NSString* oldFile in oldPathFiles) {
                    NSError* error = nil;
                    [fm moveItemAtPath:[oldPath stringByAppendingPathComponent:oldFile] toPath:[coreDataPath stringByAppendingPathComponent:oldFile] error:&error];
                    if (error) {
                        NSLog(@"Error moving old database: %@", error);
                    }
                }
                // try to move NSUserDefaults
                NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
                NSArray *keys = [[defs dictionaryRepresentation] allKeys];
                for (NSString* key in keys) {
                    [[self sharedDefaults] setObject:[defs objectForKey:key] forKey:key];
                }
//                NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
//                NSLog(@"%@", [[self sharedDefaults] dictionaryRepresentation]);
            }
        }
    }
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreAtURL:coreDataURL];
//    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"swipes"];
}
+(void)clearUserDefaults{
    NSDictionary *defaultsDictionary = [USER_DEFAULTS dictionaryRepresentation];
    for (NSString *key in [defaultsDictionary allKeys]) {
        [USER_DEFAULTS removeObjectForKey:key];
    }
    [USER_DEFAULTS synchronize];
}
+ (NSUserDefaults *)sharedDefaults
{
    static NSUserDefaults* sharedDefaults;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_NAME];
//        sharedDefaults = [NSUserDefaults standardUserDefaults];
    });
    return sharedDefaults;
}

@end
