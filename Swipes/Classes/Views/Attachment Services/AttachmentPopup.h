//
//  AttachmentPopup.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 12/05/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, KPAttachmentButtons){
    KPAttachmentButtonCancel = 0,
    KPAttachmentButtonEvernote = 1,
    KPAttachmentButtonNote = 2
};
typedef void (^AttachmentPopupBlock)(KPAttachmentButtons button, NSString *title, NSString *identifier);
@interface AttachmentPopup : UIView
+(AttachmentPopup*)popupWithFrame:(CGRect)frame block:(AttachmentPopupBlock)block;
@end
