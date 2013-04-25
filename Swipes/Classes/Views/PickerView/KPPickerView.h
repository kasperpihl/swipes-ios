//
//  CPPickerView.h
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 21/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@protocol KPPickerViewDataSource;
@protocol KPPickerViewDelegate;

@interface KPPickerView : UIView <UIScrollViewDelegate>
{

    __unsafe_unretained id <KPPickerViewDelegate> delegate;
    UIScrollView *contentView;
    UIImageView *glassView;
    
    int currentIndex;
    int itemCount;
    
    // recycling
    NSMutableSet *recycledViews;
    NSMutableSet *visibleViews;
}

// Datasource and delegate
@property (nonatomic, unsafe_unretained) IBOutlet id <KPPickerViewDataSource> dataSource;
@property (nonatomic, unsafe_unretained) IBOutlet id <KPPickerViewDelegate> delegate;
// Current status
@property (nonatomic, unsafe_unretained) int selectedItem;
// Configuration
@property (nonatomic, strong) UIFont *itemFont;
@property (nonatomic, strong) UIColor *itemColor;
@property (nonatomic, strong) UIFont *selectedFont;
@property (nonatomic) BOOL showGlass;
@property (nonatomic) UIEdgeInsets peekInset;


- (void)setup;
- (void)reloadData;
- (void)determineCurrentItem;
- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated;

// recycle queue
- (UIView *)dequeueRecycledView;
- (BOOL)isDisplayingViewForIndex:(NSUInteger)index;
- (void)tileViews;
- (void)configureView:(UIView *)view atIndex:(NSUInteger)index;

@end



@protocol KPPickerViewDataSource <NSObject>

- (NSInteger)numberOfItemsInPickerView:(KPPickerView *)pickerView;
- (NSString *)pickerView:(KPPickerView *)pickerView titleForItem:(NSInteger)item;

@end



@protocol KPPickerViewDelegate <NSObject>

- (void)pickerView:(KPPickerView *)pickerView didSelectItem:(NSInteger)item;

@end

