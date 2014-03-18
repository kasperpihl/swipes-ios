//
//  ContactHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 14/03/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "ContactHandler.h"
@interface ContactHandler ()
@property (nonatomic) APAddressBook *ab;
@end
@implementation ContactHandler
static ContactHandler *sharedObject;
+(ContactHandler*)sharedInstance{
    if(!sharedObject) sharedObject = [[ContactHandler allocWithZone:NULL] init];
    return sharedObject;
}
-(APAddressBook *)ab{
    if(!_ab){
        _ab = [[APAddressBook alloc] init];
        _ab.fieldsMask = APContactFieldFirstName | APContactFieldLastName | APContactFieldPhones | APContactFieldEmails;
        _ab.filterBlock = ^BOOL(APContact *contact)
        {
            return (contact.phones.count > 0 | contact.emails.count > 0);
        };
        _ab.sortDescriptors = @[
            [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]
        ];
    }
    return _ab;
}
-(void)loadContactsWithBlock:(void (^)(NSArray *contacts, NSError *error))block{
    [self.ab loadContacts:^(NSArray *contacts, NSError *error) {
        if(block) block(contacts,error);
    }];
}

@end
