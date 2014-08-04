//
//  EvernoteIntegration.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#import "UtilityClass.h"
#import "SettingsHandler.h"
#import "EvernoteIntegration.h"

// caches
NSString* const kKeyData = @"data";
NSString* const kKeyDate = @"date";
NSTimeInterval const kSearchTimeout = 120;
NSTimeInterval const kNoteTimeout = 120;

int32_t const kPaginator = 100;
NSInteger const kApiLimitReachedErrorCode = 19;
NSString * const kSwipesTagName = @"swipes";
NSString * const kEvernoteUpdateWaitUntilKey = @"EvernoteUpdateWaitUntil";
NSString* const MONExceptionHandlerDomain = @"Exception";
const int MONNSExceptionEncounteredErrorCode = 119;
NSError * NewNSErrorFromException(NSException * exc) {
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    [info setValue:exc.name forKey:@"MONExceptionName"];
    [info setValue:exc.reason forKey:@"MONExceptionReason"];
    [info setValue:exc.callStackReturnAddresses forKey:@"MONExceptionCallStackReturnAddresses"];
    [info setValue:exc.callStackSymbols forKey:@"MONExceptionCallStackSymbols"];
    [info setValue:exc.userInfo forKey:@"MONExceptionUserInfo"];
    
    return [[NSError alloc] initWithDomain:MONExceptionHandlerDomain code:MONNSExceptionEncounteredErrorCode userInfo:info];
}

@interface EvernoteIntegration ()

@property BOOL isAuthing;

@end

@implementation EvernoteIntegration {
    NSMutableDictionary* _searchCache;
    NSMutableDictionary* _noteCache;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)updateAPILimitIfNeeded:(NSError *)error
{
    if (kApiLimitReachedErrorCode == error.code) {
        NSUInteger seconds = [((NSNumber *)error.userInfo[@"rateLimitDuration"]) unsignedIntegerValue];
        NSDate* willResetAt = [NSDate dateWithTimeIntervalSinceNow:seconds + 1];
        NSLog(@"will reset at: %@", willResetAt);
        [[NSUserDefaults standardUserDefaults] setObject:willResetAt forKey:kEvernoteUpdateWaitUntilKey];
    }
}

+ (BOOL)isAPILimitReached
{
    NSDate* limitDate = [[NSUserDefaults standardUserDefaults] objectForKey:kEvernoteUpdateWaitUntilKey];
    if (nil == limitDate) {
        return NO;
    }
    BOOL result = [limitDate timeIntervalSinceNow] > 0;
    if (!result) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEvernoteUpdateWaitUntilKey];
    }
    return result;
}

+ (NSUInteger)minutesUntilAPILimitReset
{
    if (![self.class isAPILimitReached]) {
        return 0;
    }
    NSDate* limitDate = [[NSUserDefaults standardUserDefaults] objectForKey:kEvernoteUpdateWaitUntilKey];
    if (nil == limitDate) {
        return 0;
    }
    return fabs([limitDate timeIntervalSinceNow] / 60);;
}

+ (NSString *)APILimitReachedMessage
{
    NSUInteger minutes = [self.class minutesUntilAPILimitReset];
    NSString* message;
    if (2 > minutes) {
        message = @"Evernote usage limit reached! Try again in a minute.";
    }
    else {
        message = [NSString stringWithFormat:@"Evernote usage limit reached! Try again in %lu minutes.", (unsigned long)minutes];
    }
    return message;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _searchCache = [NSMutableDictionary new];
        _noteCache = [NSMutableDictionary new];
        self.autoFindFromTag = [[kSettings valueForSetting:IntegrationEvernoteSwipesTag] boolValue];
        self.enableSync = [[kSettings valueForSetting:IntegrationEvernoteEnableSync] boolValue];

        //NSDictionary *currentIntegration = (NSDictionary*)[kSettings valueForSetting:IntegrationEvernote];
        //[self loadEvernoteIntegrationObject:currentIntegration];
    }
    return self;
}

- (void)setEnableSync:(BOOL)enableSync
{
    _enableSync = enableSync;
    [kSettings setValue:@(enableSync) forSetting:IntegrationEvernoteEnableSync];
}

