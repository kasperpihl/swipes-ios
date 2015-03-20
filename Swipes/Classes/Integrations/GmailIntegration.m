//
//  GmailIntegration.m
//  Swipes
//
//  Created by demosten on 1/19/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#ifndef NOT_APPLICATION
#import "GlobalApp.h"
#endif

#import "UtilityClass.h"
#import "KPAttachment.h"
#import "SettingsHandler.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GmailAuthViewController.h"
#import "CoreSyncHandler.h"
#import "GmailSyncHandler.h"
#import "GmailIntegration.h"

NSString* const kSwipesMailboxLabelName = @"[Mailbox]/Add to Swipes"; // label name for Mailbox
NSString* const kSwipesLabelName = @"Add to Swipes"; // label name for normal Gmail integration

// instructions at https://code.google.com/p/google-api-objectivec-client/wiki/Introduction#Preparing_to_Use_the_Library
static NSString* const kClientID = @"336134475796-mqcavkepb80idm0qdacd2fhkf573r4cd.apps.googleusercontent.com";
static NSString* const kClientSecret = @"5heB-MAD5Qm-y1miBVic03cE";

// where to we store gmail integration data
static NSString* const kKeychainKeyName = @"swipes_gmail_integration";

static NSString* const kInboxLabelId = @"INBOX"; // do not change!
static NSUInteger const kMaxResults = 200; // how many results to retrieve

// caches
static NSString* const kKeyData = @"data";
static NSString* const kKeyDate = @"date";
static NSTimeInterval const kThreadArchieveTimeout = 300;

// json keys
static NSString* const kKeyJson = @"json:";
static NSString* const kKeyJsonEmail = @"email";
static NSString* const kKeyJsonThreadId = @"threadid";

@interface GmailIntegration ()

@property (nonatomic, strong) GTMOAuth2Authentication* googleAuth;
@property (nonatomic, strong) NSString* swipesLabelId;
@property (nonatomic, strong) NSString* emailAddress;
@property (nonatomic, strong) NSMutableDictionary* knownArchievedThreads;

@end

@implementation GmailIntegration

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _googleAuth = nil;
        _emailAddress = nil;
        _knownArchievedThreads = [NSMutableDictionary dictionary];
        _isUsingMailbox = [[kSettings valueForSetting:IntegrationGmailUsingMailbox] boolValue];
        self.labelName = _isUsingMailbox ? kSwipesMailboxLabelName : kSwipesLabelName;

        NSError* error;
        GTMOAuth2Authentication* auth = [GTMOAuth2ViewControllerTouch
                                         authForGoogleFromKeychainForName:kKeychainKeyName
                                         clientID:kClientID
                                         clientSecret:kClientSecret
                                         error:&error];
        if (!error) {
            _googleAuth = auth;
            [self emailAddressWithBlock:^(NSError *error) {
                if (nil != error)
                    [UtilityClass sendError:error type:@"gmail:cannot get user email address"];
            }];
        }
        
    }
    return self;
}

#pragma mark - IntegrationProvider

- (NSString *)integrationTitle
{
    return @"GMAIL";
}

- (NSString *)integrationSubtitle
{
    if (self.isAuthenticated) {
        return _emailAddress ? _emailAddress : LOCALIZE_STRING(@"Connected 1 account");
    }
    return LOCALIZE_STRING(@"Not connected");
}

- (NSString *)integrationIcon
{
    return iconString(@"integrationMail");
}

#pragma mark - Methods

- (BOOL)integrationEnabled
{
    return kGmInt.isAuthenticated;
}

- (void)setLabelName:(NSString *)labelName
{
    if ((nil == labelName) || [labelName isEqualToString:_labelName]) {
        return;
    }
    _labelName = labelName;
    _swipesLabelId = nil;
    if (_googleAuth) {
        [self createSwipesLabelIfNeededWithBlock:^(NSError *error) {
            if (nil != error)
                [UtilityClass sendError:error type:[NSString stringWithFormat:@"gmail:cannot create swipes label %@", labelName]];
        }];
    }
}

- (void)setIsUsingMailbox:(BOOL)isUsingMailbox
{
    _isUsingMailbox = isUsingMailbox;
    [kSettings setValue:@(_isUsingMailbox) forSetting:IntegrationGmailUsingMailbox];
    self.labelName = _isUsingMailbox ? kSwipesMailboxLabelName : kSwipesLabelName;
}

