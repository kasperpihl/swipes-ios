//
//  EvernoteToDoProcessor.h
//  EvernoteSDK_Test
//
//  Created by demosten on 2/24/14.
//

#import <Foundation/Foundation.h>

@interface EvernoteToDo: NSObject

@property (nonatomic, strong, readonly) NSString* title;
@property (nonatomic, assign, readonly) BOOL checked;
@property (nonatomic, assign, readonly) NSInteger position;

@end
@class EvernoteToDoProcessor;
typedef void (^EvernoteProcessorBlock)(EvernoteToDoProcessor *processor, NSError *error);

@interface EvernoteToDoProcessor : NSObject

+(void)processorWithGuid:(NSString*)guid block:(EvernoteProcessorBlock)block;

@property (nonatomic) BOOL needUpdate;
@property (nonatomic) NSString *guid;

- (NSArray *)toDoItems;
- (BOOL)updateToDo:(EvernoteToDo *)todo checked:(BOOL)checked;
- (BOOL)updateToDo:(EvernoteToDo *)updatedToDo title:(NSString *)title;
- (void)saveToEvernote:(SuccessfulBlock)block;
- (BOOL)addToDoWithTitle:(NSString *)title;

@end
