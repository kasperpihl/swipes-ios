#import "KPReorderTableView.h"


#define TAG_FOR_ABOVE_SHADOW_VIEW_WHEN_DRAGGING 100
#define TAG_FOR_BELOW_SHADOW_VIEW_WHEN_DRAGGING 200
#define CELL_WIDTH_SCALE 1.08
#define CELL_HEIGHT_SCALE 1.12
#define CGRectSetGrowth(r) r = CGRectMake(r.origin.x - (CELL_GROW_WIDTH/2),r.origin.y - (CELL_GROW_HEIGHT/2),r.size.width + CELL_GROW_WIDTH,r.size.height + CELL_GROW_HEIGHT)
@interface KPReorderTableView ()

typedef enum {
	AutoscrollStatusCellInBetween,
	AutoscrollStatusCellAtTop,
	AutoscrollStatusCellAtBottom
} AutoscrollStatus;
typedef enum {
    DirectionNone = 0,
    DirectionUp,
    DirectionDown
} DragDirection;

- (void)establishGestures;
- (void)longPressRecognized;
- (void)dragGestureRecognized;
- (void)shuffleCellsOutOfWayOfDraggedCellIfNeeded;
//- (void)keepDraggedCellVisible;
- (void)fastCompleteGesturesWithTranslationPoint:(CGPoint)translation;
- (BOOL)touchCanceledAfterDragGestureEstablishedButBeforeDragging;
- (void)completeGesturesForTranslationPoint:(CGPoint)translationPoint;
- (NSIndexPath *)anyIndexPathFromLongPressGesture;
- (NSIndexPath *)indexPathOfSomeRowThatIsNotIndexPath:(NSIndexPath *)selectedIndexPath;
- (void)disableInterferingAspectsOfTableViewAndNavBar;
- (UITableViewCell *)cellPreparedToAnimateAroundAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateDraggedCellWithTranslationPoint:(CGPoint)translation;
- (CGFloat)distanceOfCellCenterFromEdge;
- (CGFloat)autoscrollDistanceForProximityToEdge:(CGFloat)proximity;
- (AutoscrollStatus)locationOfCellGivenSignedAutoscrollDistance:(CGFloat)signedAutoscrollDistance;
- (void)resetDragIVars;
- (void)resetTableViewAndNavBarToTypical;

@property (nonatomic, strong) UITableViewCell *draggedCell;
@property (nonatomic, strong) NSIndexPath *indexPathBelowDraggedCell;
@property (nonatomic, strong) CADisplayLink *timerToAutoscroll;
@property (nonatomic, assign) CGFloat savedYCoordinate;
@property (nonatomic, assign) DragDirection dragDirection;
@property (nonatomic, assign) DragDirection dragPosition;

@end


#pragma mark -


@implementation KPReorderTableView
@synthesize dragDelegate, indicatorDelegate;
@synthesize reorderingEnabled=_reorderingEnabled;
@synthesize draggedCell, indexPathBelowDraggedCell, timerToAutoscroll;


- (void)dealloc {

	[[NSNotificationCenter defaultCenter] removeObserver:resignActiveObserver];
	resignActiveObserver = nil;
}

- (void)commonInit {
	_reorderingEnabled = YES;
	distanceThresholdToAutoscroll = -1.0;
	if ( self.reorderingEnabled )
		[self establishGestures];
    
	__weak KPReorderTableView *blockSelf = self;
	if ( resignActiveObserver == nil )
		resignActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:nil usingBlock:^(NSNotification *arg1) {
			if ( [blockSelf isDraggingCell] ) {
				KPReorderTableView *strongBlockSelf = blockSelf;
				CGPoint currentPoint = [strongBlockSelf->dragGestureRecognizer translationInView:blockSelf];
				[strongBlockSelf fastCompleteGesturesWithTranslationPoint:currentPoint];
			}
		}];
	// tableView's dataSource _must_ implement moving rows
	// bug: calling self.view (or self) in -init causes -viewDidLoad to be called twice
//	NSAssert(self.dataSource && [self.dataSource respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)], @"tableview's dataSource must implement moving rows");
}


