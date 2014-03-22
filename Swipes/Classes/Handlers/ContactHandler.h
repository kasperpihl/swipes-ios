//
//  ContactHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 14/03/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
#import "APContact.h"
#import "APAddressBook.h"
#import <Foundation/Foundation.h>
#define kContacts [ContactHandler sharedInstance]
@interface ContactHandler : NSObject
+(ContactHandler*)sharedInstance;
-(void)loadContactsWithBlock:(void (^)(NSArray *contacts, NSError *error))block;
@end
