//
//  EvernoteIntegration.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ENSDK/Advanced/ENSDKAdvanced.h>
#import "IntegrationProvider.h"

typedef void (^NoteFindBlock)(NSArray *findNotesResults, NSError *error);
typedef void (^NoteDownloadBlock)(ENNote *note, NSError *error);
typedef void (^NoteUpdateBlock)(ENNoteRef *noteRef, NSError *error);
#define kEnInt [EvernoteIntegration sharedInstance]
extern NSString* const MONExceptionHandlerDomain;
extern const int MONNSExceptionEncounteredErrorCode;

@interface EvernoteIntegration : NSObject <IntegrationProvider>

+ (instancetype)sharedInstance;
+ (void)updateAPILimitIfNeeded:(NSError *)error;
+ (BOOL)isAPILimitReached;
+ (NSUInteger)minutesUntilAPILimitReset;
+ (NSString *)APILimitReachedMessage;
+ (NSString *)ENNoteRefToNSString:(ENNoteRef *)noteRef;
+ (ENNoteRef *)NSStringToENNoteRef:(NSString *)string;
+ (BOOL)isNoteRefString:(NSString *)string;
+ (BOOL)isNoteRefJsonString:(NSString *)string;
+ (BOOL)hasNoteWithRef:(ENNoteRef *)noteRef;
+ (BOOL)isMovedOrDeleted:(NSError *)error;

@property (nonatomic, assign) BOOL enableSync;
@property (nonatomic, assign) BOOL autoFindFromTag;
@property (nonatomic, assign) BOOL findInPersonalLinked;
@property (nonatomic, assign) BOOL findInBusinessNotebooks;
@property (nonatomic, assign) BOOL hasAskedForPermissions;
@property (nonatomic, strong) NSDate *rateLimit;
@property (nonatomic, assign) NSInteger requestCounter;
@property (nonatomic, strong, readonly) NSString *tagGuid;
@property (nonatomic, strong, readonly) NSString *tagName;
@property (nonatomic, assign, readonly) BOOL isAuthenticated;
@property (nonatomic, assign, readonly) BOOL isAuthenticationInProgress;
@property (nonatomic, assign, readonly) BOOL isBusinessUser;
@property (nonatomic, assign, readonly) BOOL isPremiumUser;

- (void)authenticateEvernoteInViewController:(UIViewController*)viewController withBlock:(ErrorBlock)block;

- (void)downloadNoteWithRef:(ENNoteRef *)noteRef block:(NoteDownloadBlock)block;
//- (void)fetchNotesForFilter:(EDAMNoteFilter*)filter offset:(NSInteger)offset maxNotes:(NSInteger)maxNotes block:(NoteListBlock)block;
- (void)findNotesWithSearch:(NSString *)search block:(NoteFindBlock)block;
- (void)updateNote:(ENNote*)note noteRef:(ENNoteRef *)noteRef block:(NoteUpdateBlock)block;

- (void)logout;

/* Caching of notes */
- (void)cacheClear;

@end
