//
//  YoureAllDoneView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 08/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateStampView.h"
@interface YoureAllDoneView : UIView
@property (nonatomic) UILabel *shareItLabel;
@property (nonatomic) UILabel *youreDoneLabel;
@property (nonatomic) DateStampView *stampView;
@property (nonatomic) UIImageView *signatureView;
@property (nonatomic) UILabel *swipesReferLabel;
@end