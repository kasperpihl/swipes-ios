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
@property (nonatomic,strong) UIButton *backButton;

@end

@implementation EvernoteViewerView

- (id)initWithFrame:(CGRect)frame andGuid:(NSString *)guid
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = tcolor(BackgroundColor);

        // prepare webview
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height - kContentSpacingBottom)];
        [self addSubview:_webView];

        // prepare back button
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(0, self.frame.size.height - 44, 44, 44);
        [_backButton setImage:[UIImage imageNamed:timageStringBW(@"backarrow_icon")] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(pressedBack:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
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

-(void)dealloc
{
    [_webView removeFromSuperview];
    _webView = nil;
}

@end
