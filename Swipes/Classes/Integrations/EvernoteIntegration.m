//
//  EvernoteIntegration.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
// TODO:
// - test with authorizing different account
// - add support to the account in json!
// - test with 2 accounts on 2 devices
// - sync should probably check for connection?

#import "MF_Base64Additions.h"
#import "UtilityClass.h"
#import "SettingsHandler.h"
#import "AnalyticsHandler.h"
#import "EvernoteIntegration.h"
#import "EvernoteSyncHandler.h"
#import "ENNoteRefInternal.h"
#import "CoreSyncHandler.h"
#import "KPAttachment.h"

// caches
static NSString* const kKeyData = @"data";
static NSString* const kKeyDate = @"date";

// json keys
static NSString* const kKeyJson = @"json:";
static NSString* const kKeyJsonGuid = @"guid";
static NSString* const kKeyJsonType = @"type";
static NSString* const kKeyJsonTypePersonal = @"personal";
static NSString* const kKeyJsonTypeShared = @"shared";
static NSString* const kKeyJsonTypeBusiness = @"business";
static NSString* const kKeyJsonLinkedNotebook = @"linkedNotebook";
static NSString* const kKeyJsonNotebookGuid = @"guid";
static NSString* const kKeyJsonNotebookNoteStoreUrl = @"url";
static NSString* const kKeyJsonNotebookShardId = @"shardid";
static NSString* const kKeyJsonNotebookSharedNotebookGlobalId = @"globalid";
static NSString* const kKeyJsonAndroidNoteGuid = @"noteguid";

static NSTimeInterval const kSearchTimeout = 300;
static NSTimeInterval const kNoteTimeout = 300;
static NSTimeInterval const kReadOnlyNoteTimeout = 10800; // 3 hours

static int32_t const kPaginator = 100;
static NSInteger const kApiLimitReachedErrorCode = 19;
static NSString * const kSwipesTagName = @"swipes";
static NSString * const kHasAskedForPermissionKey = @"HasAskedForEvernotePermission";
static NSString * const kEvernoteUpdateWaitUntilKey = @"EvernoteUpdateWaitUntil";
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

@interface EvernoteIntegration () <ENSDKLogging>

@property (nonatomic, assign) BOOL isAuthing;

@end

