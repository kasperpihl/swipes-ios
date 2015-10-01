//
//  SlackLoginViewController.m
//  Swipes
//
//  Created by demosten on 10/1/15.
//  Copyright © 2015 Pihl IT. All rights reserved.
//

#import "NSURL+QueryDictionary.h"
#import "SlackLoginViewController.h"

static NSString* const kSlackAuthURL = @"https://slack.com/oauth/authorize?";
static NSString* const kLetters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

@interface SlackLoginViewController () <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton* btnCancel;
@property (nonatomic, weak) IBOutlet UIWebView* webView;
@property (nonatomic, copy) SlackCallbackBlockDictionary callback;
@property (nonatomic, strong) NSString* state;
@property (nonatomic, strong) NSString* clientId;
@property (nonatomic, strong) NSString* clientSecret;
@property (nonatomic, strong) NSString* redirectURI;

@end

@implementation SlackLoginViewController


+(NSString *)randomStringWithLength:(int)len
{
    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [kLetters characterAtIndex: arc4random_uniform((unsigned int)kLetters.length)]];
    }
    return randomString;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webviewDidFinishAuthorization
{
    [_webView stopLoading];
    _webView.delegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)loginWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret redirectURI:(NSString *)redirectURI scope:(NSString *)scope callback:(SlackCallbackBlockDictionary)callback
{
    self.callback = callback;
    self.clientId = clientId;
    self.clientSecret = clientSecret;
    self.redirectURI = redirectURI;
    self.state = [self.class randomStringWithLength:8];
    
    NSMutableDictionary* params = @{@"client_id": clientId, @"state": self.state}.mutableCopy;
    if (redirectURI)
        params[@"redirect_uri"] = redirectURI;
    if (scope)
        params[@"scope"] = scope;
    NSString* urlString = [kSlackAuthURL stringByAppendingString:[SlackWebAPIClient serializeParams:params]];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (IBAction)onCancel:(id)sender
{
    [self webviewDidFinishAuthorization];
    if (self.callback) {
        self.callback(nil, nil);
    }
}

#pragma mark - Web View delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    NSLog(@"Loading: %@, nav type: %ld", request, navigationType);
//    NSLog(@"Host: %@, nav type: %ld", request, navigationType);
    if ([@"team.swipesapp.com" isEqualToString:request.URL.host]) {
        [self webviewDidFinishAuthorization];
        NSDictionary* dict = [request.URL uq_queryDictionary];
        if (!dict) {
            NSLog(@"bad URL: %@", request.URL);
        }
        if (![self.state isEqualToString:dict[@"state"]]) {
            NSLog(@"bad state: %@ != %@", self.state, dict[@"state"]);
        }
        
        SlackWebAPIClient* client = [SlackWebAPIClient new];
        [client oauthAccess:self.clientId clientSecret:self.clientSecret code:dict[@"code"] redirectURI:self.redirectURI callback:^(NSDictionary *result, NSError *error) {
            
            if (self.callback) {
                self.callback(result, error);
            }
            
        }];
        return NO;
    }
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self webviewDidFinishAuthorization];
    if (self.callback) {
        self.callback(nil, error);
    }
}

@end
