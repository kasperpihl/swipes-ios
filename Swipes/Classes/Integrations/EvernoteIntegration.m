//
//  EvernoteIntegration.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "MF_Base64Additions.h"
#import "UtilityClass.h"
#import "SettingsHandler.h"
#import "EvernoteIntegration.h"

// caches

NSString* const kKeyData = @"data";
NSString* const kKeyDate = @"date";

NSTimeInterval const kSearchTimeout = 300;
NSTimeInterval const kNoteTimeout = (3600*24);
NSTimeInterval const kReadOnlyNoteTimeout = 10800; // 3 hours

int32_t const kPaginator = 100;
NSInteger const kApiLimitReachedErrorCode = 19;
NSString * const kSwipesTagName = @"swipes";
NSString * const kHasAskedForPermissionKey = @"HasAskedForEvernotePermission";
NSString * const kEvernoteUpdateWaitUntilKey = @"EvernoteUpdateWaitUntil";
NSString* const MONExceptionHandlerDomain = @"Exception";
int const MONNSExceptionEncounteredErrorCode = 119;

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

@property (nonatomic, assign) BOOL isAuthing;

@end

@implementation EvernoteIntegration {
    NSMutableDictionary* _searchCache;
    NSMutableDictionary* _noteCache;
    NSMutableDictionary* _noteRefCache;
    NSMutableDictionary* _readOnlyNoteRefCache;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        [ENSession setDisableRefreshingNotebooksCacheOnLaunch:YES]; // check is this better
    });
    return sharedInstance;
}

+ (void)updateAPILimitIfNeeded:(NSError *)error
{
    if (kApiLimitReachedErrorCode == error.code) {
        NSUInteger seconds = [((NSNumber *)error.userInfo[@"rateLimitDuration"]) unsignedIntegerValue];
        NSDate* willResetAt = [NSDate dateWithTimeIntervalSinceNow:seconds + 1];
        DLog(@"will reset at: %@", willResetAt);
        [USER_DEFAULTS setObject:willResetAt forKey:kEvernoteUpdateWaitUntilKey];
    }
}

+ (BOOL)isAPILimitReached
{
    NSDate* limitDate = [USER_DEFAULTS objectForKey:kEvernoteUpdateWaitUntilKey];
    if (nil == limitDate) {
        return NO;
    }
    BOOL result = [limitDate timeIntervalSinceNow] > 0;
    if (!result) {
        [USER_DEFAULTS removeObjectForKey:kEvernoteUpdateWaitUntilKey];
    }
    return result;
}

+ (NSUInteger)minutesUntilAPILimitReset
{
    if (![self.class isAPILimitReached]) {
        return 0;
    }
    NSDate* limitDate = [USER_DEFAULTS objectForKey:kEvernoteUpdateWaitUntilKey];
    if (nil == limitDate) {
        return 0;
    }
    return fabs([limitDate timeIntervalSinceNow] / 60);
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

+ (NSString *)ENNoteRefToNSString:(ENNoteRef *)noteRef
{
    return [[noteRef asData] base64String];
}

+ (ENNoteRef *)NSStringToENNoteRef:(NSString *)string
{
    return [ENNoteRef noteRefFromData:[NSData dataWithBase64String:string]];
}

+ (BOOL)isNoteRefString:(NSString *)string
{
    return (string && (40 < string.length));
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _searchCache = [NSMutableDictionary new];
        _noteCache = [NSMutableDictionary new];
        _noteRefCache = [NSMutableDictionary new];
        _readOnlyNoteRefCache = [NSMutableDictionary new];
        self.autoFindFromTag = [[kSettings valueForSetting:IntegrationEvernoteSwipesTag] boolValue];
        self.enableSync = [[kSettings valueForSetting:IntegrationEvernoteEnableSync] boolValue];
        self.findInPersonalLinked = [[kSettings valueForSetting:IntegrationEvernoteFindInPersonalLinkedNotebooks] boolValue];
        self.findInBusinessNotebooks = [[kSettings valueForSetting:IntegrationEvernoteFindInBusinessNotebooks] boolValue];
        self.hasAskedForPermissions = [USER_DEFAULTS boolForKey:kHasAskedForPermissionKey];
    }
    return self;
}