- (id)init {
	self = [super init];
	if (self)
		[self commonInit];
	
	return self;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self commonInit];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if(self){
        [self commonInit];
    }
    return self;
}

#pragma mark -
#pragma mark Setters and getters

- (void)establishGestures {
	if (self == nil)
		return;
	
	if (longPressGestureRecognizer == nil || [self.gestureRecognizers containsObject:longPressGestureRecognizer] == NO) {
		longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized)];
		longPressGestureRecognizer.delegate = self;
		
		[self addGestureRecognizer:longPressGestureRecognizer];
		longPressGestureRecognizer.allowableMovement = 5.0;
	}
	
	if (dragGestureRecognizer == nil || [self.gestureRecognizers containsObject:dragGestureRecognizer] ) {
		dragGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragGestureRecognized)];
		dragGestureRecognizer.delegate = self;

		[self addGestureRecognizer:dragGestureRecognizer];
	}
}


- (void)removeGestures {
	if ( [self isDraggingCell] ) {
		CGPoint currentPoint = [dragGestureRecognizer translationInView:self];
		[self fastCompleteGesturesWithTranslationPoint:currentPoint];
	}
	
	[self removeGestureRecognizer:longPressGestureRecognizer];
	longPressGestureRecognizer = nil;
	
	[self removeGestureRecognizer:dragGestureRecognizer];
	dragGestureRecognizer = nil;
}


- (void)setReorderingEnabled:(BOOL)newEnabledStatus {
	if (_reorderingEnabled == newEnabledStatus)
		return;
	
	_reorderingEnabled = newEnabledStatus;
	
	if ( _reorderingEnabled )
		[self establishGestures];
	else
		[self removeGestures];
}

- (BOOL)reorderingEnabled {
	return _reorderingEnabled;
}

- (BOOL)isReorderingEnabled {
	return [self reorderingEnabled];
}


- (BOOL)isDraggingCell {
	return (self.draggedCell != nil);
}


#pragma mark -
#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return (gestureRecognizer == dragGestureRecognizer || otherGestureRecognizer == dragGestureRecognizer);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	if( gestureRecognizer == longPressGestureRecognizer || gestureRecognizer == dragGestureRecognizer ) {
		static UITouch *longPressTouch = nil;
		
		if ( gestureRecognizer == longPressGestureRecognizer && longPressGestureRecognizer.state == UIGestureRecognizerStatePossible ) {
			longPressTouch = touch; // never retain a UITouch
			veryInitialTouchPoint = [touch locationInView:self];
		}
		return ( touch == longPressTouch );
	}

	return YES;
}


#pragma mark -
#pragma mark UIGestureRecognizer targets and CADisplayLink target


- (void)longPressRecognized {
    
	if ([self touchCanceledAfterDragGestureEstablishedButBeforeDragging]) {
		[self completeGesturesForTranslationPoint:CGPointZero];
		return;
	}
	
	if ( self.draggedCell && longPressGestureRecognizer.state == UIGestureRecognizerStateChanged && self.allowsSelection )
		self.allowsSelection = NO;
	
	if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan)
		return;
	
	NSIndexPath *indexPathOfRow = [self anyIndexPathFromLongPressGesture];
	if ( !indexPathOfRow )
		return;

	NSIndexPath *selectedPath = [self indexPathForRowAtPoint:veryInitialTouchPoint];
	if ( !(indexPathOfRow.section == selectedPath.section && indexPathOfRow.row == selectedPath.row) )
		indexPathOfRow = selectedPath;

