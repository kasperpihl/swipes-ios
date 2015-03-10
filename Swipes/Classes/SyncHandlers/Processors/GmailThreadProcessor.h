//
//  GmailThreadProcessor.h
//  Swipes
//
//  Created by demosten on 1/20/15.
//

#import <Foundation/Foundation.h>

@class GmailThreadProcessor;

typedef void (^GmailThreadProcessorBlock)(GmailThreadProcessor *processor, NSError *error);

@interface GmailThreadProcessor : NSObject

+ (void)processorWithThreadId:(NSString *)threadId block:(GmailThreadProcessorBlock)block;

@property (nonatomic, strong) NSString* threadId;
@property (nonatomic, strong, readonly) NSString* title;
@property (nonatomic, strong, readonly) NSString* snippet;

@end
