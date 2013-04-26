#import "ATSDragToReorderTableViewController.h"


#define TAG_FOR_ABOVE_SHADOW_VIEW_WHEN_DRAGGING 100
#define TAG_FOR_BELOW_SHADOW_VIEW_WHEN_DRAGGING 200
#define CELL_WIDTH_SCALE 1.02
#define CELL_HEIGHT_SCALE 1.05
#define CGRectSetGrowth(r) r = CGRectMake(r.origin.x - (CELL_GROW_WIDTH/2),r.origin.y - (CELL_GROW_HEIGHT/2),r.size.width + CELL_GROW_WIDTH,r.size.height + CELL_GROW_HEIGHT)
@interface ATSDragToReorderTableViewController ()

typedef enum {
	AutoscrollStatusCellInBetween,
	AutoscrollStatusCellAtTop,
	AutoscrollStatusCellAtBottom
} AutoscrollStatus;

- (void)establishGestures;
- (void)longPressRecognized;
- (void)dragGestureRecognized;
- (void)shuffleCellsOutOfWayOfDraggedCellIfNeeded;
- (void)keepDraggedCellVisible;
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

@property (strong) UITableViewCell *draggedCell;
@property (strong) NSIndexPath *indexPathBelowDraggedCell;
@property (strong) CADisplayLink *timerToAutoscroll;

@end


#pragma mark -


@implementation ATSDragToReorderTableViewController
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
	
	self.indicatorDelegate = self;
	
	// tableView's dataSource _must_ implement moving rows
	// bug: calling self.view (or self.tableview) in -init causes -viewDidLoad to be called twice
//	NSAssert(self.tableView.dataSource && [self.tableView.dataSource respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)], @"tableview's dataSource must implement moving rows");
}


- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	if (self)
		[self commonInit];
	
	return self;
}

- (id)init {
	self = [super init];
	if (self)
		[self commonInit];
	
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
		[self commonInit];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self)
		[self commonInit];
	
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

	if ( self.reorderingEnabled )
		[self establishGestures];

	__weak ATSDragToReorderTableViewController *blockSelf = self;
	if ( resignActiveObserver == nil )
		resignActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:nil usingBlock:^(NSNotification *arg1) {
			if ( [blockSelf isDraggingCell] ) {
				ATSDragToReorderTableViewController *strongBlockSelf = blockSelf;
				CGPoint currentPoint = [strongBlockSelf->dragGestureRecognizer translationInView:blockSelf.tableView];
				[strongBlockSelf fastCompleteGesturesWithTranslationPoint:currentPoint];
			}
		}];
}


#pragma mark -
#pragma mark Setters and getters

- (void)establishGestures {
	if (self.tableView == nil)
		return;
	
	if (longPressGestureRecognizer == nil || [self.tableView.gestureRecognizers containsObject:longPressGestureRecognizer] == NO) {
		longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized)];
		longPressGestureRecognizer.delegate = self;
		
		[self.tableView addGestureRecognizer:longPressGestureRecognizer];
		longPressGestureRecognizer.allowableMovement = 5.0;
	}
	
	if (dragGestureRecognizer == nil || [self.tableView.gestureRecognizers containsObject:dragGestureRecognizer] ) {
		dragGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragGestureRecognized)];
		dragGestureRecognizer.delegate = self;

		[self.tableView addGestureRecognizer:dragGestureRecognizer];
	}
}


