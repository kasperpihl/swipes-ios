//
//  ParseCommunicator.m
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPParseCommunicator.h"

@interface KPParseCommunicator ()
@property (nonatomic) dispatch_queue_t priorityQueue;
@property (nonatomic) dispatch_queue_t queue;
@end
@implementation KPParseCommunicator
static KPParseCommunicator *sharedObject;
+(KPParseCommunicator *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[KPParseCommunicator allocWithZone:NULL] init];
    }
    return sharedObject;
}
-(dispatch_queue_t)priorityQueue{
    if(!_priorityQueue){
        _priorityQueue = dispatch_queue_create([@"parsePriority" UTF8String], NULL);
    }
    return _priorityQueue;
}
-(dispatch_queue_t)queue{
    if(!_queue){
        _queue = dispatch_queue_create([@"parse" UTF8String], NULL);
    }
    return _queue;
}
-(void)runCloudFunction:(NSString *)functionName withOptions:(NSDictionary *)options priority:(BOOL)priority block:(ResultBlock)block{
    dispatch_queue_t queue = priority ? self.priorityQueue : self.queue;
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    dispatch_async(queue, ^{
        NSError *error;
        id result = [PFCloud callFunction:functionName withParameters:options error:&error];
        if(error){
            // Handling error
        }
        dispatch_async(currentQueue, ^{
            if(block) block(result,error);
        });
        
    });
}
-(void)downloadFile:(PFFile*)file priority:(BOOL)priority withCompletionBlock:(DataBlock)block{
    if (file) {
        if(file.isDataAvailable){
            block(KPDLResultSuccess,file.getData,nil);
            return;
        }
        if(priority){
            NSLog(@"file is downloading prior");
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if(!error) block(KPDLResultSuccess,data,error);
                else block(KPDLResultError,nil,error);
            }];
        }
        else{
            dispatch_queue_t queue = self.queue;
            dispatch_async(queue, ^{
                NSError *error;
                NSData *data = [file getData:&error];
                if(!error) block(KPDLResultSuccess,data,error);
                else block(KPDLResultError,nil,error);
            });
        }
    }
    else{
        block(KPDLResultError,nil,nil);
    }
}
-(void)uploadFile:(PFFile *)file withCompletionBlock:(void(^)(PFFile* file, NSError *error))completionBlock andProgressBlock:(void(^)(float progress))progressBlock{
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error || !succeeded){
            if(completionBlock) completionBlock(nil,error);
        }
        else if(completionBlock) completionBlock(file,nil);
    } progressBlock:^(int percentDone) {
        float percentFloat = (float)percentDone/100;
        if(progressBlock) progressBlock(percentFloat);
    }];
}
-(void)saveObject:(PFObject *)object priority:(BOOL)priority handler:(SuccessfulBlock)block{
    dispatch_queue_t queue = priority ? self.priorityQueue : self.queue;
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    dispatch_async(queue, ^{
        NSError *error;
        BOOL saved = [object save:&error];
        dispatch_async(currentQueue, ^{
            if(block) block(saved,error);
        });
    });
}
@end