- (NSString *)threadIdToNSString:(NSString *)threadId
{
    if ((nil == threadId) || (nil == _emailAddress))
        return nil;

    NSMutableDictionary* jsonDict = [NSMutableDictionary dictionary];
    [jsonDict setObject:_emailAddress forKey:kKeyJsonEmail];
    [jsonDict setObject:threadId forKey:kKeyJsonThreadId];
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    if (error) {
        [UtilityClass sendError:error type:@"gmail:threadIdToNSString error"];
        return nil;
    }
    return [kKeyJson stringByAppendingString:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
}

- (NSString *)NSStringToThreadId:(NSString *)string
{
    NSError* error;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:[[string substringFromIndex:kKeyJson.length] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error) {
        [UtilityClass sendError:error type:@"gmail:NSStringToThreadId error"];
        return nil;
    }
    return jsonDict[kKeyJsonThreadId];
}

- (NSString *)NSStringToEmail:(NSString *)string
{
    NSError* error;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:[[string substringFromIndex:kKeyJson.length] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error) {
        [UtilityClass sendError:error type:@"gmail:NSStringToThreadId error"];
        return nil;
    }
    return jsonDict[kKeyJsonEmail];
}

- (void)authenticateInViewController:(UIViewController*)viewController withBlock:(ErrorBlock)block
{
    NSError* error;
    GTMOAuth2Authentication* auth = [GTMOAuth2ViewControllerTouch
                                         authForGoogleFromKeychainForName:kKeychainKeyName
                                         clientID:kClientID
                                         clientSecret:kClientSecret
                                         error:&error];
    if (error) {
        GmailAuthViewController* vc = [GmailAuthViewController controllerWithScope:kGTLAuthScopeGmailModify clientID:kClientID clientSecret:kClientSecret keychainItemName:kKeychainKeyName completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error)
        {
            [viewController dismissViewControllerAnimated:NO completion:nil];
            if (nil == error) {
                _googleAuth = auth;
                [self createSwipesLabelIfNeededWithBlock:^(NSError *error) {
                    // TODO log error
                }];
            }
            block(error);
            DLog(@"Authenticated. Auth: %@, Error: %@", auth, error);
        }];
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [viewController presentViewController:nav animated:YES completion:nil];
    }
    else {
        _googleAuth = auth;
        block(error);
    }
}

- (BOOL)isAuthenticated
{
    return (_googleAuth != nil);
}

- (void)logout
{
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainKeyName];
    _googleAuth = nil;
    _swipesLabelId = nil;
    _emailAddress = nil;
    [[KPCORE gmailSyncHandler] setUpdatedAt:nil];
}

- (NSString *)emailAddress
{
    return _emailAddress;
}

- (void)createSwipesLabelIfNeededWithBlock:(ErrorBlock)block
{
    if (_swipesLabelId) {
        block(nil);
        return;
    }
    
    GTLQueryGmail* listLabels = [GTLQueryGmail queryForUsersLabelsList];
    GTLServiceGmail* service = [[GTLServiceGmail alloc] init];
    service.authorizer = _googleAuth;
    [service executeQuery:listLabels completionHandler:^(GTLServiceTicket *ticket, GTLGmailListLabelsResponse* object, NSError *error) {
        //DLog(@"queried - error: %@", error);
        if (error) {
            block(error);
        }
        else {
            BOOL hasSwipes = NO;
            if (object) {
                for (GTLGmailLabel* label in object.labels) {
                    //DLog(@"label: %@", label);
                    if (NSOrderedSame == [label.name caseInsensitiveCompare:_labelName]) {
                        _swipesLabelId = label.identifier;
                        hasSwipes = YES;
                        break;
                    }
                }
            }
            if (hasSwipes) {
                block(nil);
            }
            else {
                GTLQueryGmail* createLabel = [GTLQueryGmail queryForUsersLabelsCreate];
                GTLGmailLabel* label = [[GTLGmailLabel alloc] init];
                label.name = _labelName;
                label.labelListVisibility = @"labelShow";
                label.messageListVisibility = @"show";
                createLabel.label = label;
                GTLServiceGmail* serviceCreateLabel = [[GTLServiceGmail alloc] init];
                serviceCreateLabel.authorizer = _googleAuth;
                [serviceCreateLabel executeQuery:createLabel completionHandler:^(GTLServiceTicket *ticket, GTLGmailLabel* object, NSError *error) {
                    //DLog(@"queried - error: %@", error);
                    if (nil == error) {
                        _swipesLabelId = object.identifier;
                    }
                    block(error);
                }];
            }
        }
    }];
}