- (void)removeGestures {
	if ( [self isDraggingCell] ) {
		CGPoint currentPoint = [dragGestureRecognizer translationInView:self.tableView];
		[self fastCompleteGesturesWithTranslationPoint:currentPoint];
	}
	
	[self.tableView removeGestureRecognizer:longPressGestureRecognizer];
	longPressGestureRecognizer = nil;
	
	[self.tableView removeGestureRecognizer:dragGestureRecognizer];
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
			veryInitialTouchPoint = [touch locationInView:self.tableView];
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
	
	if ( self.draggedCell && longPressGestureRecognizer.state == UIGestureRecognizerStateChanged && self.tableView.allowsSelection )
		self.tableView.allowsSelection = NO;
	
	if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan)
		return;
	
	NSIndexPath *indexPathOfRow = [self anyIndexPathFromLongPressGesture];
	if ( !indexPathOfRow )
		return;

	NSIndexPath *selectedPath = [self.tableView indexPathForRowAtPoint:veryInitialTouchPoint];
	if ( !(indexPathOfRow.section == selectedPath.section && indexPathOfRow.row == selectedPath.row) )
		indexPathOfRow = selectedPath;

/*	UITableViewCell *highlightedCell = [self.tableView cellForRowAtIndexPath:indexPathOfRow];
	if ( ![highlightedCell isHighlighted] )
		return;*/

	if ([self.tableView.dataSource respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)]) {
		if (![self.tableView.dataSource tableView:self.tableView canMoveRowAtIndexPath:indexPathOfRow])
			return;
	}

	[self disableInterferingAspectsOfTableViewAndNavBar];

	NSIndexPath *indexPathOfSomeOtherRow = [self indexPathOfSomeRowThatIsNotIndexPath:indexPathOfRow];

	if (indexPathOfSomeOtherRow != nil)
		[self.tableView reloadRowsAtIndexPaths:@[indexPathOfSomeOtherRow] withRowAnimation:UITableViewRowAnimationNone];

	self.draggedCell = [self cellPreparedToAnimateAroundAtIndexPath:indexPathOfRow];

	//[self.draggedCell setHighlighted:NO animated:NO];
    [self dragTableViewController:self addDraggableIndicatorsToCell:self.draggedCell forIndexPath:indexPathOfRow];
	[UIView animateWithDuration:0.23 delay:0 options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseInOut) animations:^{
        CGFloat widthScale = CELL_WIDTH_SCALE;
        CGFloat heightScale = CELL_HEIGHT_SCALE;
        self.draggedCell.transform = CGAffineTransformMakeScale(widthScale, heightScale);
        /*CGRectSetGrowth(self.draggedCell.frame);
        UIView *aboveShadowView = [self.draggedCell viewWithTag:TAG_FOR_ABOVE_SHADOW_VIEW_WHEN_DRAGGING];
        //CGRectSetGrowth(aboveShadowView.frame);
        UIView *belowShadowView = [self.draggedCell viewWithTag:TAG_FOR_BELOW_SHADOW_VIEW_WHEN_DRAGGING];
        //CGRectSetGrowth(belowShadowView.frame);*/
        
        
	} completion:^(BOOL finished) {
		if (finished) {
            
			self.draggedCell.layer.rasterizationScale = [[UIScreen mainScreen] scale];
			self.draggedCell.layer.shouldRasterize = YES;
		}
	}];

	initialYOffsetOfDraggedCellCenter = self.draggedCell.center.y - self.tableView.contentOffset.y;

	distanceThresholdToAutoscroll = DISTANCE_TO_AUTO_SCROLL;// self.draggedCell.frame.size.height / 2.0 + 6;

	self.indexPathBelowDraggedCell = indexPathOfRow;

	if ([self.dragDelegate respondsToSelector:@selector(dragTableViewController:didBeginDraggingAtRow:)])
		[self.dragDelegate dragTableViewController:self didBeginDraggingAtRow:indexPathOfRow];

	UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(@"Now dragging.", @"Voiceover annoucement"));
}

- (void)dragGestureRecognized {

	if ( !self.draggedCell )
		return;
	CGPoint translation = [dragGestureRecognizer translationInView:self.tableView];
    //NSLog(@"translation:%f:%f",translation.x,translation.y);
	if (dragGestureRecognizer.state == UIGestureRecognizerStateEnded || dragGestureRecognizer.state == UIGestureRecognizerStateCancelled)
		[self completeGesturesForTranslationPoint:translation];
	else
		[self updateDraggedCellWithTranslationPoint:translation];
}


