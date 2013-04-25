//
//  CPPickerView.m
//  ToDo
//
//  Created by Kasper Pihl Tornøe on 21/04/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//


#import "KPPickerView.h"
#define ITEM_PADDING 10
#define ITEM_SPACE 0
#define LOADER_SPACE 200

@interface KPPickerView ()
// Views
@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *glassImage;
@property (nonatomic, strong) UIImage *shadowImage;
@property (nonatomic,strong) NSMutableArray *indexOffsets;
@property (nonatomic,strong) NSMutableArray *titleArray;
@property (nonatomic, strong) UILabel *currentView;
@end

@implementation KPPickerView
@synthesize dataSource = _dataSource;

@synthesize delegate;
@synthesize contentView;
@synthesize glassImage, backgroundImage, shadowImage;
@synthesize selectedItem = currentIndex;
@synthesize itemFont = _itemFont;
@synthesize itemColor = _itemColor;
@synthesize showGlass, peekInset;

#pragma mark - Custom getters/setters
-(NSMutableArray *)indexOffsets{
    if(!_indexOffsets) _indexOffsets = [NSMutableArray array];
    return _indexOffsets;
}
-(NSMutableArray *)titleArray{
    if(!_titleArray) _titleArray = [NSMutableArray array];
    return _titleArray;
}
- (void)setSelectedItem:(int)selectedItem
{
    if (selectedItem >= itemCount)
        return;
    
    currentIndex = selectedItem;
    [self scrollToIndex:currentIndex animated:NO];
}

- (void)setItemFont:(UIFont *)itemFont
{
    _itemFont = itemFont;
    
    for (UILabel *aLabel in visibleViews)
    {
        aLabel.font = _itemFont;
    }
    
    for (UILabel *aLabel in recycledViews)
    {
        aLabel.font = _itemFont;
    }
}

- (void)setItemColor:(UIColor *)itemColor
{
    _itemColor = itemColor;
    
    for (UILabel *aLabel in visibleViews)
    {
        aLabel.textColor = _itemColor;
    }
    
    for (UILabel *aLabel in recycledViews)
    {
        aLabel.textColor = _itemColor;
    }
}

#pragma mark - Initialization


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
    // setup
    [self setup];
    
    // content
    self.contentView = [[UIScrollView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, self.peekInset)];
    self.contentView.clipsToBounds = NO;
    self.contentView.showsHorizontalScrollIndicator = NO;
    self.contentView.showsVerticalScrollIndicator = NO;
    self.contentView.pagingEnabled = NO;
    self.contentView.scrollsToTop = NO;
    self.contentView.decelerationRate = 0.1;
    self.contentView.delegate = self;
    [self addSubview:self.contentView];
    
    //The setup code (in viewDidLoad in your view controller)
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.contentView addGestureRecognizer:singleFingerTap];
    
    // Images
    /*if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        self.backgroundImage = [[UIImage imageNamed:@"wheelBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
        self.glassImage = [[UIImage imageNamed:@"stretchableGlass"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    } else {
        self.backgroundImage = [[UIImage imageNamed:@"wheelBackground"] stretchableImageWithLeftCapWidth:0 topCapHeight:5];
        self.glassImage = [[UIImage imageNamed:@"stretchableGlass"]  stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    }
    self.shadowImage = [UIImage imageNamed:@"shadowOverlay"];
    */
    // Rounded borders
    self.layer.cornerRadius = 3.0f;
    self.clipsToBounds = YES;
    self.layer.borderColor = [UIColor colorWithWhite:0.15 alpha:1.0].CGColor;
    self.layer.borderWidth = 0.5f;
}


- (void)setup
{
    _itemFont = [UIFont fontWithName:@"HelveticaNeue" size:16];
    _selectedFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    _itemColor = [UIColor blackColor];
    showGlass = NO;
    currentIndex = 0;
    itemCount = 0;
    visibleViews = [[NSMutableSet alloc] init];
    recycledViews = [[NSMutableSet alloc] init];
}

