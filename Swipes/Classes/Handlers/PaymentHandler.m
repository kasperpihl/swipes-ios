//
//  PaymentHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 23/11/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define plusMonthlyIdentifier @"plusMonthlyTier1"
#define plusYearlyIdentifier @"plusYearlyTier10"
#import "PaymentHandler.h"
#import "RMStore.h"
#import "MF_Base64Additions.h"
#import <Parse/Parse.h>


@interface PaymentHandler ()
@property SKProductsRequest *productsRequest;
@property SKProduct *_plusMonthly;
@property SKProduct *_plusYearly;
@end
@implementation PaymentHandler
static PaymentHandler *sharedObject;
+(PaymentHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[PaymentHandler allocWithZone:NULL] init];
        [sharedObject requestProductsWithBlock:nil];
    }
    return sharedObject;
}
-(void)requestProductsWithBlock:(PlusBlock)block{
    if(self._plusMonthly && self._plusYearly){
        if(block) block(self._plusMonthly,self._plusYearly,nil);
        return;
    }
    NSSet *products = [NSSet setWithArray:@[plusMonthlyIdentifier, plusYearlyIdentifier]];
    [[RMStore defaultStore] requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        for(SKProduct *product in products){
            if([product.productIdentifier isEqualToString:plusMonthlyIdentifier]) self._plusMonthly = product;
            else if([product.productIdentifier isEqualToString:plusYearlyIdentifier]) self._plusYearly = product;
        }
        if(block) block(self._plusMonthly,self._plusYearly,nil);
    } failure:^(NSError *error) {
        if(block) block(nil,nil,error);
    }];
    
    // we will release the request object in the delegate callback
}
-(void)requestPayment:(NSString*)identifier block:(SuccessfulBlock)block{
    [[RMStore defaultStore] addPayment:identifier user:kCurrent.objectId success:^(SKPaymentTransaction *transaction) {
        NSLog(@"reciept:%@",[transaction.transactionReceipt base64Encoding]);
        if(transaction.transactionReceipt){
            PFObject *purchase = [PFObject objectWithClassName:@"Payment"];
            purchase[@"type"] = @"ios";
            purchase[@"productIdentifier"] = identifier;
            purchase[@"transactionIdentifier"] = transaction.transactionIdentifier;
            purchase[@"transactionReceipt"] = [transaction.transactionReceipt base64Encoding];
            [purchase saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!succeeded){
                    [purchase saveEventually];
                }
                else{
                    
                }
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"upgrade userlevel" object:self];
            block(YES,nil);
        }
        else block(NO,nil);
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        block(NO,error);
    }];

}
-(void)requestPlusYearlyBlock:(SuccessfulBlock)block{
    [self requestPayment:plusYearlyIdentifier block:block];
}
-(void)requestPlusMonthlyBlock:(SuccessfulBlock)block{
    [self requestPayment:plusMonthlyIdentifier block:block];
}
-(void)restoreWithBlock:(void (^)(NSError *))errorBlock{
    [[RMStore defaultStore] restoreTransactionsOfUser:kCurrent.objectId onSuccess:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"upgrade userlevel" object:self];
        errorBlock(nil);
    } failure:^(NSError *error) {
        errorBlock(error);
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
