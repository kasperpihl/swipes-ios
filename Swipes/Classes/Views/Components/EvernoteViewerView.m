//
//  EvernoteViewerView.m
//  Swipes
//
//  Created by demosten on 1/20/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <ENMLUtility.h>
#import "KPBlurry.h"
#import "EvernoteViewerView.h"

#define kContentSpacingBottom 44

@interface EvernoteViewerView ()

@property (nonatomic, strong) UIWebView* webView;
@property (nonatomic,strong) UIButton* backButton;
@property (nonatomic,strong) UIButton* attachButton;

@end

@implementation EvernoteViewerView

- (id)initWithFrame:(CGRect)frame andGuid:(NSString *)guid
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = tcolor(BackgroundColor);

        CGFloat top = (OSVER >= 7) ? [Global statusBarHeight] : 0.f;
        
        // prepare webview
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, top, 320, frame.size.height - top - kContentSpacingBottom)];
        [self addSubview:_webView];

        // prepare back button
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(0, self.frame.size.height - 44, 44, 44);
        [_backButton setImage:[UIImage imageNamed:timageStringBW(@"backarrow_icon")] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(pressedBack:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        // prepare attach button
        _attachButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _attachButton.frame = CGRectMake(44, self.frame.size.height - 44, 44, 44);
        [_attachButton setImage:[UIImage imageNamed:timageStringBW(@"checkmark_icon")] forState:UIControlStateNormal];
        [_attachButton addTarget:self action:@selector(pressedAttach:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_attachButton];
        
        // load the note
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [[EvernoteNoteStore noteStore] getNoteWithGuid:guid withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *note) {
            ENMLUtility *utltility = [[ENMLUtility alloc] init];
                [utltility convertENMLToHTML:note.content withResources:note.resources completionBlock:^(NSString *html, NSError *error) {
                    if (nil == error) {
                        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Assets/"];
                        NSURL* dirUrl = [NSURL fileURLWithPath:path isDirectory:YES];
                        
                        NSString* fullHTML = [NSString stringWithFormat:@"<html><head><link type=\"text/css\" rel=\"stylesheet\" href=\"css/style.css\"></head>%@</html>", html];
                        //NSString* fullHTML = html;
                        //DLog(@"HTML:\n%@", fullHTML);
                        [_webView loadHTMLString:fullHTML baseURL:dirUrl];
                    }
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                }];
            }
            failure:^(NSError *error) {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                NSLog(@"Failed to get note : %@",error);
            }
        ];
    }
    return self;
}

-(void)pressedBack:(UIButton*)backButton
{
    [self.delegate onGetBack];
}

-(void)pressedAttach:(UIButton*)backButton
{
    [self.delegate onAttach];
}

-(void)dealloc
{
    [_webView removeFromSuperview];
    _webView = nil;
}

@end