- (void)drawRect:(CGRect)rect {
    
    // Draw background
    [self.backgroundImage drawInRect:self.bounds];
    
    // Draw super/UIScrollView
    [super drawRect:rect];
    
    // Draw shadow
    [self.shadowImage drawInRect:self.bounds];
    
    // Draw glass
    if (self.showGlass) {
        [self.glassImage drawInRect:CGRectMake(10, 0.0, 60, self.frame.size.height)];
    }
}

- (void)setShowGlass:(BOOL)doShowGlass {
    if (showGlass != doShowGlass) {
        showGlass = doShowGlass;
        [self setNeedsDisplay];
    }
}
- (void)setPeekInset:(UIEdgeInsets)aPeekInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(peekInset, aPeekInset)) {
        peekInset = aPeekInset;
        self.contentView.frame = UIEdgeInsetsInsetRect(self.bounds, self.peekInset);
        [self reloadData];
        [self.contentView setNeedsDisplay];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    if ([self pointInside:point withEvent:event]) {
        return self.contentView;
    }
    
    return nil;
}


#pragma mark - Data handling and interaction
-(void)setDataSource:(id<KPPickerViewDataSource>)dataSource{
    _dataSource = dataSource;
    [self reloadData];
}
- (void)reloadData
{
    // empty views
    currentIndex = 0;
    itemCount = 0;
    
    for (UIView *aView in visibleViews)
        [aView removeFromSuperview];
    
    for (UIView *aView in recycledViews)
        [aView removeFromSuperview];
    
    visibleViews = [[NSMutableSet alloc] init];
    recycledViews = [[NSMutableSet alloc] init];
    
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInPickerView:)]) {
        itemCount = [self.dataSource numberOfItemsInPickerView:self];
    } else {
        itemCount = 0;
    }
    for(int i = 0 ; i < itemCount ; i++){
        NSString *title;
        if ([self.dataSource respondsToSelector:@selector(pickerView:titleForItem:)]) {
            title = [self.dataSource pickerView:self titleForItem:i];
        }
        [self.titleArray addObject:title];
        [self.indexOffsets addObject:[NSNumber numberWithFloat:[self xCoordinateForIndex:i]]];
    }
    self.contentView.frame = UIEdgeInsetsInsetRect(self.bounds, self.peekInset);
    CGFloat width = [[self.indexOffsets lastObject] floatValue] + (self.contentView.frame.size.width/2) + ([self widthForText:[self.titleArray lastObject]]/2);
    self.contentView.contentSize = CGSizeMake(width, self.contentView.frame.size.height);
    [self tileViews];
    [self determineCurrentItem];
}



-(void)determineItemFromTarget:(CGFloat)target{
    CGFloat oldOffset;
    BOOL hasSetCurrent = NO;
    NSInteger counter = 0;
    for(int i = 0 ; i < self.indexOffsets.count ; i++){
        counter = i;
        CGFloat offset = [[self.indexOffsets objectAtIndex:i] floatValue] + ([self widthForIndex:i]/2);
        if(offset >= target){
            if(i == 0) currentIndex = i;
            else if((target-oldOffset) > (offset-target)) currentIndex = i;
            else currentIndex = i-1;
            hasSetCurrent = YES;
            break;
        }
        oldOffset = offset;
    }
    if(!hasSetCurrent) currentIndex = counter;
    [self scrollToIndex:currentIndex animated:YES];
    for (UILabel *aView in visibleViews)
    {
        if (aView.tag == currentIndex){
            self.currentView = aView;
            self.currentView.font = self.selectedFont;
        }
    }
    if ([delegate respondsToSelector:@selector(pickerView:didSelectItem:)]) {
        [delegate pickerView:self didSelectItem:currentIndex];
    }
}
- (void)determineCurrentItem
{
    CGFloat target = self.contentView.contentOffset.x+(self.contentView.frame.size.width/2);
    [self determineItemFromTarget:target];
}

- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    [self scrollToIndex:index animated:animated];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    CGFloat offset = [[self.indexOffsets objectAtIndex:index] floatValue] - (self.contentView.bounds.size.width/2) + ([self widthForIndex:index]/2);
    [self.contentView setContentOffset:CGPointMake(offset, 0.0) animated:animated];
}




