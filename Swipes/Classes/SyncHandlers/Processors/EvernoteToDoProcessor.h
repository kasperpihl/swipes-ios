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
@property (nonatomic) NSString *guid;
+(void)processorWithGuid:(NSString*)guid block:(EvernoteProcessorBlock)block;
- (NSArray *)toDoItems;
- (BOOL)updateToDo:(EvernoteToDo *)todo checked:(BOOL)checked;

@end
