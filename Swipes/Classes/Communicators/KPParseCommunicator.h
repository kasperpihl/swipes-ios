//
//  ParseCommunicator.h
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/PFObject.h>
#import <Parse/PFFile.h>
#import <Parse/PFCloud.h>
#import <Parse/PFUser.h>
typedef void (^PFObjectBlock) (PFObject *object, NSError *error);
#define PC [KPParseCommunicator sharedInstance]

@interface KPParseCommunicator : NSObject
+(KPParseCommunicator*)sharedInstance;
-(void)uploadFile:(PFFile *)file withCompletionBlock:(void(^)(PFFile* file, NSError *error))completionBlock andProgressBlock:(void(^)(float progress))progressBlock;
@end
