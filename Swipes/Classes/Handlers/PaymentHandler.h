//
//  PaymentHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 23/11/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/SKProduct.h>
@interface SKProduct (LocalizedPrice)
-(NSString*)localizedPrice;
@end
@interface PaymentHandler : NSObject
+(PaymentHandler*)sharedInstance;
@end
