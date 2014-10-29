//
//  EvernoteIntegration.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ENSDK/Advanced/ENSDKAdvanced.h>

typedef void (^NoteListBlock)(EDAMNoteList *list, NSError *error);
typedef void (^NoteFindBlock)(NSArray *findNotesResults, NSError *error);
typedef void (^NoteBlock)(EDAMNote *note, NSError *error);
typedef void (^NoteDownloadBlock)(ENNote *note, NSError *error);
typedef void (^NoteUpdateBlock)(ENNoteRef *noteRef, NSError *error);
#define kEnInt [EvernoteIntegration sharedInstance]
extern NSString* const MONExceptionHandlerDomain;
extern const int MONNSExceptionEncounteredErrorCode;

@interface EvernoteIntegration : NSObject

+ (instancetype)sharedInstance;
+ (void)updateAPILimitIfNeeded:(NSError *)error;
+ (BOOL)isAPILimitReached;
+ (NSUInteger)minutesUntilAPILimitReset;
+ (NSString *)APILimitReachedMessage;
+ (NSString *)ENNoteRefToNSString:(ENNoteRef *)noteRef;
+ (ENNoteRef *)NSStringToENNoteRef:(NSString *)string;
+ (BOOL)isNoteRefString:(NSString *)string;

@property (nonatomic, assign) BOOL enableSync;
@property (nonatomic, assign) BOOL hasAskedForPermissions;
@property (nonatomic, strong) NSString *tagGuid;
@property (nonatomic, assign) NSInteger requestCounter;
@property (nonatomic, strong) NSString *tagName;
@property (nonatomic, assign) BOOL autoFindFromTag;
@property (nonatomic, strong) NSDate *rateLimit;
@property (nonatomic, assign) BOOL isAuthenticated;

- (void)authenticateEvernoteInViewController:(UIViewController*)viewController withBlock:(ErrorBlock)block;

- (void)updateNote:(EDAMNote*)note block:(NoteBlock)block;
- (void)fetchNoteWithGuid:(NSString *)guid block:(NoteBlock)block;
- (void)downloadNoteWithRef:(ENNoteRef *)noteRef block:(NoteDownloadBlock)block;
//- (void)fetchNotesForFilter:(EDAMNoteFilter*)filter offset:(NSInteger)offset maxNotes:(NSInteger)maxNotes block:(NoteListBlock)block;
- (void)findNotesWithSearch:(NSString *)search block:(NoteFindBlock)block;
- (void)updateNote:(ENNote*)note noteRef:(ENNoteRef *)noteRef block:(NoteUpdateBlock)block;

- (void)logout;

/* Caching of notes */
- (void)cacheClear;

@end