- (void)emailAddressWithBlock:(ErrorBlock)block
{
    // maybe we need a flag that we are currently doing this?
    if (_emailAddress) {
        block(nil);
        return;
    }
    
    GTLQueryGmail* getProfile = [GTLQueryGmail queryForUsersGetProfile];
    
    GTLServiceGmail* service = [[GTLServiceGmail alloc] init];
    service.authorizer = _googleAuth;
    [service executeQuery:getProfile completionHandler:^(GTLServiceTicket *ticket, GTLGmailProfile* profile, NSError *error) {
        if (!error) {
            _emailAddress = profile.emailAddress;
        }
        block(error);
    }];
}

- (void)doListThreads:(NSString *)query withBlock:(ThreadListBlock)block
{
    GTLQueryGmail* listThreads = [GTLQueryGmail queryForUsersThreadsList];
    listThreads.labelIds = @[_swipesLabelId];
    listThreads.maxResults = kMaxResults;
    listThreads.q = query;
    
    GTLServiceGmail* service = [[GTLServiceGmail alloc] init];
    service.authorizer = _googleAuth;
    [service executeQuery:listThreads completionHandler:^(GTLServiceTicket *ticket, GTLGmailListThreadsResponse* object, NSError *error) {
        block(nil == object ? nil : object.threads, error);
    }];
}

- (void)getThread:(NSString *)threadId format:(NSString*)format withBlock:(ThreadGetBlock)block
{
    if (nil == _googleAuth) {
        block(nil, [[NSError alloc] initWithDomain:@"Gmail not authenticated" code:701 userInfo:nil]);
    }
    GTLQueryGmail* getThread = [GTLQueryGmail queryForUsersThreadsGet];
    getThread.identifier = threadId;
    if (format) {
        getThread.format = format;
    }
    GTLServiceGmail* service = [[GTLServiceGmail alloc] init];
    service.authorizer = _googleAuth;
    [service executeQuery:getThread completionHandler:^(GTLServiceTicket *ticket, GTLGmailThread* thread, NSError *error) {
        //DLog(@"queried - thread:%@, error: %@", thread, error);
        block(thread, error);
    }];
}

- (void)listThreads:(NSString *)query withBlock:(ThreadListBlock)block
{
    if (nil == _googleAuth) {
        block(nil, [[NSError alloc] initWithDomain:@"Gmail not authenticated" code:701 userInfo:nil]);
    }
    
    [self emailAddressWithBlock:^(NSError *error) {
        if (error) {
            block(nil, error);
        }
        else {
            [self createSwipesLabelIfNeededWithBlock:^(NSError *error) {
                if (error) {
                    block(nil, error);
                }
                else {
                    [self doListThreads:query withBlock:block];
                }
            }];
        }
    }];
}

- (void)removeSwipesLabelFromThreadAndArchive:(NSString *)threadId withBlock:(ErrorBlock)block
{
    [self hasSwipesLabelThread:threadId block:^(BOOL hasSwipesLabel, NSError *error) {
        if (error)
            block(error);
        else {
            if (hasSwipesLabel) {
                GTLQueryGmail* modifyThread = [GTLQueryGmail queryForUsersThreadsModify];
                modifyThread.identifier = threadId;
                modifyThread.removeLabelIds = @[_swipesLabelId, kInboxLabelId];
                GTLServiceGmail* service = [[GTLServiceGmail alloc] init];
                service.authorizer = _googleAuth;
                [service executeQuery:modifyThread completionHandler:^(GTLServiceTicket *ticket, GTLGmailThread* thread, NSError *error) {
                    //DLog(@"queried - thread:%@, error: %@", thread, error);
                    block(error);
                }];
            }
            else
                block(nil);
        }
    }];
}

