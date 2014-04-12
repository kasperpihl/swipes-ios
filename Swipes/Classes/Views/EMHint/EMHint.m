//
//  EMHintState.m
//  ModalStateOverviewTest
//
//  Created by Eric McConkie on 3/6/12.
/*
Copyright (c) 2012 Eric McConkie

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "EMHint.h"

@implementation EMHint
@synthesize hintDelegate;

#pragma mark ---------------------------------->> 
#pragma mark -------------->>private
-(void)_onTap:(UITapGestureRecognizer*)tap
{
    BOOL flag = YES;
    if ([self.hintDelegate respondsToSelector:@selector(hintStateShouldCloseIfPermitted:)]) {
        flag = [self.hintDelegate hintStateShouldCloseIfPermitted:self];
    }
    if(!flag)return;
    if ([self.hintDelegate respondsToSelector:@selector(hintStateWillClose:)]) {
        [self.hintDelegate hintStateWillClose:self];
    }
    [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseOut 
                     animations:^(){
                         [_modalView setAlpha:0.0];
                     } 
                     completion:^(BOOL finished){
                         [_modalView removeFromSuperview];
                         _modalView = nil;
                         if ([self.hintDelegate respondsToSelector:@selector(hintStateDidClose:)])
                         {
                             [self.hintDelegate hintStateDidClose:self];
                         }

                     }];
    
}

-(void)_addTap
{
    UITapGestureRecognizer *tap = tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onTap:)];
    [_modalView addGestureRecognizer:tap];
}

#pragma mark ---------------------------------->> 
#pragma mark -------------->>PUBLIC
-(void)clear
{
    [_modalView removeFromSuperview];
    _modalView = nil;
}
-(UIView*)modalView
{
    return _modalView;
}
-(void)presentModalMessage:(NSString*)message where:(UIView*)presentationPlace
{
    //incase we have many in a row
    if(_modalView!=nil)
        [self clear];
    
    if ([self.hintDelegate respondsToSelector:@selector(hintStateViewsToHint:)]) {
        NSArray *viewArray = [self.hintDelegate hintStateViewsToHint:self];
        if(viewArray!=nil)
            _modalView = [[EMHintsView alloc] initWithFrame:presentationPlace.frame forViews:viewArray];
    }
    
    if ([self.hintDelegate respondsToSelector:@selector(hintStateRectsToHint:)]) {
        NSArray* rectArray = [self.hintDelegate hintStateRectsToHint:self];
        if (rectArray != nil){
            _modalView = [[EMHintsView alloc] initWithFrame:presentationPlace.frame withRects:rectArray];
            if([self.hintDelegate respondsToSelector:@selector(titleForRect:index:)]){
                for (NSInteger i = 0 ; i < rectArray.count ; i++)
                {
                    NSValue *theRectObj = [rectArray objectAtIndex:i];
                    CGRect theRect = [theRectObj CGRectValue];
                    NSString *title = [self.hintDelegate titleForRect:theRect index:i];
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:_modalView.bounds];
                    titleLabel.text = title;
                    titleLabel.textColor = tcolorF(TextColor,ThemeDark);
                    titleLabel.backgroundColor = CLEAR;
                    titleLabel.font = KP_REGULAR(15);
                    [titleLabel sizeToFit];
                    BOOL above = (theRect.origin.y > (_modalView.frame.size.height/2));
                    CGFloat y;
                    if(above) y = theRect.origin.y - theRect.size.width - titleLabel.frame.size.height/2;
                    else y = theRect.origin.y + theRect.size.width + titleLabel.frame.size.height/2;
                    CGRectSetCenter(titleLabel, theRect.origin.x , y);
                    [_modalView addSubview:titleLabel];
                    
                    
                }
            }
        }
    }
    
    if (_modalView==nil)
        _modalView = [[EMHintsView alloc] initWithFrame:presentationPlace.frame];
    _modalView.alpha = 0;
    [_modalView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [presentationPlace addSubview:_modalView];
    
    UIView *v = nil;
    if ([[self hintDelegate] respondsToSelector:@selector(hintStateViewForDialog:)]) {
        v = [self.hintDelegate hintStateViewForDialog:self];
        [_modalView addSubview:v];
    }
    
    if(v==nil)//no custom subview
    {
        //label
        UIFont *ft = KP_REGULAR(18);
        CGSize sz = [message sizeWithFont:ft constrainedToSize:CGSizeMake(250, 1000)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(floorf(presentationPlace.center.x - sz.width/2),
                                                                   floorf(presentationPlace.center.y - sz.height/2),
                                                                   floorf(sz.width),
                                                                   floorf(sz.height +10
                                                                          ))];
        
        [label setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin
                                    | UIViewAutoresizingFlexibleRightMargin
                                    | UIViewAutoresizingFlexibleLeftMargin
                                    | UIViewAutoresizingFlexibleBottomMargin
                                    )];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:ft];
        label.textAlignment = NSTextAlignmentCenter;
        [label setText:message];
        [label setTextColor:[UIColor whiteColor]];
        [label setNumberOfLines:0];
        [label setLineBreakMode:NSLineBreakByWordWrapping];
        [_modalView addSubview:label];
    }
    
    if ([[self hintDelegate] respondsToSelector:@selector(hintStateHasDefaultTapGestureRecognizer:)]) {
        BOOL flag = [self.hintDelegate hintStateHasDefaultTapGestureRecognizer:self];
        if (flag) {
            [self _addTap];
        }
    }else
    {
        [self _addTap];
    }
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         [_modalView setAlpha:1.0];
                     }
                     completion:^(BOOL finished){
                         
                     }];
                                   
}
#pragma mark ---------------------------------->> 
#pragma mark -------------->>cleanup
- (void)dealloc {
}
@end
