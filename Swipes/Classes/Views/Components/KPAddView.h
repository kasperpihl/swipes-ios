//
//  KPAddView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 24/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KPAddView;
@protocol AddViewDelegate
-(void)addView:(KPAddView*)addView enteredTrimmedText:(NSString*)trimmedText;
-(void)addViewPressedDoneButton:(KPAddView*)addView;
@end
@interface KPAddView : UIView
@property (nonatomic,weak) NSObject<AddViewDelegate> *delegate;
@property (nonatomic) IBOutlet UITextField *textField;
@end
