//
//  FacebookCommunicatorDelegate.h
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FacebookCommunicator;
@protocol FacebookCommunicatorDelegate
@optional
-(void)communicator:(FacebookCommunicator*)communicator receivedRequestWithResult:(id)result;
@required
-(void)communicator:(FacebookCommunicator*)communicator requestFailedWithError:(NSError*)error hasHandled:(BOOL)hasHandled;

@end