- (void)fireAutoscrollTimer:(CADisplayLink *)sender {

	UITableViewCell *blankCell = [self.tableView cellForRowAtIndexPath:self.indexPathBelowDraggedCell];
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

	CGPoint tableViewContentOffset = self.tableView.contentOffset;

	if ( autoscrollOption == AutoscrollStatusCellAtTop ) {

		CGFloat scrollDistance = tableViewContentOffset.y;
		tableViewContentOffset.y = 0;

		draggedCell.center = CGPointMake(draggedCell.center.x, draggedCell.center.y - scrollDistance);

		[self.timerToAutoscroll invalidate];
	} else if ( autoscrollOption == AutoscrollStatusCellAtBottom ) {

		CGFloat yOffsetForBottomOfTableViewContent = MAX(0, (self.tableView.contentSize.height - self.tableView.frame.size.height));

		CGFloat scrollDistance = yOffsetForBottomOfTableViewContent - tableViewContentOffset.y;
		tableViewContentOffset.y = yOffsetForBottomOfTableViewContent;

		draggedCell.center = CGPointMake(draggedCell.center.x, draggedCell.center.y + scrollDistance);

		[self.timerToAutoscroll invalidate];
	} else {

		tableViewContentOffset.y += autoscrollDistance;
		draggedCell.center = CGPointMake(draggedCell.center.x, draggedCell.center.y + autoscrollDistance);
	}

	self.tableView.contentOffset = tableViewContentOffset;

	[self keepDraggedCellVisible];

	[self shuffleCellsOutOfWayOfDraggedCellIfNeeded];
}


#pragma mark -
#pragma mark longPressRecognized helper methods

- (BOOL)touchCanceledAfterDragGestureEstablishedButBeforeDragging {
	return (self.draggedCell != nil && longPressGestureRecognizer.state == UIGestureRecognizerStateEnded && dragGestureRecognizer.state == UIGestureRecognizerStateFailed);
}

