//
//  PaymentHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 23/11/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "PaymentHandler.h"
#import "CargoBay.h"
@interface PaymentHandler ()
@end
@implementation PaymentHandler
static PaymentHandler *sharedObject;
+(PaymentHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[PaymentHandler allocWithZone:NULL] init];
    }
    return sharedObject;
}
-(void)requestProducts{
    NSArray *identifiers = @[
                             @"com.example.myapp.apple",
                             @"com.example.myapp.pear",
                             @"com.example.myapp.banana"
                             ];
    
    [[CargoBay sharedManager] productsWithIdentifiers:[NSSet setWithArray:identifiers]
                                              success:^(NSArray *products, NSArray *invalidIdentifiers) {
                                                  NSLog(@"Products: %@", products);
                                                  NSLog(@"Invalid Identifiers: %@", invalidIdentifiers);
                                              } failure:^(NSError *error) {
                                                  NSLog(@"Error: %@", error);
                                              }];
}
@end


@implementation SKProduct (LocalizedPrice)

- (NSString *)localizedPrice
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    return formattedString;
}

@end