-(void)setHasAskedForPermissions:(BOOL)hasAskedForPermissions{
    _hasAskedForPermissions = hasAskedForPermissions;
    [USER_DEFAULTS setBool:hasAskedForPermissions forKey:kHasAskedForPermissionKey];
    [USER_DEFAULTS synchronize];
}

- (void)setEnableSync:(BOOL)enableSync
{
    _enableSync = enableSync;
    [kSettings setValue:@(enableSync) forSetting:IntegrationEvernoteEnableSync];
}

- (void)setAutoFindFromTag:(BOOL)autoFindFromTag
{
    _autoFindFromTag = autoFindFromTag;
//    if(autoFindFromTag){
//        [self swipesTagGuidBlock:^(NSString *string, NSError *error) {
//            if( string ){
//                self.tagGuid = string;
//                self.tagName = @"swipes";
//            }
//        }];
//    }
    [kSettings setValue:@(autoFindFromTag) forSetting:IntegrationEvernoteSwipesTag];
}

- (void)setFindInPersonalLinked:(BOOL)findInPersonalLinked
{
    _findInPersonalLinked = findInPersonalLinked;
    [kSettings setValue:@(findInPersonalLinked) forSetting:IntegrationEvernoteFindInPersonalLinkedNotebooks];
}

- (void)setFindInBusinessNotebooks:(BOOL)findInBusinessNotebooks
{
    _findInBusinessNotebooks = findInBusinessNotebooks;
    [kSettings setValue:@(findInBusinessNotebooks) forSetting:IntegrationEvernoteFindInBusinessNotebooks];
}

- (BOOL)isBusinessUser
{
    return [ENSession sharedSession].isBusinessUser;
}

