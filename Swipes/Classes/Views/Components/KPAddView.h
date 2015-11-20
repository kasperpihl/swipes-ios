//
//  KPAddView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 24/07/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KPAddView;
@protocol AddViewDelegate <NSObject>
-(void)addView:(KPAddView*)addView enteredTrimmedText:(NSString*)trimmedText;
-(void)addViewPressedDoneButton:(KPAddView*)addView;
@end
@interface KPAddView : UIView
@property (nonatomic, strong) UIButton *doneEditingButton;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, weak) id<AddViewDelegate> delegate;
-(void)setText:(NSString*)text;
@end
