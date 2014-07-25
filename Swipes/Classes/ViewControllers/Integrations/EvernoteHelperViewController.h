//
//  EvernoteHelperViewController.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 21/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol EvernoteHelperDelegate <NSObject>
-(void)endedEvernoteHelperSuccessfully:(BOOL)success;
@end
@interface EvernoteHelperViewController : UIViewController
@property (nonatomic, weak) NSObject<EvernoteHelperDelegate> *delegate;
@end
