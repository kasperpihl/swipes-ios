//
//  OnboardingTopMenu.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 26/12/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "OnboardingTableViewCell.h"
#import "SlowHighlightIcon.h"
#import "OnboardingTopMenu.h"

#define kCellHeight 40
@interface OnboardingTopMenu () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *items;
@property (nonatomic) UIButton *clearButton;
@property (nonatomic) NSArray *selectedItems;
@end

@implementation OnboardingTopMenu

#pragma mark Public Interface
-(void)setDone:(BOOL)done animated:(BOOL)animated itemIndex:(NSInteger)itemIndex{
    
    OnboardingTableViewCell *cell = (OnboardingTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:itemIndex inSection:0]];
    DLog(@"cell%@",cell);
    if( cell ){
        
        [cell setDone:done animated:animated];
    }
}


#pragma mark Getters/Setters
-(void)setItems:(NSArray *)items{
    _items = items;
    [self reload];
}
-(void)setDelegate:(NSObject<OnboardingTopMenuDelegate> *)delegate{
    _delegate = delegate;
    [self fetchFromDelegate];
    [self reload];
}



#pragma mark UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"OnboardingCell";
    OnboardingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[OnboardingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView willDisplayCell:(OnboardingTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = [self.items objectAtIndex:indexPath.row];
    [cell setNumber:indexPath.row+1 text:title];
    BOOL selectCell = [self.selectedItems containsObject:title];
    [cell setDone:selectCell animated:NO];
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.delegate respondsToSelector:@selector(topMenu:didSelectItem:)])
        [self.delegate topMenu:self didSelectItem:indexPath.row];
    return nil;
}

-(void)reload{
    [self.tableView reloadData];
    CGRectSetHeight(self, self.items.count * kCellHeight + self.tableView.frame.origin.y + 10);
    [self.topMenuDelegate topMenu:self changedSize:self.frame.size];
}
-(void)fetchFromDelegate{
    self.items = [self.delegate itemsForTopMenu:self];
    NSMutableArray *selectedItems = [NSMutableArray array];
    for( int i = 0 ; i < self.items.count ; i++){
        NSString *item = [self.items objectAtIndex:i];
        if([self.delegate respondsToSelector:@selector(topMenu:hasCompletedItem:)]){
            BOOL selected = [self.delegate topMenu:self hasCompletedItem:i];
            
            if(selected)
                [selectedItems addObject:item];
        }
    }
    self.selectedItems = selectedItems;
}

-(void)showClearButton:(BOOL)show{
    //self.clearButton.hidden = !show;
}

#pragma mark UIView methods
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = tcolor(BackgroundColor);
        CGFloat gradientHeight = 4;
        UIView *gradientBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, gradientHeight)];
        gradientBackground.backgroundColor = CLEAR;
        CAGradientLayer *agradient = [CAGradientLayer layer];
        agradient.frame = gradientBackground.bounds;
        gradientBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        agradient.colors = @[(id)alpha(tcolor(TextColor),0.0f).CGColor,(id)alpha(tcolor(TextColor),0.2f).CGColor,(id)alpha(tcolor(TextColor),0.4f).CGColor];
        agradient.locations = @[@0.0,@0.5,@1.0];
        [gradientBackground.layer insertSublayer:agradient atIndex:0];
        [self addSubview:gradientBackground];
        
        CGFloat topY = 44;
        
        UIButton *setWorkSpaceButton = [[UIButton alloc] initWithFrame:CGRectMake(0, gradientHeight, self.frame.size.width, topY)];
        
        setWorkSpaceButton.backgroundColor = CLEAR;
        [setWorkSpaceButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        setWorkSpaceButton.titleLabel.font = KP_REGULAR(16);
        [setWorkSpaceButton setTitle:[NSLocalizedString(@"Get Started", nil) uppercaseString] forState:UIControlStateNormal];
        //[setWorkSpaceButton addTarget:self action:@selector(onHelp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:setWorkSpaceButton];
        
        UIButton *clearButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
        clearButton.frame = CGRectMake(0, gradientHeight, kSideButtonsWidth, topY);
        clearButton.titleLabel.font = KP_REGULAR(16);
        [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
        [clearButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [clearButton addTarget:self action:@selector(onClear:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearButton];
        self.clearButton = clearButton;
        
        
        UIButton *closeButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(frame.size.width-kSideButtonsWidth, gradientHeight, kSideButtonsWidth, topY);
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        closeButton.titleLabel.font = iconFont(20);
        [closeButton setTitle:@"arrowThick" forState:UIControlStateNormal];
        
        [closeButton setTitleColor:tcolor(TextColor) forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];

        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topY, self.bounds.size.width, self.bounds.size.height)];
        self.tableView.backgroundColor = CLEAR;
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.tableView.delegate = self;
        self.tableView.scrollEnabled = NO;
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.dataSource = self;
        [self addSubview:self.tableView];
    }
    return self;
}
-(void)onClose:(UIButton*)closeButton{
    if([self.delegate respondsToSelector:@selector(didPressCloseInOnboardingTopMenu:)])
        [self.delegate didPressCloseInOnboardingTopMenu:self];
}
-(void)onClear:(UIButton*)clearButton{
    if([self.delegate respondsToSelector:@selector(didPressClearInOnboardingTopMenu:)])
        [self.delegate didPressClearInOnboardingTopMenu:self];
}

-(void)dealloc{
    self.tableView = nil;
}
@end
