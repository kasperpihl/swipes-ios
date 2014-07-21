//
//  EvernoteIntegration.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^NoteListBlock)(EDAMNoteList *list, NSError *error);
typedef void (^NoteBlock)(EDAMNote *note, NSError *error);
#define kEnInt [EvernoteIntegration sharedInstance]
@interface EvernoteIntegration : NSObject
@property BOOL enableSync;
@property NSString *tagGuid;
@property NSString *tagName;
@property BOOL autoFindFromTag;
@property NSDate *rateLimit;
@property (nonatomic) BOOL isAuthenticated;
-(void)loadEvernoteIntegrationObject:(NSDictionary*)object;
+(EvernoteIntegration*)sharedInstance;
-(void)authenticateEvernoteInViewController:(UIViewController*)viewController withBlock:(ErrorBlock)block;

-(void)saveNote:(EDAMNote*)note block:(NoteBlock)block;
- (void)fetchNoteWithGuid:(NSString *)guid block:(NoteBlock)block;
-(void)fetchNotesForFilter:(EDAMNoteFilter*)filter offset:(NSInteger)offset maxNotes:(NSInteger)maxNotes block:(NoteListBlock)block;

@end
