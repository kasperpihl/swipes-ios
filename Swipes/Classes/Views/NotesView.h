//
//  NotesView.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 03/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NotesView;
@protocol NotesViewDelegate <NSObject>
-(void)pressedCancelNotesView:(NotesView*)notesView;
-(void)savedNotesView:(NotesView*)notesView text:(NSString*)text;
@end
@interface NotesView : UIView
@property (nonatomic,weak) NSObject<NotesViewDelegate> *delegate;
-(void)setNotesText:(NSString*)notesText;
@end