- (NSIndexPath *)anyIndexPathFromLongPressGesture {

	for (NSUInteger pointIndex = 0; pointIndex < [longPressGestureRecognizer numberOfTouches]; ++pointIndex) {
		CGPoint touchPoint = [longPressGestureRecognizer locationOfTouch:pointIndex inView:self.tableView];

		NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
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
		cellCopy = [self.tableView.dataSource tableView:self.tableView cellForRowAtIndexPath:indexPath];
	cellCopy.frame = [self.tableView rectForRowAtIndexPath:indexPath];

	[self.tableView addSubview:cellCopy];
	[self.tableView bringSubviewToFront:cellCopy];

	UITableViewCell *actualCell = [self.tableView cellForRowAtIndexPath:indexPath];
	if (actualCell != nil)
		actualCell.hidden = YES;

	return cellCopy;
}

- (NSIndexPath *)indexPathOfSomeRowThatIsNotIndexPath:(NSIndexPath *)selectedIndexPath {
	NSArray *arrayOfVisibleIndexPaths = [self.tableView indexPathsForVisibleRows];

	if (arrayOfVisibleIndexPaths.count <= 1)
		return nil;

	NSIndexPath *indexPathOfSomeOtherRow = [arrayOfVisibleIndexPaths lastObject];

	if (indexPathOfSomeOtherRow.row == selectedIndexPath.row && indexPathOfSomeOtherRow.section == selectedIndexPath.section)
		indexPathOfSomeOtherRow = [arrayOfVisibleIndexPaths objectAtIndex:0];

	return indexPathOfSomeOtherRow;
}


#pragma mark -
#pragma mark dragGestureRecognized helper methods

- (void)keepDraggedCellVisible {

	if (draggedCell.frame.origin.y <= 0) {
		CGRect newDraggedCellFrame = draggedCell.frame;
		newDraggedCellFrame.origin.y = 0;
		draggedCell.frame = newDraggedCellFrame;

		return;
	}
	CGRect contentRect = {
		.origin = self.tableView.contentOffset,
		.size = self.tableView.contentSize
	};

	CGFloat maxYOffsetOfDraggedCell = contentRect.origin.x + contentRect.size.height - draggedCell.frame.size.height;

	if (draggedCell.frame.origin.y >= maxYOffsetOfDraggedCell) {
		CGRect newDraggedCellFrame = draggedCell.frame;
		newDraggedCellFrame.origin.y = maxYOffsetOfDraggedCell;
		draggedCell.frame = newDraggedCellFrame;
	}

}
- (void)updateFrameOfDraggedCellForTranlationPoint:(CGPoint)translation {
	CGFloat newYCenter = initialYOffsetOfDraggedCellCenter + translation.y + self.tableView.contentOffset.y;
	newYCenter = MAX(newYCenter, self.tableView.contentOffset.y);
	newYCenter = MIN(newYCenter, self.tableView.contentOffset.y + self.tableView.bounds.size.height);

	CGPoint newDraggedCellCenter = {
		.x = draggedCell.center.x,
		.y = newYCenter
	};

	draggedCell.center = newDraggedCellCenter;

	/*
		Don't let the cell go off of the tableview
	 */
	[self keepDraggedCellVisible];
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

	CGRect rectForIndexPath = [self.tableView rectForRowAtIndexPath:self.indexPathBelowDraggedCell];

	BOOL hideDragIndicator = YES;
	if( [self.dragDelegate respondsToSelector:@selector(dragTableViewController:shouldHideDraggableIndicatorForDraggingToRow:)] )
		hideDragIndicator = [self.dragDelegate dragTableViewController:self shouldHideDraggableIndicatorForDraggingToRow:blankIndexPath];
	self.draggedCell.layer.shouldRasterize = NO;
	/*if( hideDragIndicator )
		[(UITableViewCell *)self.draggedCell setHighlighted:NO animated:YES];
*/
	[UIView animateWithDuration:0.25 delay:0 options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState) animations:^{
		//self.draggedCell.transform = CGAffineTransformMakeScale(1/CELL_WIDTH_SCALE, 1/CELL_HEIGHT_SCALE);
        [self dragTableViewController:self removeDraggableIndicatorsFromCell:oldDraggedCell];
        self.draggedCell.transform = CGAffineTransformInvert(CGAffineTransformMakeScale(CELL_WIDTH_SCALE, CELL_HEIGHT_SCALE));
        oldDraggedCell.frame = rectForIndexPath;
        /*
		if( hideDragIndicator )
			[self.indicatorDelegate dragTableViewController:self hideDraggableIndicatorsOfCell:oldDraggedCell];*/
	} completion:^(BOOL finished) {
        
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:blankIndexPath] withRowAnimation:UITableViewRowAnimationNone];
		
		[oldDraggedCell removeFromSuperview];

		if( [self.dragDelegate respondsToSelector:@selector(dragTableViewController:didEndDraggingToRow:)] )
			[self.dragDelegate dragTableViewController:self didEndDraggingToRow:blankIndexPath];

		UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(@"Drag completed.", @"Voiceover annoucement"));
	}];

	[self.tableView scrollRectToVisible:rectForIndexPath animated:YES];
}
- (void)fastCompleteGesturesWithTranslationPoint:(CGPoint) translation {
	[self updateFrameOfDraggedCellForTranlationPoint:translation];

	[self shuffleCellsOutOfWayOfDraggedCellIfNeeded];

	if ([self.dragDelegate respondsToSelector:@selector(dragTableViewController:willEndDraggingToRow:)])
		[self.dragDelegate dragTableViewController:self willEndDraggingToRow:self.indexPathBelowDraggedCell];

	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPathBelowDraggedCell] withRowAnimation:UITableViewRowAnimationNone];
	self.draggedCell.layer.shouldRasterize = NO;

	[self dragTableViewController:self removeDraggableIndicatorsFromCell:self.draggedCell];

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
	
	NSArray *arrayOfCoveredIndexPaths = [self.tableView indexPathsForRowsInRect:self.draggedCell.frame];

	CGRect blankCellFrame = [self.tableView rectForRowAtIndexPath:self.indexPathBelowDraggedCell];
	CGPoint blankCellCenter = {
		.x = CGRectGetMidX(blankCellFrame),
		.y = CGRectGetMidY(blankCellFrame)
	};
	CGRect rectOfCoveredCells = blankCellFrame;
	for (NSIndexPath *row in arrayOfCoveredIndexPaths) {
		CGRect newRect = CGRectUnion(rectOfCoveredCells, [self.tableView rectForRowAtIndexPath:row]);
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
		[self.tableView.dataSource tableView:self.tableView moveRowAtIndexPath:self.indexPathBelowDraggedCell toIndexPath:rowToMoveTo];

		/*
			Update the blank index path
		 */
		NSIndexPath *formerBlankIndexPath = self.indexPathBelowDraggedCell;
		self.indexPathBelowDraggedCell = rowToMoveTo;

		/*
			Then animate the row updates.
		 */
		if ( [self.tableView respondsToSelector:@selector(moveRowAtIndexPath:toIndexPath:)] )
			[self.tableView moveRowAtIndexPath:formerBlankIndexPath toIndexPath:rowToMoveTo];
		else {
			[self.tableView beginUpdates];
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:formerBlankIndexPath] withRowAnimation:UITableViewRowAnimationNone];
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPathBelowDraggedCell] withRowAnimation:UITableViewRowAnimationNone];
			[self.tableView endUpdates];
		}


		/*
			Keep the cell under the dragged cell hidden.
			This is a crucial line of code. Otherwise we get all kinds of graphical weirdness
		 */
		UITableViewCell *cellToHide = [self.tableView cellForRowAtIndexPath:self.indexPathBelowDraggedCell];
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
	CGPoint translation = [dragGestureRecognizer translationInView:self.tableView];
	
	CGFloat yOffsetOfDraggedCellCenter = initialYOffsetOfDraggedCellCenter + translation.y;
	
	CGFloat heightOfTableView = self.tableView.bounds.size.height;
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

		return MAX((1.0 / [UIScreen mainScreen].scale), (heightOfTableView) - yOffsetOfDraggedCellCenter);
	} else
		/*
			Return negative because going up.
		 */
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

	if ( signedAutoscrollDistance < 0 && self.tableView.contentOffset.y + signedAutoscrollDistance <= 0 )
		return AutoscrollStatusCellAtTop;

	if ( signedAutoscrollDistance > 0 && self.tableView.contentOffset.y + signedAutoscrollDistance >= self.tableView.contentSize.height - self.tableView.frame.size.height )
		return AutoscrollStatusCellAtBottom;

	return AutoscrollStatusCellInBetween;

}



