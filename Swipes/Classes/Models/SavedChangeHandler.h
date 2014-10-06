//
//  SavedChangeHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 05/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SavedChangeHandler : NSObject
@property (nonatomic) BOOL disableSync;
-(void)saveContextForSynchronization:(NSManagedObjectContext*)context;

@end
