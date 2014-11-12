//
//  YoureAllDoneView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 08/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define kColor color(80,89,102,1)
#import <UIKit/UIKit.h>
@interface YoureAllDoneView : UIView

//@property (nonatomic) DateStampView *stampView;
@property (nonatomic) UIImageView *trompetView;
@property (nonatomic) UILabel *streakLabel;
@property (nonatomic) UILabel *shareItLabel;

@property (nonatomic) UILabel *signatureView;
@property (nonatomic) UILabel *swipesReferLabel;

-(void)setText:(NSString*)text;
@property (nonatomic) BOOL allDoneForToday;
@end