/*	UITableViewCell *highlightedCell = [self cellForRowAtIndexPath:indexPathOfRow];
	if ( ![highlightedCell isHighlighted] )
		return;*/

	if ([self.dataSource respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)]) {
		if (![self.dataSource tableView:self canMoveRowAtIndexPath:indexPathOfRow])
			return;
	}
	[self disableInterferingAspectsOfTableViewAndNavBar];

	NSIndexPath *indexPathOfSomeOtherRow = [self indexPathOfSomeRowThatIsNotIndexPath:indexPathOfRow];

	if (indexPathOfSomeOtherRow != nil)
		[self reloadRowsAtIndexPaths:@[indexPathOfSomeOtherRow] withRowAnimation:UITableViewRowAnimationNone];
	self.draggedCell = [self cellPreparedToAnimateAroundAtIndexPath:indexPathOfRow];

	//[self.draggedCell setSelected:NO animated:NO];
    
	[UIView animateWithDuration:0.23 delay:0 options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseInOut) animations:^{
        CGFloat widthScale = CELL_WIDTH_SCALE;
        CGFloat heightScale = CELL_HEIGHT_SCALE;
        self.draggedCell.transform = CGAffineTransformMakeScale(widthScale, heightScale);
        
	} completion:nil];

	initialYOffsetOfDraggedCellCenter = self.draggedCell.center.y - self.contentOffset.y;

	distanceThresholdToAutoscroll = DISTANCE_TO_AUTO_SCROLL;// self.draggedCell.frame.size.height / 2.0 + 6;

	self.indexPathBelowDraggedCell = indexPathOfRow;

	if ([self.dragDelegate respondsToSelector:@selector(dragTableViewController:didBeginDraggingAtRow:)])
		[self.dragDelegate dragTableViewController:self didBeginDraggingAtRow:indexPathOfRow];

	UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(@"Now dragging.", @"Voiceover annoucement"));
}

- (void)dragGestureRecognized {

	if ( !self.draggedCell )
		return;
	CGPoint translation = [dragGestureRecognizer translationInView:self];
    if(self.savedYCoordinate){

        if(translation.y < self.savedYCoordinate ) self.dragDirection = DirectionUp;
        else if(translation.y > self.savedYCoordinate) self.dragDirection = DirectionDown;
    }
    self.savedYCoordinate = translation.y;
	if (dragGestureRecognizer.state == UIGestureRecognizerStateEnded || dragGestureRecognizer.state == UIGestureRecognizerStateCancelled)
		[self completeGesturesForTranslationPoint:translation];
	else
		[self updateDraggedCellWithTranslationPoint:translation];
}


- (void)fireAutoscrollTimer:(CADisplayLink *)sender {
	UITableViewCell *blankCell = [self cellForRowAtIndexPath:self.indexPathBelowDraggedCell];
	if (blankCell != nil && blankCell.hidden == NO)
		blankCell.hidden = YES;

	CGFloat signedDistance = [self distanceOfCellCenterFromEdge];
    //NSLog(@"signedDistance:%f",signedDistance);
	CGFloat absoluteDistance = fabs(signedDistance);

    
	CGFloat autoscrollDistance = [self autoscrollDistanceForProximityToEdge:absoluteDistance];
   // NSLog(@"distance:%f",autoscrollDistance);
	// negative values means going up
	if (signedDistance < 0)
		autoscrollDistance *= -1;

	AutoscrollStatus autoscrollOption = [self locationOfCellGivenSignedAutoscrollDistance:autoscrollDistance];

	CGPoint tableViewContentOffset = self.contentOffset;

	if ( autoscrollOption == AutoscrollStatusCellAtTop ) {
        
		CGFloat scrollDistance = autoscrollDistance;
        CGFloat tableViewHeaderHeight = self.tableHeaderView.frame.size.height;
        
		tableViewContentOffset.y = tableViewContentOffset.y < tableViewHeaderHeight ? tableViewContentOffset.y : tableViewHeaderHeight;

		draggedCell.center = CGPointMake(draggedCell.center.x, draggedCell.center.y - scrollDistance);

		[self.timerToAutoscroll invalidate];
	} else if ( autoscrollOption == AutoscrollStatusCellAtBottom ) {

		CGFloat yOffsetForBottomOfTableViewContent = MAX(0, (self.contentSize.height - self.frame.size.height));

		CGFloat scrollDistance = autoscrollDistance;//yOffsetForBottomOfTableViewContent - tableViewContentOffset.y;
		tableViewContentOffset.y = yOffsetForBottomOfTableViewContent;

		draggedCell.center = CGPointMake(draggedCell.center.x, draggedCell.center.y + scrollDistance);

		[self.timerToAutoscroll invalidate];
	} else {
		tableViewContentOffset.y += autoscrollDistance;
		draggedCell.center = CGPointMake(draggedCell.center.x, draggedCell.center.y + autoscrollDistance);
	}

	self.contentOffset = tableViewContentOffset;


	[self shuffleCellsOutOfWayOfDraggedCellIfNeeded];
}


