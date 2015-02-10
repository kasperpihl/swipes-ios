//
//  AttachmentEditView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/01/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AttachmentEditView;
@protocol AttachmentEditViewDelegate <NSObject>
-(void)clickedAttachment:(AttachmentEditView*)attachmentView;
@end

@interface AttachmentEditView : UIView
@property (nonatomic,weak) NSObject <AttachmentEditViewDelegate> *delegate;
@property (nonatomic) NSString *service;
@property (nonatomic) NSString *identifier;

-(void)setIconString:(NSString*)iconString;
-(void)setTitleString:(NSString*)titleString;
-(void)setSyncString:(NSString*)syncString iconString:(NSString*)iconString;
@end