- (void)updateNote:(EDAMNote*)note block:(NoteBlock)block
{
    NSError *error;
    ENNoteStoreClient *noteStore = [self primaryNoteStoreError:&error];
    if(error){
        return block(nil,error);
    }
    @try {
        self.requestCounter++;
        
        [noteStore updateNote:note success:^(EDAMNote *note) {
            if( block )
                block( note, nil );
            if (note.guid && note.guid.length > 0)
                [self cacheAddNote:note forGuid:note.guid];
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
    __block EDAMNote *cachedNote = [self cacheNoteForGuid:guid];
    if (cachedNote) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(cachedNote, nil);
        });
        return;
    }

    NSError *error;
    ENNoteStoreClient *noteStore = [self primaryNoteStoreError:&error];
    if(error){
        return block(nil,error);
    }
    
    @try {
        self.requestCounter++;
        [noteStore getNoteWithGuid:guid withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *note) {
            
            if( block )
                block( note , nil );
            
            [self cacheAddNote:note forGuid:guid];
            
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

- (ENNoteStoreClient *)primaryNoteStoreError:(NSError**)error
{
    ENSession *session = [ENSession sharedSession];
    if(!session.isAuthenticated){
        NSError* authError = [NSError errorWithDomain:@"Evernote not authenticated" code:601 userInfo:nil];
        *error = authError;
    }
    
    return [session primaryNoteStore];
}

- (BOOL)isAuthenticated
{
    return [[ENSession sharedSession] isAuthenticated];
}

- (void)authenticateEvernoteInViewController:(UIViewController*)viewController withBlock:(ErrorBlock)block
{
    @try {
        ENSession *session = [ENSession sharedSession];
        [session authenticateWithViewController:viewController preferRegistration:YES completion:^(NSError *authenticateError) {
            if(authenticateError) {
                [self handleError:authenticateError withType:@"Evernote Auth Error"];
            }
            else {
                [self setEnableSync:YES];
                [self setAutoFindFromTag:YES];
            }
            block(authenticateError);
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
    [[ENSession sharedSession] unauthenticate];
    [self cacheClear];
}

- (void)swipesTagGuidBlock:(StringBlock)block
{
    NSError *error;
    ENNoteStoreClient* noteStore = [self primaryNoteStoreError:&error];
    if (error) {
        return block(nil,error);
    }
    @try {
        __block NSString *swipesTagGuid;
        self.requestCounter++;
        [noteStore listTagsWithSuccess:^(NSArray *tags) {
            for ( EDAMTag *tag in tags ) {
                if (NSOrderedSame == [tag.name caseInsensitiveCompare:kSwipesTagName]){
                    swipesTagGuid = tag.guid;
                    break;
                }
            }
            
            if (!swipesTagGuid){
                [self createSwipesTagBlock:block inNoteStore:noteStore];
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


- (void)createSwipesTagBlock:(StringBlock)block inNoteStore:(ENNoteStoreClient *)noteStore
{
    @try {
        self.requestCounter++;
        EDAMTag *swipesTag = [[EDAMTag alloc] init];
        swipesTag.name = kSwipesTagName;
        [noteStore createTag:swipesTag success:^(EDAMTag *tag) {
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
        DLog(@"rate limit seconds: %@",[error.userInfo objectForKey:@"rateLimitDuration"]);
    }
    [UtilityClass sendError:error type:type];
    return NO;
}

#pragma mark - New API

- (void)findNotesWithSearch:(NSString *)search block:(NoteFindBlock)block
{
    // try to get it from cache
    NSArray *cachedFindNotesResults = [self cacheFindNotesResultsForText:search];
    if (cachedFindNotesResults) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(cachedFindNotesResults, nil);
        });
        return;
    }
    
    ENSession* session = [ENSession sharedSession];
    ENNoteSearch* noteSearch = [ENNoteSearch noteSearchWithSearchString:search];
    
    ENSessionSearchScope scope = ENSessionSearchScopePersonal;
    if (self.findInBusinessNotebooks) {
        scope |= ENSessionSearchScopeBusiness;
    }
    if (self.findInPersonalLinked) {
        scope |= ENSessionSearchScopePersonalLinked;
    }
    self.requestCounter++;
    [session findNotesWithSearch:noteSearch inNotebook:nil orScope:scope sortOrder:ENSessionSortOrderRecentlyUpdated maxResults:kPaginator completion:^(NSArray *findNotesResults, NSError *error) {
        
        if (!error) {
            [self cacheAddSearchResult:findNotesResults forText:search];
            block(findNotesResults, nil);
        }
        else {
            [self handleError:error withType:@"Evernote Find Notes Error"];
            block(nil, error);
        }
        
    }];
}

- (void)downloadNoteWithRef:(ENNoteRef *)noteRef block:(NoteDownloadBlock)block
{
    // try to get it from cache
    ENNote* cachedNote = [self cacheNoteForRef:noteRef];
    if (cachedNote) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(cachedNote, nil);
        });
        return;
    }
    
    ENSession* session = [ENSession sharedSession];
    self.requestCounter++;
    [session downloadNote:noteRef progress:nil completion:^(ENNote *note, NSError *error) {
        if (!error) {
            [self cacheAddNote:note forNoteRef:noteRef];
            block(note, nil);
        }
        else {
            [self handleError:error withType:@"Evernote Find Notes Error"];
            block(nil, error);
        }
    }];
}

- (void)updateNote:(ENNote*)note noteRef:(ENNoteRef *)noteRef block:(NoteUpdateBlock)block
{
    NSError* cacheError = [self cacheReadOnlyNoteForRef:noteRef];
    if (cacheError) {
        block(nil, nil);
        return;
    }
    
    self.requestCounter++;
    [[ENSession sharedSession] uploadNote:note policy:ENSessionUploadPolicyReplace toNotebook:nil orReplaceNote:noteRef progress:nil completion:^(ENNoteRef *newNoteRef, NSError *error) {
        if (nil == error) {
            [self cacheAddNote:note forNoteRef:newNoteRef];
            block(newNoteRef, nil);
        }
        else {
            NSNumber* errorCode = error.userInfo[@"EDAMErrorCode"];
            if (errorCode && (EDAMErrorCode_PERMISSION_DENIED == [errorCode integerValue])) {
                [self cacheAddReadOnlyNoteForRef:noteRef withError:error];
                block(nil, nil);
            }
            else {
                [self handleError:error withType:@"Evernote Update Note Error"];
                block(nil, error);
            }
        }
    }];
}

#pragma mark - Caches

- (void)cacheClear
{
    [_searchCache removeAllObjects];
    [_noteCache removeAllObjects];
    [_noteRefCache removeAllObjects];
    [_readOnlyNoteRefCache removeAllObjects];
}

- (NSArray *)cacheFindNotesResultsForText:(NSString *)text
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

- (void)cacheAddSearchResult:(NSArray *)findNotesResults forText:(NSString *)text
{
    _searchCache[text] = @{kKeyData: findNotesResults, kKeyDate: [NSDate dateWithTimeIntervalSinceNow:kSearchTimeout]};
}

- (EDAMNote *)cacheNoteForGuid:(NSString *)guid
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

- (void)cacheAddNote:(EDAMNote *)note forGuid:(NSString *)guid
{
    if (!note.content || note.content.length == 0)
        [self cacheRemoveNoteForGuid:guid];
    else
        _noteCache[guid] = @{kKeyData: note, kKeyDate: [NSDate dateWithTimeIntervalSinceNow:kNoteTimeout]};
}

- (void)cacheRemoveNoteForGuid:(NSString *)guid
{
    [_noteCache removeObjectForKey:guid];
}

- (ENNote *)cacheNoteForRef:(ENNoteRef *)noteRef
{
    // purge old entries
    NSDate* now = [NSDate date];
    for (NSString* key in [_noteRefCache allKeys]) {
        NSDictionary* data = _noteRefCache[key];
        if (0 < [now timeIntervalSinceDate:data[kKeyDate]]) {
            [_noteRefCache removeObjectForKey:key];
        }
    }
    
    return _noteRefCache[noteRef][kKeyData];
}

- (void)cacheAddNote:(ENNote *)note forNoteRef:(ENNoteRef *)noteRef
{
    if (!note.content)
        [self cacheRemoveNoteForRef:noteRef];
    else
        _noteRefCache[noteRef] = @{kKeyData: note, kKeyDate: [NSDate dateWithTimeIntervalSinceNow:kNoteTimeout]};
}

- (void)cacheRemoveNoteForRef:(ENNoteRef *)noteRef
{
    [_noteRefCache removeObjectForKey:noteRef];
}

- (NSError *)cacheReadOnlyNoteForRef:(ENNoteRef *)noteRef
{
    // purge old entries
    NSDate* now = [NSDate date];
    for (NSString* key in [_readOnlyNoteRefCache allKeys]) {
        NSDictionary* data = _readOnlyNoteRefCache[key];
        if (0 < [now timeIntervalSinceDate:data[kKeyDate]]) {
            [_readOnlyNoteRefCache removeObjectForKey:key];
        }
    }
    
    return _readOnlyNoteRefCache[noteRef][kKeyData];
}

- (void)cacheAddReadOnlyNoteForRef:(ENNoteRef *)noteRef withError:(NSError *)error
{
    _readOnlyNoteRefCache[noteRef] = @{kKeyData: error, kKeyDate: [NSDate dateWithTimeIntervalSinceNow:kReadOnlyNoteTimeout]};
}



@end
