//
//  KPPopup.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 07/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPPopup : UIView
@property (nonatomic,weak) IBOutlet UIView *containerView;
-(void)show:(BOOL)show completed:(SuccessfulBlock)block;
-(void)setContainerSize:(CGSize)size;
-(void)cancelled;
@end