#pragma mark -
#pragma mark longPressRecognized helper methods

- (BOOL)touchCanceledAfterDragGestureEstablishedButBeforeDragging {
	return (self.draggedCell != nil && longPressGestureRecognizer.state == UIGestureRecognizerStateEnded && dragGestureRecognizer.state == UIGestureRecognizerStateFailed);
}

- (NSIndexPath *)anyIndexPathFromLongPressGesture {

	for (NSUInteger pointIndex = 0; pointIndex < [longPressGestureRecognizer numberOfTouches]; ++pointIndex) {
		CGPoint touchPoint = [longPressGestureRecognizer locationOfTouch:pointIndex inView:self];

		NSIndexPath *indexPath = [self indexPathForRowAtPoint:touchPoint];
		if (indexPath != nil)
			return indexPath;
	}

	return nil;
}

- (UITableViewCell *)cellPreparedToAnimateAroundAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cellCopy;
	if ( [self.indicatorDelegate respondsToSelector:@selector(cellIdenticalToCellAtIndexPath:forDragTableViewController:)])
		cellCopy = [self.indicatorDelegate cellIdenticalToCellAtIndexPath:indexPath forDragTableViewController:self];
	else
		cellCopy = [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
	cellCopy.frame = [self rectForRowAtIndexPath:indexPath];

	[self addSubview:cellCopy];
	[self bringSubviewToFront:cellCopy];

	UITableViewCell *actualCell = [self cellForRowAtIndexPath:indexPath];
	if (actualCell != nil)
		actualCell.hidden = YES;

	return cellCopy;
}

- (NSIndexPath *)indexPathOfSomeRowThatIsNotIndexPath:(NSIndexPath *)selectedIndexPath {
	NSArray *arrayOfVisibleIndexPaths = [self indexPathsForVisibleRows];

	if (arrayOfVisibleIndexPaths.count <= 1)
		return nil;

	NSIndexPath *indexPathOfSomeOtherRow = [arrayOfVisibleIndexPaths lastObject];

	if (indexPathOfSomeOtherRow.row == selectedIndexPath.row && indexPathOfSomeOtherRow.section == selectedIndexPath.section)
		indexPathOfSomeOtherRow = [arrayOfVisibleIndexPaths objectAtIndex:0];

	return indexPathOfSomeOtherRow;
}


#pragma mark -
#pragma mark dragGestureRecognized helper methods

- (void)updateFrameOfDraggedCellForTranlationPoint:(CGPoint)translation {
	CGFloat newYCenter = initialYOffsetOfDraggedCellCenter + translation.y + self.contentOffset.y;
	newYCenter = MAX(newYCenter, self.contentOffset.y);
	newYCenter = MIN(newYCenter, self.contentOffset.y + self.bounds.size.height);

	CGPoint newDraggedCellCenter = {
		.x = draggedCell.center.x,
		.y = newYCenter
	};

	draggedCell.center = newDraggedCellCenter;

	/*
		Don't let the cell go off of the tableview
	 */
}

/*
	Description:
		Checks if the draggedCell is close to an edge and makes tableView autoscroll or not depending.
 */
