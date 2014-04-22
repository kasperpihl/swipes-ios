//
//  PlusAlertView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 09/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPModal.h"

@interface PlusAlertView : KPModal
+(void)alertInView:(UIView*)view message:(NSString*)message block:(SuccessfulBlock)block;
+(PlusAlertView*)alertWithFrame:(CGRect)frame message:(NSString *)message block:(SuccessfulBlock)block;
@end
