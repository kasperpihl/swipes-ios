//
//  GmailHelperViewController.h
//  Swipes
//
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GmailHelperDelegate <NSObject>
-(void)endedGmailHelperSuccessfully:(BOOL)success;
@end
@interface GmailHelperViewController : UIViewController
@property (nonatomic, weak) NSObject<GmailHelperDelegate> *delegate;
@end