- (void)setTableViewToAutoscrollIfNeeded {
	/*
		Get absolute distance from edge.
	 */
	CGFloat absoluteDistance = [self distanceOfCellCenterFromEdge];
	if (absoluteDistance < 0)
		absoluteDistance *= -1;

	/*
		If cell is close enough, create a timer to autoscroll.
	 */
    //NSLog(@"%f:%f",absoluteDistance,distanceThresholdToAutoscroll);
	if (absoluteDistance < distanceThresholdToAutoscroll) {
        if(self.dragPosition != self.dragDirection) return;
		/*
			dragged cell is close to the top or bottom edge, so create an autoscroll timer if needed.
		 */
		if (self.timerToAutoscroll == nil) {
			/*
				Timer is actually a CADisplayLink, which fires everytime Core Animation wants to draw, aka, every frame.
				Using an NSTimer with 1/60th of a second hurts frame rate because it might update in between drawing and force it to try to draw again.
			 */
			self.timerToAutoscroll = [CADisplayLink displayLinkWithTarget:self selector:@selector(fireAutoscrollTimer:)];
			[self.timerToAutoscroll addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
		}
	} else {
		/*
			If we move our cell out of the autoscroll threshold, remove the timer and stop autoscrolling.
		 */
		if (self.timerToAutoscroll != nil) {
			[timerToAutoscroll invalidate];
			self.timerToAutoscroll = nil;
		}
	}
}

/*
	Description:
		Animates the dragged cell sliding back into the tableview.
		Tells the data model to update as appropriate.
 */
- (void)endedDragGestureWithTranslationPoint:(CGPoint)translation {
	
    [self updateFrameOfDraggedCellForTranlationPoint:translation];
	
	[self shuffleCellsOutOfWayOfDraggedCellIfNeeded];
    
	if ([self.dragDelegate respondsToSelector:@selector(dragTableViewController:willEndDraggingToRow:)])
		[self.dragDelegate dragTableViewController:self willEndDraggingToRow:self.indexPathBelowDraggedCell];
	UITableViewCell *oldDraggedCell = self.draggedCell;
	NSIndexPath *blankIndexPath = self.indexPathBelowDraggedCell;

	CGRect rectForIndexPath = [self rectForRowAtIndexPath:self.indexPathBelowDraggedCell];

        
	[UIView animateWithDuration:0.25 delay:0 options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^{
		//self.draggedCell.transform = CGAffineTransformMakeScale(1/CELL_WIDTH_SCALE, 1/CELL_HEIGHT_SCALE);
        self.draggedCell.transform = CGAffineTransformIdentity;
        oldDraggedCell.frame = rectForIndexPath;
	} completion:^(BOOL finished) {
        
		[self reloadRowsAtIndexPaths:[NSArray arrayWithObject:blankIndexPath] withRowAnimation:UITableViewRowAnimationNone];
		
		[oldDraggedCell removeFromSuperview];

		if( [self.dragDelegate respondsToSelector:@selector(dragTableViewController:didEndDraggingToRow:)] )
			[self.dragDelegate dragTableViewController:self didEndDraggingToRow:blankIndexPath];

		UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(@"Drag completed.", @"Voiceover annoucement"));
	}];

	[self scrollRectToVisible:rectForIndexPath animated:YES];
}
- (void)fastCompleteGesturesWithTranslationPoint:(CGPoint) translation {
	[self updateFrameOfDraggedCellForTranlationPoint:translation];

	[self shuffleCellsOutOfWayOfDraggedCellIfNeeded];

	if ([self.dragDelegate respondsToSelector:@selector(dragTableViewController:willEndDraggingToRow:)])
		[self.dragDelegate dragTableViewController:self willEndDraggingToRow:self.indexPathBelowDraggedCell];

	[self reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPathBelowDraggedCell] withRowAnimation:UITableViewRowAnimationNone];
	self.draggedCell.layer.shouldRasterize = NO;


	[self.draggedCell removeFromSuperview];

	[self resetDragIVars];
	[self resetTableViewAndNavBarToTypical];
}

- (void)completeGesturesForTranslationPoint:(CGPoint)translation {

	[self endedDragGestureWithTranslationPoint:translation];
	[self resetDragIVars];
	[self resetTableViewAndNavBarToTypical];

}

