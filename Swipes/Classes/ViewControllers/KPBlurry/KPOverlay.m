//
//  KPOverlay.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 04/09/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPOverlay.h"
@interface KPOverlay ()
@property (nonatomic,strong) NSMutableArray *views;
@end
@implementation KPOverlay
-(NSMutableArray *)views{
    if(!_views) _views = [NSMutableArray array];
    return _views;
}
static KPOverlay *sharedObject;
+(KPOverlay *)sharedInstance{
    if(!sharedObject) sharedObject = [[KPOverlay allocWithZone:NULL] init];
    return sharedObject;
}
-(void)pushView:(UIView *)view animated:(BOOL)animated{
    [self.views addObject:view];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:view];
}
-(void)popViewAnimated:(BOOL)animated{
    if(self.views.count == 0) return;
    UIView *lastView = (UIView*)[self.views lastObject];
    [lastView removeFromSuperview];
    [self.views removeObject:lastView];
}
-(void)popAllViewsAnimated:(BOOL)animated{
    for(NSInteger i = 0 ; i < self.views.count ; i++) [self popViewAnimated:animated];
}
@end