- (void)setAutoFindFromTag:(BOOL)autoFindFromTag
{
    _autoFindFromTag = autoFindFromTag;
    if(autoFindFromTag){
        [self getSwipesTagGuidBlock:^(NSString *string, NSError *error) {
            if( string ){
                self.tagGuid = string;
                self.tagName = @"swipes";
            }
        }];
    }
    [kSettings setValue:@(autoFindFromTag) forSetting:IntegrationEvernoteSwipesTag];
}

- (void)loadEvernoteIntegrationObject:(NSDictionary *)object
{
    /*self.tagName = [object objectForKey:@"tagName"];
    self.tagGuid = [object objectForKey:@"tagGuid"];
    if(self.tagName || self.tagGuid)
        self.autoFindFromTag = YES;*/
}


- (void)saveNote:(EDAMNote*)note block:(NoteBlock)block
{
    @try {
        self.requestCounter++;
        [[EvernoteNoteStore noteStore] updateNote:note success:^(EDAMNote *note) {
            if( block )
                block( note, nil );
            if (note.guidIsSet)
                [self addNote:note forGuid:note.guid];
        } failure:^(NSError *error) {
            [self handleError:error withType:@"Evernote Update Note Error"];
            if( block)
                block( note , error);
        }];
    }
    @catch (NSException *exception) {
        NSError *error = NewNSErrorFromException(exception);
        block(nil, error);
        [UtilityClass sendException:exception type:@"Evernote Update Note Exception"];
    }
}


- (void)fetchNoteWithGuid:(NSString *)guid block:(NoteBlock)block
{
    // try to get it from cache
    __block EDAMNote *cachedNote = [self noteForGuid:guid];
    if (cachedNote) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(cachedNote, nil);
        });
        return;
    }
    
    @try {
        self.requestCounter++;
        [[EvernoteNoteStore noteStore] getNoteWithGuid:guid withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *note) {
            
            if( block )
                block( note , nil );
            
            [self addNote:note forGuid:guid];
            
        } failure:^(NSError *error) {
            [self handleError:error withType:@"Evernote Get Note Error"];
            if( block )
                block( nil , error );
        }];
    }
    @catch (NSException *exception) {
        NSError *error = NewNSErrorFromException(exception);
        block(nil, error);
        [UtilityClass sendException:exception type:@"Evernote Get Note Exception"];
    }
    
    
}

- (void)fetchNotesForFilter:(EDAMNoteFilter*)filter offset:(NSInteger)offset maxNotes:(NSInteger)maxNotes block:(NoteListBlock)block {
    
    // try to get it from cache
    
    /*__block EDAMNoteList *cachedList = [self searchListForText:filter.words ? filter.words : @""];
    if (cachedList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(cachedList, nil);
        });
        return;
    }*/
    
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    @try {
        self.requestCounter++;
        [noteStore findNotesWithFilter:filter offset:0 maxNotes:kPaginator success:^(EDAMNoteList *list) {
            [self addSearchList:list forText:filter.words ? filter.words : @""];
            block(list, nil);
        } failure:^(NSError *error) {
            [self handleError:error withType:@"Evernote Fetch Notes with Filter Error"];
            block(nil,error);
        }];
    }
    @catch (NSException *exception) {
        NSError *error = NewNSErrorFromException(exception);
        block(nil, error);
        [UtilityClass sendException:exception type:@"Evernote Fetch Notes with Filter Exception"];
    }
}

- (BOOL)isAuthenticated
{
    return [[EvernoteSession sharedSession] isAuthenticated];
}

- (void)authenticateEvernoteInViewController:(UIViewController*)viewController withBlock:(ErrorBlock)block
{
    @try {
        EvernoteSession *session = [EvernoteSession sharedSession];
        [session authenticateWithViewController:viewController completionHandler:^(NSError *error) {
            if(error) {
                [self handleError:error withType:@"Evernote Auth Error"];
            }
            else {
                [self setEnableSync:YES];
                [self setAutoFindFromTag:YES];
            }
            block(error);
        }];
    }
    @catch (NSException *exception) {
        NSError *error = NewNSErrorFromException(exception);
        block(error);
        [UtilityClass sendException:exception type:@"Evernote Auth Exception"];
    }
    
}

