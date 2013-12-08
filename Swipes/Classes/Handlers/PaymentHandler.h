//
//  PaymentHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 23/11/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
typedef void (^PlusBlock)(SKProduct* plusMonthly, SKProduct *plusYearly, NSError *error);

@interface SKProduct (LocalizedPrice)
-(NSString*)localizedPrice;
@end
@interface PaymentHandler : NSObject
+(PaymentHandler*)sharedInstance;
-(void)requestProductsWithBlock:(PlusBlock)block;
-(void)requestPlusYearlyBlock:(SuccessfulBlock)block;
-(void)requestPlusMonthlyBlock:(SuccessfulBlock)block;
-(void)restoreWithBlock:(void (^)(NSError *error))errorBlock;
@end
