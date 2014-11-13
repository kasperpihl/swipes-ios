//
//  EvernoteToDoProcessor.h
//  Swipes
//
//  Created by demosten on 2/24/14.
//
#import <ENSDK/ENSDK.h>
#import <ENSDK/Advanced/ENSDKAdvanced.h>
#import <Foundation/Foundation.h>

@interface EvernoteToDo: NSObject

@property (nonatomic, strong, readonly) NSString* title;
@property (nonatomic, assign, readonly) BOOL checked;
@property (nonatomic, assign, readonly) NSInteger position;

@end
@class EvernoteToDoProcessor;
typedef void (^EvernoteProcessorBlock)(EvernoteToDoProcessor *processor, NSError *error);

@interface EvernoteToDoProcessor : NSObject

+ (void)processorWithNoteRefString:(NSString *)noteRefString block:(EvernoteProcessorBlock)block;

@property (nonatomic) BOOL needUpdate;
@property (nonatomic, strong) ENNote* note;
@property (nonatomic) NSString *noteRefString;

- (NSArray *)toDoItems;
- (BOOL)updateToDo:(EvernoteToDo *)todo checked:(BOOL)checked;
- (BOOL)updateToDo:(EvernoteToDo *)updatedToDo title:(NSString *)title;
- (void)saveToEvernote:(SuccessfulBlock)block;
- (BOOL)addToDoWithTitle:(NSString *)title;

@end
