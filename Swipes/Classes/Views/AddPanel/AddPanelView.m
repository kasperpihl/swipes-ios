//
//  AddPanelView.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 20/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "AddPanelView.h"
#import "KPBlurry.h"
#import "UtilityClass.h"
#import "KPAddView.h"
#define ADD_VIEW_TAG 1
#define BACKGROUND_VIEW_TAG 2
#define PICKER_VIEW_TAG 3
#define TEXT_FIELD_TAG 4
#define DONE_EDITING_BUTTON_TAG 5
#define ANIMATION_DURATION 0.25f

#define SEPERATOR_SPACING 15

#define ADD_VIEW_HEIGHT GLOBAL_TEXTFIELD_HEIGHT
#define ADD_FIELD_HEIGHT 30


@interface AddPanelView () <AddViewDelegate,KPBlurryDelegate>
@property (nonatomic,weak) IBOutlet KPAddView *addView;
@property (nonatomic) BOOL shouldRemove;
@property (nonatomic) BOOL isRotated;
@end
@implementation AddPanelView
-(void)blurryWillShow:(KPBlurry *)blurry{
    [self.addView.textField becomeFirstResponder];
    [UIView animateWithDuration:0.25f animations:^{
        CGRectSetY(self.addView, self.frame.size.height-self.addView.frame.size.height-KEYBOARD_HEIGHT);
    }];
}
-(void)blurryWillHide:(KPBlurry *)blurry{
    [self.addView.textField resignFirstResponder];
    [UIView animateWithDuration:0.25f animations:^{
        CGRectSetY(self.addView, self.frame.size.height-self.addView.frame.size.height);
    }];
}
-(void)addView:(KPAddView *)addView enteredTrimmedText:(NSString *)trimmedText{
    if(self.addDelegate && [self.addDelegate respondsToSelector:@selector(didAddItem:)])
        [self.addDelegate didAddItem:trimmedText];
}
-(void)addViewPressedDoneButton:(KPAddView *)addView{
    [self.addDelegate closeAddPanel:self];
}        
-(BOOL)blurryShouldClose:(KPBlurry *)blurry{
    [self.addDelegate closeAddPanel:self];
    return NO;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        KPAddView *addView = [[KPAddView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, ADD_VIEW_HEIGHT)];
        addView.tag = ADD_VIEW_TAG;
        addView.userInteractionEnabled = YES;
        addView.backgroundColor = tbackground(MenuBackground);
        addView.textField.placeholder = @"Add a new task";
        addView.delegate = self;
        
        
        //[self.textField setValue:TEXT_FIELD_COLOR forKeyPath:@"_placeholderLabel.textColor"];
        [self addSubview:addView];
        
        
        self.addView = (KPAddView*)[self viewWithTag:ADD_VIEW_TAG];
        CGRectSetHeight(self, KEYBOARD_HEIGHT+self.addView.frame.size.height);
        CGRectSetY(self.addView, self.frame.size.height-self.addView.frame.size.height);
    }
    return self;
}
@end