#pragma mark -
#pragma mark miscellaneous helper methods

- (void)setInterferingElementsToEnabled:(BOOL)enabled {

	if (self.navigationController != nil) {
		self.navigationController.navigationBar.userInteractionEnabled = enabled;
		self.navigationController.toolbar.userInteractionEnabled = enabled;
	}

	if (self.tabBarController != nil)
		self.tabBarController.tabBar.userInteractionEnabled = enabled;

	self.tableView.scrollsToTop = enabled;
}


- (void)resetTableViewAndNavBarToTypical {
	[self setInterferingElementsToEnabled:YES];

	self.tableView.allowsSelection = YES;

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

- (UIView *)shadowViewWithFrame:(CGRect)frame andShadowPath:(CGPathRef)shadowPath {
	UIView *shadowView = [[UIView alloc] initWithFrame:frame];

	CGFloat commonShadowOpacity = 0.8;
	CGSize commonShadowOffset = {
		.width = 0,
		.height = 1
	};
	CGFloat commonShadowRadius = 4;

	shadowView.backgroundColor = [UIColor clearColor];
	shadowView.opaque = NO;
	shadowView.clipsToBounds = YES;

	shadowView.layer.shadowPath = shadowPath;
	shadowView.layer.shadowOpacity = commonShadowOpacity;
	shadowView.layer.shadowOffset = commonShadowOffset;
	shadowView.layer.shadowRadius = commonShadowRadius;

	return shadowView;
}
- (NSArray *)addShadowViewsToCell:(UITableViewCell *)selectedCell {

	if (selectedCell.selectedBackgroundView == nil)
		return nil;
    
    selectedCell.selectedBackgroundView.frame = selectedCell.frame;
	CGFloat heightOfViews = 10; // make it enough space to show whole shadow
	CGRect shadowPathFrame = selectedCell.selectedBackgroundView.frame;
	CGRect aboveShadowViewFrame = {
		.origin.x = 0,
		.origin.y = -heightOfViews,
		.size.width = shadowPathFrame.size.width,
		.size.height = heightOfViews
	};

	CGRect shadowPathRectFromAbovePerspective = {
		.origin.x = 0,
		.origin.y = -aboveShadowViewFrame.origin.y,
		.size = shadowPathFrame.size
	};

	UIBezierPath *aboveShadowPath = [UIBezierPath bezierPathWithRect:shadowPathRectFromAbovePerspective];

	CGRect belowShadowViewFrame = {
		.origin.x = 0,
		.origin.y = shadowPathFrame.size.height,
		.size.width = shadowPathFrame.size.width,
		.size.height = heightOfViews
	};

	CGRect shadowPathRectFromBelowPerspective = {
		.origin.x = 0,
		.origin.y = -belowShadowViewFrame.origin.y,
		.size = shadowPathFrame.size
	};

	UIBezierPath *belowShadowPath = [UIBezierPath bezierPathWithRect:shadowPathRectFromBelowPerspective];

	UIView *aboveShadowView = [self shadowViewWithFrame:aboveShadowViewFrame andShadowPath:aboveShadowPath.CGPath];
	aboveShadowView.tag = TAG_FOR_ABOVE_SHADOW_VIEW_WHEN_DRAGGING;
	aboveShadowView.alpha = 0; // set to 0 before adding as subview

	UIView *belowShadowView = [self shadowViewWithFrame:belowShadowViewFrame andShadowPath:belowShadowPath.CGPath];
	belowShadowView.tag = TAG_FOR_BELOW_SHADOW_VIEW_WHEN_DRAGGING;
	belowShadowView.alpha = 0;
    
    
    
	[selectedCell addSubview:aboveShadowView];
	[selectedCell addSubview:belowShadowView];
	[selectedCell bringSubviewToFront:belowShadowView];

	return [NSArray arrayWithObjects:aboveShadowView, belowShadowView, nil];
}

- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController addDraggableIndicatorsToCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {

	 NSArray *arrayOfShadowViews = [self addShadowViewsToCell:cell];

	for (UIView *shadowView in arrayOfShadowViews)
		shadowView.alpha = 1;
}

- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController hideDraggableIndicatorsOfCell:(UITableViewCell *)cell {
	UIView *aboveShadowView = [cell viewWithTag:TAG_FOR_ABOVE_SHADOW_VIEW_WHEN_DRAGGING];
	aboveShadowView.alpha = 0;
	
	UIView *belowShadowView = [cell viewWithTag:TAG_FOR_BELOW_SHADOW_VIEW_WHEN_DRAGGING];
	belowShadowView.alpha = 0;
}

- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController removeDraggableIndicatorsFromCell:(UITableViewCell *)cell {
	UIView *aboveShadowView = [cell viewWithTag:TAG_FOR_ABOVE_SHADOW_VIEW_WHEN_DRAGGING];
	[aboveShadowView removeFromSuperview];
	
	UIView *belowShadowView = [cell viewWithTag:TAG_FOR_BELOW_SHADOW_VIEW_WHEN_DRAGGING];
	[belowShadowView removeFromSuperview];
}


@end