#pragma mark - recycle queue

- (UIView *)dequeueRecycledView
{
	UIView *aView = [recycledViews anyObject];
	
    if (aView)
        [recycledViews removeObject:aView];
    return aView;
}

- (BOOL)isDisplayingViewForIndex:(NSUInteger)index
{
	BOOL foundPage = NO;
    for (UIView *aView in visibleViews)
	{
        if (aView.tag == index)
		{
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}





- (void)tileViews
{
    // Calculate which pages are visible
    CGFloat lowerBarrier = self.contentView.contentOffset.x - LOADER_SPACE;
    CGFloat upperBarrier = self.contentView.contentOffset.x+self.contentView.frame.size.width + LOADER_SPACE;
    int firstNeededViewIndex = 10000;
    int lastNeededViewIndex = 0;
    for(int i = 0 ; i < self.indexOffsets.count ; i++){
        CGFloat offSet = [[self.indexOffsets objectAtIndex:i] floatValue];
        if(offSet < lowerBarrier) continue;
        
        if(offSet > upperBarrier) continue;
        if(i < firstNeededViewIndex) firstNeededViewIndex = i;
        if(i > lastNeededViewIndex) lastNeededViewIndex = i;
    }
    // Recycle no-longer-visible pages
	for (UIView *aView in visibleViews)
    {
        if (aView.tag < firstNeededViewIndex || aView.tag > lastNeededViewIndex)
        {
            [recycledViews addObject:aView];
            [aView removeFromSuperview];
        }
    }
    
    [visibleViews minusSet:recycledViews];
    
    // add missing pages
    
	for (int index = firstNeededViewIndex; index <= lastNeededViewIndex; index++)
	{
        
        if (![self isDisplayingViewForIndex:index])
		{
            UILabel *label = (UILabel *)[self dequeueRecycledView];
            
			if (label == nil)
            {
				label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
                
                label.backgroundColor = [UIColor clearColor];
                label.font = self.itemFont;
                label.textColor = self.itemColor;
                label.textAlignment = NSTextAlignmentCenter;
            }
            
            [self configureView:label atIndex:index];
            [self.contentView addSubview:label];
            [visibleViews addObject:label];
            
        }
    }
}




- (void)configureView:(UIView *)view atIndex:(NSUInteger)index
{
    UILabel *label = (UILabel *)view;
    label.tag = index;
    CGRect frame = label.frame;
    label.text = [self.titleArray objectAtIndex:index];
    frame.origin.x = [[self.indexOffsets objectAtIndex:index] floatValue];
    frame.size.width = [self widthForIndex:index];
    label.frame = frame;
}
-(CGFloat)widthForIndex:(NSInteger)index{
    return [self widthForText:[self.titleArray objectAtIndex:index]];
}
-(CGFloat)widthForText:(NSString*)text{
    CGSize labelSize = [text sizeWithFont:self.itemFont];
    return labelSize.width+(ITEM_PADDING*2);
}
-(CGFloat)xCoordinateForIndex:(NSUInteger)index{
    if(index > 0){
        return [[self.indexOffsets objectAtIndex:index-1] floatValue] + [self widthForIndex:index-1] + ITEM_SPACE;
    }
    else {
        return (self.contentView.frame.size.width / 2) - ([self widthForIndex:0]/2);
    };
}

#pragma mark - TapGestureRecognizer
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    if(self.currentView){
        self.currentView.font = self.itemFont;
        self.currentView = nil;
    }
    CGFloat target = self.contentView.contentOffset.x + location.x;
    [self determineItemFromTarget:target];
    NSLog(@"x: %f y: %f",location.x,location.y);
    //Do stuff here...
}
#pragma mark - UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"begin dragging");
    if(self.currentView){
        self.currentView.font = self.itemFont;
        self.currentView = nil;
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate) [self determineCurrentItem];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self tileViews];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self determineCurrentItem];
}


@end