- (void)hasSwipesLabelThread:(NSString *)threadId block:(SuccessfulBlock)block {
    if (nil == _googleAuth) {
        block(NO, [[NSError alloc] initWithDomain:@"Gmail not authenticated" code:701 userInfo:nil]);
    }
    [self createSwipesLabelIfNeededWithBlock:^(NSError *error) {
        if (error) {
            block(NO, error);
        }
        else {
            [self getThread:threadId format:@"minimal" withBlock:^(GTLGmailThread *thread, NSError *error) {
                BOOL hasSwipesLabel = NO;
                if (nil == error) {
                    if (thread.messages && 0 < thread.messages.count) {
                        for (GTLGmailMessage* message in thread.messages) {
                            if (message.labelIds) {
                                for (NSString* labelId in message.labelIds) {
                                    if (_swipesLabelId && [labelId isEqualToString:_swipesLabelId]) {
                                        hasSwipesLabel = YES;
                                        break;
                                    }
                                }
                            }
                            if (hasSwipesLabel)
                                break;
                        }
                    }
                }
                block(hasSwipesLabel, error);
            }];
        }
    }];
}

- (void)checkArchievedThread:(NSString *)threadId block:(SuccessfulBlock)block {
    __block BOOL isArchieved = [self cacheIsArchieved:threadId];
    if (isArchieved) {
        block(isArchieved, nil);
    }
    else {
        [self getThread:threadId format:@"minimal" withBlock:^(GTLGmailThread *thread, NSError *error) {
            if (nil == error) {
                isArchieved = YES;
                if (thread.messages && 0 < thread.messages.count) {
                    for (GTLGmailMessage* message in thread.messages) {
                        if (message.labelIds) {
                            for (NSString* labelId in message.labelIds) {
                                if ([labelId isEqualToString:kInboxLabelId] || (_swipesLabelId && [labelId isEqualToString:_swipesLabelId])) {
                                    isArchieved = NO;
                                    break;
                                }
                            }
                        }
                        if (!isArchieved)
                            break;
                    }
                }
                [self cacheAddToArchieved:threadId isArchieved:isArchieved];
            }
            block(isArchieved, error);
        }];
    }
}

- (void)cacheAddToArchieved:(NSString *)threadId isArchieved:(BOOL)isArchieved {
    _knownArchievedThreads[threadId] = @{kKeyData: @(isArchieved), kKeyDate: [NSDate dateWithTimeIntervalSinceNow:kThreadArchieveTimeout]};
}

- (BOOL)cacheIsArchieved:(NSString *)threadId {
    // purge old entries
    NSDate* now = [NSDate date];
    for (NSString* key in [_knownArchievedThreads allKeys]) {
        NSDictionary* data = _knownArchievedThreads[key];
        if (0 < [now timeIntervalSinceDate:data[kKeyDate]]) {
            [_knownArchievedThreads removeObjectForKey:key];
        }
    }
    
    return [_knownArchievedThreads[threadId][kKeyData] boolValue];
}

#ifndef NOT_APPLICATION

- (MailOpenType)defaultMailOpenType
{
    if (kGmInt.isUsingMailbox && [GlobalApp isMailboxInstalled]) {
        return MailOpenTypeMailbox;
    }
    return MailOpenTypeInbox;
}

- (MailOpenType)mailOpenType
{
    MailOpenType result = [[kSettings valueForSetting:IntegrationGmailOpenType] unsignedIntegerValue];
    switch (result) {
        case MailOpenTypeMailbox:
            if (![GlobalApp isMailboxInstalled]) {
                return [self defaultMailOpenType];
            }
            break;
        case MailOpenTypeGmail:
            if (![GlobalApp isGoogleMailInstalled]) {
                return [self defaultMailOpenType];
            }
            break;
        case MailOpenTypeCloudMagic:
            if (![GlobalApp isCloudMagicInstalled]) {
                return [self defaultMailOpenType];
            }
            break;
        default:
            break;
    }
    return result;
}

- (void)openMail:(NSString *)identifier
{
    MailOpenType openType = [self mailOpenType];
    switch (openType) {
        case MailOpenTypeMailbox:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"dbx-mailbox://"]];
            break;
        case MailOpenTypeGmail: {
                NSString* urlString = [NSString stringWithFormat:@"googlegmail:///cv=%@/accountId=1&create-new-tab", [kGmInt NSStringToThreadId:identifier]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            }
            break;
        case MailOpenTypeCloudMagic: {
                NSString* urlString = [NSString stringWithFormat:@"cloudmagic://open?account_name=%@&thread_id=%@", [kGmInt NSStringToEmail:identifier], [kGmInt NSStringToThreadId:identifier]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            }
            break;
            
        default:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"message://"]];
            break;
    }
}

#endif

@end
