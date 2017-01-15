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
@end
