//
//  RootViewController.m
//  GoOut
//
//  Created by Kasper Pihl Tornøe on 24/08/12.
//
//

#import "RootViewController.h"
#import <Parse/Parse.h>
#import "FacebookCommunicator.h"
#import "SBSegmentedViewController.h"
#import "BacklogViewController.h"
#import "TodayViewController.h"
#import "DoneViewController.h"


@interface RootViewController () <UINavigationControllerDelegate>
@property (nonatomic,strong) SBSegmentedViewController *menuViewController;
@end

@implementation RootViewController
#pragma mark - Properties


#pragma mark - Public API
static RootViewController *sharedObject;
+(RootViewController *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[RootViewController allocWithZone:NULL] init];
    }
    return sharedObject;
}
-(void)changeToMenu:(NSString*)viewControllerString storyboard:(BOOL)storyboard identifier:(NSString*)identifier{
    UIViewController *viewController;
    self.navigationBarHidden = NO;
    NSString *vcClassName = [NSString stringWithFormat:@"%@ViewController",viewControllerString];
    if(storyboard){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        viewController = [storyboard instantiateViewControllerWithIdentifier:vcClassName];
    }
    else{
        Class class = NSClassFromString(vcClassName);
        if(!class) return;
        viewController = [[class alloc] init];
    }
    NSArray *viewControllers = @[viewController];
    [self setViewControllers:viewControllers];
}
-(void)setCurrentViewController:(UIViewController *)viewController atIndex:(NSInteger)index{
    if(self.viewControllers.count <= index) return;
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    UIViewController *currentViewController = [viewControllers lastObject];
    [viewControllers replaceObjectAtIndex:index withObject:viewController];
    viewController.view.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        viewController.view.alpha = 1;
        currentViewController.view.alpha = 0.0;
        self.viewControllers = [viewControllers subarrayWithRange:NSMakeRange(0, index+1)];
    } completion:^(BOOL finished) {
    }];
}
-(void)setupMenu{
    if(!self.menuViewController){
        BacklogViewController *vc1 = [[BacklogViewController alloc] initWithStyle:UITableViewStylePlain];
        
        TodayViewController *vc2 = [[TodayViewController alloc] initWithStyle:UITableViewStylePlain];
        
        DoneViewController *vc3 = [[DoneViewController alloc] initWithStyle:UITableViewStylePlain];
        SBSegmentedViewController *menuViewController = [[SBSegmentedViewController alloc] initWithViewControllers:@[vc1,vc2,vc3] titles:@[@"Backlog",@"Today",@"Done"]];
        menuViewController.position = SBSegmentedViewControllerControlPositionNavigationBar;
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pressedAdd:)];
        menuViewController.navigationItem.rightBarButtonItem = addButton;
        menuViewController.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        self.menuViewController = menuViewController;
        self.viewControllers = @[menuViewController];
    }
}

#pragma mark - Helping methods
#pragma mark - ViewController methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!sharedObject) sharedObject = self;
    [self setupMenu];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    clearNotify();
}
@end
