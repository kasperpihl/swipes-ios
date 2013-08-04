//
//  NotesView.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 03/06/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
#define BUTTON_BAR_HEIGHT (50)
#define kTitleHeight 50
#define kTitleTopPadding 1
#define kTextTopPadding 5
#define kContentSpacing 10

#import "NotesView.h"
#import "KPToolbar.h"
#import "KPBlurry.h"
#import "KPAlert.h"
@interface NotesView () <ToolbarDelegate,KPBlurryDelegate>
@property (nonatomic,strong) UITextView *notesView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) KPToolbar *toolbar;
@property (nonatomic) NSString *originalString;
@end
@implementation NotesView
-(void)blurryWillShow:(KPBlurry *)blurry{
    [self.notesView becomeFirstResponder];
    [self showToolbar:YES];
}
-(void)blurryWillHide:(KPBlurry *)blurry{
    if([self.notesView isFirstResponder]) [self.notesView resignFirstResponder];
    [self showToolbar:NO];
}
-(void)showToolbar:(BOOL)show{
    /*CGFloat yPosition = self.frame.size.height - BUTTON_BAR_HEIGHT;
    if(show) yPosition -= KEYBOARD_HEIGHT;
    [UIView animateWithDuration:0.25f animations:^{
        CGRectSetY(self.toolbar, yPosition);
    }];*/
}
- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = tbackground(TaskTableBackground);
        
        self.toolbar = [[KPToolbar alloc] initWithFrame:CGRectMake(0, 0/*self.frame.size.height-BUTTON_BAR_HEIGHT*/, 320, BUTTON_BAR_HEIGHT) items:@[@"cross_button",@"",@"",@"",@"",@"toolbar_check_icon"]];
        
        self.toolbar.backgroundColor = tbackground(MenuBackground);
        self.toolbar.delegate = self;
        [self addSubview:self.toolbar];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kContentSpacing, kTitleTopPadding, self.bounds.size.width-2*kContentSpacing, kTitleHeight-kTitleTopPadding)];
        titleLabel.backgroundColor = CLEAR;
        titleLabel.textColor = tcolor(TagColor);
        titleLabel.font = KP_SEMIBOLD(22);
        titleLabel.numberOfLines = 1;
        titleLabel.text = @"NOTE";
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UITextView *notesView = [[UITextView alloc] initWithFrame:CGRectMake(kContentSpacing, kTitleHeight + kTextTopPadding, 320-2*kContentSpacing, self.frame.size.height-kTitleHeight-BUTTON_BAR_HEIGHT-KEYBOARD_HEIGHT)];
        notesView.backgroundColor = CLEAR;
        notesView.font = NOTES_VIEW_FONT;
        notesView.keyboardAppearance = UIKeyboardAppearanceAlert;
        notesView.textColor = tcolor(TagColor);
        [self addSubview:notesView];
        self.notesView = notesView;
        
    }
    return self;
}
-(void)toolbar:(KPToolbar *)toolbar pressedItem:(NSInteger)item{
    if(item == 0){
        [self.delegate pressedCancelNotesView:self];
    }else if(item == 5){
        [self.delegate savedNotesView:self text:self.notesView.text];
    }
}
-(void)setNotesText:(NSString*)notesText title:(NSString *)title{
    self.notesView.text = notesText;
    //self.titleLabel.text = title;
}
-(void)dealloc{
    self.toolbar = nil;
    self.notesView = nil;
    self.titleLabel = nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