@implementation EvernoteIntegration {
    NSMutableDictionary* _searchCache;
    NSMutableDictionary* _noteRefCache;
    NSMutableDictionary* _readOnlyNoteRefCache;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        [USER_DEFAULTS setBool:IsEvernoteInstalled() forKey:@"isEvernoteInstalled"];
        [USER_DEFAULTS synchronize];
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
    if (nil == noteRef)
        return nil;
    // always provide new JSON string
    NSMutableDictionary* jsonDict = [NSMutableDictionary dictionary];
    [jsonDict setObject:noteRef.guid forKey:kKeyJsonGuid];
    switch (noteRef.type) {
        case ENNoteRefTypePersonal:
            jsonDict[kKeyJsonType] = kKeyJsonTypePersonal;
            break;
        case ENNoteRefTypeBusiness:
            jsonDict[kKeyJsonType] = kKeyJsonTypeBusiness;
            break;
        case ENNoteRefTypeShared:
            jsonDict[kKeyJsonType] = kKeyJsonTypeShared;
            break;
    }
    if (noteRef.linkedNotebook) {
        NSMutableDictionary* jsonLinkedNotebook = [NSMutableDictionary dictionary];
        if (noteRef.linkedNotebook.guid)
            jsonLinkedNotebook[kKeyJsonNotebookGuid] = noteRef.linkedNotebook.guid;
        if (noteRef.linkedNotebook.noteStoreUrl)
            jsonLinkedNotebook[kKeyJsonNotebookNoteStoreUrl] = noteRef.linkedNotebook.noteStoreUrl;
        if (noteRef.linkedNotebook.shardId)
            jsonLinkedNotebook[kKeyJsonNotebookShardId] = noteRef.linkedNotebook.shardId;
        if (noteRef.linkedNotebook.sharedNotebookGlobalId)
            jsonLinkedNotebook[kKeyJsonNotebookSharedNotebookGlobalId] = noteRef.linkedNotebook.sharedNotebookGlobalId;
        jsonDict[kKeyJsonLinkedNotebook] = jsonLinkedNotebook;
    }
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    if (error) {
        [UtilityClass sendError:error type:@"ENNoteRefToNSString error"];
        return nil;
    }
    return [kKeyJson stringByAppendingString:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
}

+ (ENNoteRef *)NSStringToENNoteRef:(NSString *)string
{
    if (![EvernoteIntegration isNoteRefJsonString:string]) {
        ENNoteRef* noteRef = [ENNoteRef noteRefFromData:[NSData dataWithBase64String:string]];
        if (nil == noteRef) {
            // this is the case of old Android BETA version of the data in form of
            // {"notebookguid":"74391953-86be-4789-83f5-6bb672facb58","noteguid":"ea67462c-ac4b-42e2-8a7e-0f1de6636b15"}
            // we cannot recall the version or disallow it, so we cover the case here instead of one time convertion
            NSError* error;
            NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
            if (!error && jsonDict[kKeyJsonAndroidNoteGuid]) {
                ENNoteRef* noteRef = [[ENNoteRef alloc] init];
                noteRef.guid = jsonDict[kKeyJsonAndroidNoteGuid];
                noteRef.type = ENNoteRefTypePersonal;
                return noteRef;
            }
        }
    }
    else if ([EvernoteIntegration isNoteRefJsonString:string]) {
        NSError* error;
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:[[string substringFromIndex:kKeyJson.length] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if (error) {
            [UtilityClass sendError:error type:@"NSStringToENNoteRef error" attachment:@{@"data" : string}];
            return nil;
        }
        
        ENNoteRef* noteRef = [[ENNoteRef alloc] init];
        noteRef.guid = jsonDict[kKeyJsonGuid];
        NSString* type = jsonDict[kKeyJsonType];
        if ([type isEqualToString:kKeyJsonTypeShared])
            noteRef.type = ENNoteRefTypeShared;
        else if ([type isEqualToString:kKeyJsonTypeBusiness])
            noteRef.type = ENNoteRefTypeBusiness;
        else
            noteRef.type = ENNoteRefTypePersonal;
        
        if (jsonDict[kKeyJsonLinkedNotebook]) {
            NSDictionary* jsonLinkedNotebook = jsonDict[kKeyJsonLinkedNotebook];
            noteRef.linkedNotebook = [[ENLinkedNotebookRef alloc] init];
            noteRef.linkedNotebook.guid = jsonLinkedNotebook[kKeyJsonNotebookGuid];
            noteRef.linkedNotebook.noteStoreUrl = jsonLinkedNotebook[kKeyJsonNotebookNoteStoreUrl];
            noteRef.linkedNotebook.shardId = jsonLinkedNotebook[kKeyJsonNotebookShardId];
            noteRef.linkedNotebook.sharedNotebookGlobalId = jsonLinkedNotebook[kKeyJsonNotebookSharedNotebookGlobalId];
        }
            
        return noteRef;
    }
    NSError* error = [NSError errorWithDomain:@"NSStringToENNoteRef invalid data" code:612 userInfo:nil];
    [UtilityClass sendError:error type:@"NSStringToENNoteRef error" attachment:@{@"data" : string}];
    return nil;
}

+ (BOOL)isNoteRefString:(NSString *)string
{
    return (string && (40 < string.length));
}

+ (BOOL)isNoteRefJsonString:(NSString *)string
{
    return (string && [string hasPrefix:kKeyJson]);
}

+ (BOOL)hasNoteWithRef:(ENNoteRef *)noteRef
{
    NSArray* allAttachments = [KPAttachment allIdentifiersForService:EVERNOTE_SERVICE sync:YES context:nil];
    for (NSString* attachmentString in allAttachments) {
        ENNoteRef* tempNote = [EvernoteIntegration NSStringToENNoteRef:attachmentString];
        if (tempNote && (tempNote.type == noteRef.type) && [tempNote.guid isEqualToString:noteRef.guid]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isMovedOrDeleted:(NSError *)error
{
    return ([error.domain isEqualToString:ENErrorDomain] && ((error.code == ENErrorCodeNotFound) || (error.code == ENErrorCodeDataConflict)));
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _searchCache = [NSMutableDictionary new];
        _noteRefCache = [NSMutableDictionary new];
        _readOnlyNoteRefCache = [NSMutableDictionary new];
        _autoFindFromTag = [[kSettings valueForSetting:IntegrationEvernoteSwipesTag] boolValue];
        _enableSync = [[kSettings valueForSetting:IntegrationEvernoteEnableSync] boolValue];
        _findInPersonalLinked = [[kSettings valueForSetting:IntegrationEvernoteFindInPersonalLinkedNotebooks] boolValue];
        _findInBusinessNotebooks = [[kSettings valueForSetting:IntegrationEvernoteFindInBusinessNotebooks] boolValue];
        self.hasAskedForPermissions = [USER_DEFAULTS boolForKey:kHasAskedForPermissionKey];
        //notify(ENSessionDidAuthenticateNotification, onAuthenticatedNotification);
        notify(ENSessionDidUnauthenticateNotification, onUnauthenticatedNotification);
        [ENSession sharedSession].logger = self;
    }
    return self;
}

- (void)dealloc
{
    clearNotify();
}

//- (void)onAuthenticatedNotification
//{
//    NSError* error = [NSError errorWithDomain:@"Evernote authenticated" code:607 userInfo:nil];
//    [UtilityClass sendError:error type:@"onAuthenticatedNotification"];
//}

- (void)onUnauthenticatedNotification
{
    NSError* error = [NSError errorWithDomain:@"Evernote unauthenticated" code:608 userInfo:nil];
    [UtilityClass sendError:error type:@"onUnauthenticatedNotification"];
}

#pragma mark - ENSDKLogging

- (void)evernoteLogInfoString:(NSString *)str
{
    DLog(@"EN info: %@", str);
}

- (void)evernoteLogErrorString:(NSString *)str
{
    NSError* error = [NSError errorWithDomain:str code:609 userInfo:nil];
    [UtilityClass sendError:error type:@"evernoteLogErrorString"];
    DLog(@"EN error: %@", str);
}

#pragma mark - IntegrationProvider

- (NSString *)integrationTitle
{
    return @"EVERNOTE";
}

- (NSString *)integrationSubtitle
{
    if (self.isAuthenticated) {
        return [ENSession sharedSession].userDisplayName;
    }
    return LOCALIZE_STRING(@"Not connected");
}

- (NSString *)integrationIcon
{
    return iconString(@"integrationEvernote");
}

- (BOOL)integrationEnabled
{
    return kEnInt.isAuthenticated;
}

#pragma mark - Methods

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
    [self cacheClear];
}

- (void)setFindInBusinessNotebooks:(BOOL)findInBusinessNotebooks
{
    _findInBusinessNotebooks = findInBusinessNotebooks;
    [kSettings setValue:@(findInBusinessNotebooks) forSetting:IntegrationEvernoteFindInBusinessNotebooks];
    [self cacheClear];
}

- (BOOL)isBusinessUser
{
    return [ENSession sharedSession].isBusinessUser;
}

-(BOOL)isPremiumUser
{
    return [ENSession sharedSession].isPremiumUser;
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

- (BOOL)isAuthenticationInProgress
{
    return [[ENSession sharedSession] isAuthenticationInProgress];
}

- (void)authenticateEvernoteInViewController:(UIViewController*)viewController withBlock:(ErrorBlock)block
{
    @try {
        [self handleError:[NSError errorWithDomain:@"Evernote authentication request" code:610 userInfo:nil] withType:@"Evernote authentication request"];
        ENSession *session = [ENSession sharedSession];
        [session authenticateWithViewController:viewController preferRegistration:NO completion:^(NSError *authenticateError) {
            if (authenticateError) {
                [self handleError:authenticateError withType:@"Evernote Auth Error"];
            }
            else {
                [self setEnableSync:YES];
                [self setHasAskedForPermissions:NO];
                [self setAutoFindFromTag:YES];
                NSString *userLevel = @"Standard";
                if(self.isPremiumUser)
                    userLevel = @"Premium";
                if(self.isBusinessUser)
                    userLevel = @"Business";
                [ANALYTICS trackEvent:@"Linked Evernote" options:@{@"Level": userLevel}];
                [ANALYTICS trackCategory:@"Integrations" action:@"Linked Evernote" label:userLevel value:nil];
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
    [[KPCORE evernoteSyncHandler] setUpdatedAt:nil];
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
#ifdef EVERNOTE_BUSINESS
    if (self.findInBusinessNotebooks) {
        scope |= ENSessionSearchScopeBusiness;
    }
#endif
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
            [self handleError:error withType:@"Evernote Download Note Error"];
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
    
    return _searchCache[text ? text : [NSNull null]][kKeyData];
}

- (void)cacheAddSearchResult:(NSArray *)findNotesResults forText:(NSString *)text
{
    if (text && ![text isKindOfClass:NSString.class]) {
        DLog(@"ERROR ERROR ERROR!!! Text is of class: %@", NSStringFromClass(text.class));
        NSError* error = [NSError errorWithDomain:@"Invalid class sent as text to cacheAddSearchResult:forText:" code:611 userInfo:nil];
        [UtilityClass sendError:error type:@"onUnauthenticatedNotification" attachment:@{@"class" : NSStringFromClass(text.class)}];
    }

    if (text && [text isKindOfClass:NSString.class] && [text containsString:@"updated:"])
        return; // these better not be cached
    _searchCache[text ? text : [NSNull null]] = @{kKeyData: findNotesResults, kKeyDate: [NSDate dateWithTimeIntervalSinceNow:kSearchTimeout]};
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
