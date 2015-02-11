//
//  GmailThreadProcessor.m
//  Swipes
//
//  Created by demosten on 1/20/15.
//

#import "GmailIntegration.h"
#import "GmailThreadProcessor.h"

@implementation GmailThreadProcessor {
    GTLGmailThread* _thread;
}

+ (void)processorWithThreadId:(NSString *)threadId block:(GmailThreadProcessorBlock)block
{
    __block GmailThreadProcessor *processor = [[GmailThreadProcessor alloc] initWithThreadId:threadId block:^(BOOL succeeded, NSError *error) {
        if (succeeded)
            block(processor, nil);
        else
            block(nil, error);
    }];
}

- (instancetype)initWithThreadId:(NSString *)threadId block:(SuccessfulBlock)block
{
    self = [super init];
    if (self) {
        _title = nil;
        _thread = nil;
        self.threadId = threadId;
        [kGmInt getThread:threadId format:nil withBlock:^(GTLGmailThread *thread, NSError *error) {
            _thread = thread;
            if (nil == error) {
                [self processTitle];
                block(YES, nil);
            }
            else {
                block(NO, error);
            }
        }];
    }
    return self;
}

- (void)processTitle
{
    if (_thread) {
        if (_thread.messages && 0 < _thread.messages.count) {
            GTLGmailMessage* message = _thread.messages[0];
            if (message.payload.headers) {
                for (GTLGmailMessagePartHeader* header in message.payload.headers) {
                    if (NSOrderedSame == [header.name compare:@"Subject" options:NSCaseInsensitiveSearch]) {
                        _title = header.value;
                        break;
                    }
                }
                if (_title) {
                    _snippet = message.snippet;
                    return;
                }
            }
            _title = message.snippet;
            return;
        }
    }
    _title = nil;
    
}

@end
