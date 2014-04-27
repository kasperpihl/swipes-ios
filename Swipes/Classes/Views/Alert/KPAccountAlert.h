//
//  KPAccountAlert.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 22/04/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "KPModal.h"

@interface KPAccountAlert : KPModal
+(void)alertInView:(UIView*)view message:(NSString*)message block:(SuccessfulBlock)block;
+(KPAccountAlert*)alertWithFrame:(CGRect)frame message:(NSString *)message block:(SuccessfulBlock)block;
@end
