//
//  KPLoginViewController.m
//  Swipes
//
//  Created by demosten on 10/6/15.
//  Copyright © 2015 Pihl IT. All rights reserved.
//

#import "SlackLoginViewController.h"
#import "KPLoginViewController.h"

@interface KPLoginViewController ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* sofiBottom;

@end

@implementation KPLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sofiBottom.constant = -175;
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(animateSofi:) userInfo:nil repeats:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)animateSofi:(NSTimer *)timer
{
    [self.view layoutIfNeeded];
    
    _sofiBottom.constant = -85;
    [UIView animateWithDuration:2
                     animations:^{
                         [self.view layoutIfNeeded]; // Called on parent view
                     }];
}

- (IBAction)onLoginWithSlack:(id)sender
{
    SlackLoginViewController* vc = [[SlackLoginViewController alloc] init];
    [self presentViewController:vc animated:YES completion:^{
        [vc loginWithClientId:@"10289009793.10670437991" clientSecret:@"b02fe024878b8e68fd5eeeb57fe3ebca" redirectURI:@"http://team.swipesapp.com/loginsuccess" scope:@"client" callback:^(NSDictionary *result, NSError *error) {
            NSLog(@"result: %@, error: %@", result, error);
            if (result && result[@"access_token"]) {
                DLog(@"token is: %@", result[@"access_token"]);
                if (self.delegate) {
                    [self.delegate loginViewController:self error:error];
                }
            }
        }];
        NSLog(@"completed");
    }];
}


@end