- (void)shuffleCellsOutOfWayOfDraggedCellIfNeeded {
	
	NSArray *arrayOfCoveredIndexPaths = [self indexPathsForRowsInRect:self.draggedCell.frame];

	CGRect blankCellFrame = [self rectForRowAtIndexPath:self.indexPathBelowDraggedCell];
	CGPoint blankCellCenter = {
		.x = CGRectGetMidX(blankCellFrame),
		.y = CGRectGetMidY(blankCellFrame)
	};
	CGRect rectOfCoveredCells = blankCellFrame;
	for (NSIndexPath *row in arrayOfCoveredIndexPaths) {
		CGRect newRect = CGRectUnion(rectOfCoveredCells, [self rectForRowAtIndexPath:row]);
		rectOfCoveredCells = newRect;
	}
	NSIndexPath *rowToMoveTo = nil;
	if (draggedCell.center.y < CGRectGetMidY(rectOfCoveredCells)) {
		CGRect upperHalf = {
			.origin = rectOfCoveredCells.origin,
			.size.width = rectOfCoveredCells.size.width,
			.size.height = rectOfCoveredCells.size.height / 2
		};
		if (!CGRectContainsPoint(upperHalf, blankCellCenter)) {
			NSUInteger blankCellIndex = [arrayOfCoveredIndexPaths indexOfObject:self.indexPathBelowDraggedCell];

			if (blankCellIndex != NSNotFound && blankCellIndex != 0 && (blankCellIndex - 1) > 0)
				rowToMoveTo = [arrayOfCoveredIndexPaths objectAtIndex:(blankCellIndex - 1)];
			else if (arrayOfCoveredIndexPaths.count > 0)
				rowToMoveTo = [arrayOfCoveredIndexPaths objectAtIndex:0];
		}

	} else {
		CGRect lowerHalf ={
			.origin.x = rectOfCoveredCells.origin.x,
			.origin.y = rectOfCoveredCells.origin.y + rectOfCoveredCells.size.height / 2,
			.size.width = rectOfCoveredCells.size.width,
			.size.height = rectOfCoveredCells.size.height / 2
		};
		if (!CGRectContainsPoint(lowerHalf, blankCellCenter)) {
			NSUInteger blankCellIndex = [arrayOfCoveredIndexPaths indexOfObject:self.indexPathBelowDraggedCell];

			if (blankCellIndex != NSNotFound && (blankCellIndex + 1) < arrayOfCoveredIndexPaths.count)
				rowToMoveTo = [arrayOfCoveredIndexPaths objectAtIndex:(blankCellIndex + 1)];
			else
				rowToMoveTo = [arrayOfCoveredIndexPaths lastObject];
		}
	}
	if (rowToMoveTo != nil && !(rowToMoveTo.section == self.indexPathBelowDraggedCell.section && rowToMoveTo.row == self.indexPathBelowDraggedCell.row)) {
		[self.dataSource tableView:self moveRowAtIndexPath:self.indexPathBelowDraggedCell toIndexPath:rowToMoveTo];

		/*
			Update the blank index path
		 */
		NSIndexPath *formerBlankIndexPath = self.indexPathBelowDraggedCell;
		self.indexPathBelowDraggedCell = rowToMoveTo;

		/*
			Then animate the row updates.
		 */
		if ( [self respondsToSelector:@selector(moveRowAtIndexPath:toIndexPath:)] )
			[self moveRowAtIndexPath:formerBlankIndexPath toIndexPath:rowToMoveTo];
		else {
			[self beginUpdates];
			[self deleteRowsAtIndexPaths:[NSArray arrayWithObject:formerBlankIndexPath] withRowAnimation:UITableViewRowAnimationNone];
			[self insertRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPathBelowDraggedCell] withRowAnimation:UITableViewRowAnimationNone];
			[self endUpdates];
		}


		/*
			Keep the cell under the dragged cell hidden.
			This is a crucial line of code. Otherwise we get all kinds of graphical weirdness
		 */
		UITableViewCell *cellToHide = [self cellForRowAtIndexPath:self.indexPathBelowDraggedCell];
		cellToHide.hidden = YES;

	}
}


/*
	Description:
		Update the dragged cell to its new position and updates the tableView to shuffle cells out of the way.
 */
- (void)updateDraggedCellWithTranslationPoint:(CGPoint)translation {
	/*
		Set new frame of dragged cell,
		then use this new frame to check if the tableview needs to autoscroll or shuffle cells out of the way or both.
	 */
	[self updateFrameOfDraggedCellForTranlationPoint:translation];
	[self setTableViewToAutoscrollIfNeeded];
	[self shuffleCellsOutOfWayOfDraggedCellIfNeeded];
}


#pragma mark -
#pragma mark fireAutoscrollTimer helper methods

/*
	Description:
		Calculates how far from the top or bottom edge of the tableview the cell's visible center is.
	Returns:
		A positive number if close to the bottom, negative if close to top.
		Will not return zero.
 */
