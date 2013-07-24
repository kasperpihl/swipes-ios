//
//  KPAddView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 24/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AddViewDelegate
-(void)pressedButtonWithTrimmedText:(NSString*)trimmedText;
-(void)pressedReturnWithTrimmedText:(NSString*)trimmedText;
@end
@interface KPAddView : UIView
@end
