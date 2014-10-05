//
//  URLHandler.h
//  Swipes
//
//  Created by demosten on 7/28/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KPToDo;

@interface URLHandler : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) KPToDo* viewTodo;
@property (nonatomic, assign) BOOL addTodo;
// used to reset rootviewcontroller, added by kasper and used with widget when opening
@property (nonatomic, assign) BOOL reset;

- (BOOL)handleURL:(NSURL *)url;

@end