- (CGFloat)distanceOfCellCenterFromEdge {

	/*
		Use translation data to get absolute position of touch insted of cell. Cell is bound by tableview content offset and contentsize, touch is not.
	 */
	CGPoint translation = [dragGestureRecognizer translationInView:self];
	
	CGFloat yOffsetOfDraggedCellCenter = initialYOffsetOfDraggedCellCenter + translation.y;
	
	CGFloat heightOfTableView = self.bounds.size.height;
	//CGFloat paddingAgainstBottom = 100.0;
	if (yOffsetOfDraggedCellCenter > heightOfTableView/2.0) {
		/*
			The subtraction from the height is to make it faster to autoscroll down.
			Scrolling up is easy because there's a navigation bar to cover. No such luck when scrolling down.
			So the "bottom" of the tableView is considered to be higher than it is.

			Todo: make this more generic by checking for existance of toolbar or navbar, but even that might not be generic enough.
			Could check position in UIWindow, perhaps.
		 */

		/*
			Return positive because going down.
		 */
        self.dragPosition = DirectionDown;
		return MAX((1.0 / [UIScreen mainScreen].scale), (heightOfTableView) - yOffsetOfDraggedCellCenter);
	} else
		/*
			Return negative because going up.
		 */
        self.dragPosition = DirectionUp;
		return -1 * MAX((1.0 / [UIScreen mainScreen].scale), yOffsetOfDraggedCellCenter);
}



/*
	Description:
		Figures out how much to scroll the tableView depending on how close it is to the edge.
	Parameter:
		The distance
	Returns:
		Distance in pixels to move the tableView. None of this velocity stuff.
 */
- (CGFloat)autoscrollDistanceForProximityToEdge:(CGFloat)proximity {
    /*
		To scroll more smoothly on Retina Displays, we multiply by scale, ceilf the result, and then divide by scale again.
		This will allow us to round to 0.5 pixel increments on retina displays instead of rounding up to 1.0.
	 */
	/*
		To support variable row heights. We want speed at the center of a cell to be the same no matter what size cell it is.
		Mimics behavior of built-in drag control.

		Higher max distance traveled means faster autoscrolling.
	 */
    CGFloat maxAutoscrollDistance = 20.0;
    if ( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad )
        maxAutoscrollDistance = 39.0;

#if CGFLOAT_IS_DOUBLE
	return ceil((distanceThresholdToAutoscroll - proximity)/distanceThresholdToAutoscroll * maxAutoscrollDistance * [UIScreen mainScreen].scale) / [UIScreen mainScreen].scale;
#else
	return ceilf((distanceThresholdToAutoscroll - proximity)/distanceThresholdToAutoscroll * maxAutoscrollDistance * [UIScreen mainScreen].scale) / [UIScreen mainScreen].scale;
#endif
}




- (AutoscrollStatus)locationOfCellGivenSignedAutoscrollDistance:(CGFloat)signedAutoscrollDistance {
	if ( signedAutoscrollDistance < 0 && self.contentOffset.y + signedAutoscrollDistance <= self.tableHeaderView.frame.size.height )
		return AutoscrollStatusCellAtTop;

	if ( signedAutoscrollDistance > 0 && self.contentOffset.y + signedAutoscrollDistance >= self.contentSize.height - self.frame.size.height )
		return AutoscrollStatusCellAtBottom;

	return AutoscrollStatusCellInBetween;

}



#pragma mark -
#pragma mark miscellaneous helper methods

- (void)setInterferingElementsToEnabled:(BOOL)enabled {
	self.scrollsToTop = enabled;
}


- (void)resetTableViewAndNavBarToTypical {
	[self setInterferingElementsToEnabled:YES];
	self.allowsSelection = YES;

}

- (void)disableInterferingAspectsOfTableViewAndNavBar {
	[self setInterferingElementsToEnabled:NO];
}

- (void)resetDragIVars {
	self.draggedCell = nil;
	self.indexPathBelowDraggedCell = nil;
	[self.timerToAutoscroll invalidate];
	self.timerToAutoscroll = nil;
	distanceThresholdToAutoscroll = -1.0;
}


#pragma mark -
#pragma mark add and remove indications of draggability methods



@end
