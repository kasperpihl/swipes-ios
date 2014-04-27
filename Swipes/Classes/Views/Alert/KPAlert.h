//
//  KPAlert.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 08/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPModal.h"

@interface KPAlert : KPModal
+(void)alertInView:(UIView*)view title:(NSString*)title message:(NSString*)message block:(SuccessfulBlock)block;
+(KPAlert*)alertWithFrame:(CGRect)frame title:(NSString *)title message:(NSString *)message block:(SuccessfulBlock)block;
@end