- (void)logout
{
    [[EvernoteSession sharedSession] logout];
    [self clearCaches];
}

- (void)getSwipesTagGuidBlock:(StringBlock)block
{
    if (!self.isAuthenticated) {
        block(nil, [NSError errorWithDomain:@"Evernote not authenticated" code:602 userInfo:nil]);
        return;
    }
    
    @try {
        __block NSString *swipesTagGuid;
        self.requestCounter++;
        [[EvernoteNoteStore noteStore] listTagsWithSuccess:^(NSArray *tags) {
            for ( EDAMTag *tag in tags ) {
                if (NSOrderedSame == [tag.name caseInsensitiveCompare:kSwipesTagName]){
                    swipesTagGuid = tag.guid;
                    break;
                }
            }
            
            if (!swipesTagGuid){
                [self createSwipesTagBlock:block];
            }
            else
                block(swipesTagGuid, nil);
        } failure:^(NSError *error) {
            if (error)
                [self handleError:error withType:@"Evernote Get Tags Error"];
            block(nil, error);
        }];
    }
    @catch (NSException *exception) {
        NSError *error = NewNSErrorFromException(exception);
        block(nil, error);
        [UtilityClass sendException:exception type:@"Evernote Get Tags Exception"];
    }
}


- (void)createSwipesTagBlock:(StringBlock)block
{
    @try {
        self.requestCounter++;
        EDAMTag *swipesTag = [[EDAMTag alloc] init];
        swipesTag.name = kSwipesTagName;
        [[EvernoteNoteStore noteStore] createTag:swipesTag success:^(EDAMTag *tag) {
            block(swipesTag.guid, nil);
        } failure:^(NSError *error) {
            if(error)
                [self handleError:error withType:@"Evernote Create Tag Error"];
            block(nil, error);
        }];
    }
    @catch (NSException *exception) {
        NSError *error = NewNSErrorFromException(exception);
        block(nil, error);
        [UtilityClass sendException:exception type:@"Evernote Create Tag Exception"];
    }
}

- (BOOL)handleError:(NSError*)error withType:(NSString*)type
{
    if (kApiLimitReachedErrorCode == error.code) {
        NSTimeInterval rateLimit = [[error.userInfo objectForKey:@"rateLimitDuration"] floatValue];
        if (0 < rateLimit){
            self.rateLimit = [NSDate dateWithTimeIntervalSinceNow:rateLimit + 10];
        }
        DLog(@"%@",[error.userInfo objectForKey:@"rateLimitDuration"]);
    }
    [UtilityClass sendError:error type:type];
    return NO;
}

#pragma mark - Caches

- (void)clearCaches
{
    [_searchCache removeAllObjects];
    [_noteCache removeAllObjects];
}

- (EDAMNoteList *)searchListForText:(NSString *)text
{
    // purge old entries
    NSDate* now = [NSDate date];
    for (NSString* key in [_searchCache allKeys]) {
        NSDictionary* data = _searchCache[key];
        if (0 < [now timeIntervalSinceDate:data[kKeyDate]]) {
            [_searchCache removeObjectForKey:key];
        }
    }
    
    return _searchCache[text][kKeyData];
}

- (void)addSearchList:(EDAMNoteList *)list forText:(NSString *)text
{
    _searchCache[text] = @{kKeyData: list, kKeyDate: [NSDate dateWithTimeIntervalSinceNow:kSearchTimeout]};
}

- (EDAMNote *)noteForGuid:(NSString *)guid
{
    // purge old entries
    NSDate* now = [NSDate date];
    for (NSString* key in [_noteCache allKeys]) {
        NSDictionary* data = _noteCache[key];
        if (0 < [now timeIntervalSinceDate:data[kKeyDate]]) {
            [_noteCache removeObjectForKey:key];
        }
    }
    
    return _noteCache[guid][kKeyData];
}

- (void)addNote:(EDAMNote *)note forGuid:(NSString *)guid
{
    _noteCache[guid] = @{kKeyData: note, kKeyDate: [NSDate dateWithTimeIntervalSinceNow:kNoteTimeout]};
}

- (void)removeNoteForGuid:(NSString *)guid
{
    [_noteCache removeObjectForKey:guid];
}

@end
