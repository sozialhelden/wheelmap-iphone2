//
//  InfiniteGallery.m
//  SuperTextView
//
//  Created by Stephen O'Connor on 10/26/11.
//  Copyright (c) 2011 Smart Mobile Factory GmbH. All rights reserved.
//

#import "InfiniteGallery.h"
#import <QuartzCore/QuartzCore.h>

#define kViewTagOffset 200

#define kPagingDirectionGoRight YES
#define kPagingDirectionGoLeft NO


@interface InfiniteGallery() {
    
    UIScrollView *scroller;
    
    UIView* currentView;
    UIView* nextView;
    UIView* prevView;
    
    int prevIndex;
    int currIndex;
    int nextIndex;
    
    CGRect pageZeroRect, pageOneRect, pageTwoRect;
    
    id<InfiniteGalleryDataSource> dataSource;
    id<InfiniteGalleryDelegate> delegate;
    
    BOOL wrapsAround;
    BOOL clampingDisabled;  // sort of a hack so everything plays nicely with UIScrollView
}

@property (nonatomic, assign) UIView *currentView;
@property (nonatomic, assign) UIView *nextView;
@property (nonatomic, assign) UIView *prevView;

- (UIView*)loadViewForPage:(int)pageNum;
- (UIView*)cachedViewForPage:(int)pageNum;
- (void)loadPages;

- (void)animateToPageNum:(int)pageNum;
- (void)clampContentOffsets;  // used if wrapsAround = NO



@end

@implementation InfiniteGallery
@synthesize nextView, prevView, currentView, dataSource, delegate;

- (void) dealloc
{
    self.delegate = nil;
    self.dataSource = nil;
    
    [scroller release];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.userInteractionEnabled = YES;
        
        scroller = [[UIScrollView alloc] initWithFrame:self.bounds];
        
        // a page is the width of the scroll view
        scroller.delegate = self;
        scroller.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        scroller.autoresizesSubviews = NO;
        scroller.pagingEnabled = YES;
        scroller.contentSize = CGSizeMake(scroller.frame.size.width * 3, scroller.frame.size.height);
        scroller.showsHorizontalScrollIndicator = NO;
        scroller.showsVerticalScrollIndicator = NO;
        scroller.scrollsToTop = NO;
        scroller.backgroundColor = [UIColor clearColor];
        scroller.clearsContextBeforeDrawing = YES;
        scroller.clipsToBounds = YES;
        
        self.wrapsAround = YES;
        
        [self addSubview:scroller];
        
        frame = self.bounds;        
        pageZeroRect = frame;
        
        frame.origin.x += frame.size.width;
        pageOneRect = frame;
        
        frame.origin.x += frame.size.width;
        pageTwoRect = frame;
        
        self.prevView = nil;
        self.currentView = nil;
        self.nextView = nil;
        
        scroller.contentSize = CGSizeMake(pageTwoRect.size.width + pageTwoRect.origin.x, pageTwoRect.size.height);
        [scroller scrollRectToVisible:pageOneRect animated:NO];
        
        self.delegate = nil;
        self.dataSource = nil;  // temp
        
        currIndex = 0;
        
    }
    return self;
}



-(id<InfiniteGalleryDataSource>)dataSource { return dataSource;}
-(void)setDataSource:(id<InfiniteGalleryDataSource>)ds
{
    if (!ds) {
        dataSource = nil;
        return;
    }
    
    if (dataSource) {
        [dataSource release];
        dataSource = nil;
        //currIndex = 0;
    }
    dataSource = [ds retain];
    
    if (dataSource) {
        //currIndex = 0;  // This should be set in the init method so that subclasses can set it and it not get changed here.
        int numPagesInGallery = [dataSource numberOfPagesForGallery:self];
        
        prevIndex = currIndex - 1 < 0 ? numPagesInGallery - 1 : currIndex - 1;
        nextIndex = currIndex + 1 > numPagesInGallery -1 ? 0 : currIndex + 1; 
        
        if (numPagesInGallery == 1){
            scroller.userInteractionEnabled = YES;
            nextIndex = 0;
            prevIndex = 0;
        }
        else{
            scroller.userInteractionEnabled = YES;
        }
        
        [self reloadData];
    }
    else
    {
        nextIndex = 0, currIndex = 0, prevIndex = 0;
        
        for (int i = 0; [scroller.subviews count]; i++) {
            [(UIView*)[scroller.subviews objectAtIndex: i] removeFromSuperview];
        }
    }
    
    
}

- (UIColor*)bgcolor { return scroller.backgroundColor;}
- (void)setBgcolor:(UIColor*)color {
    scroller.backgroundColor = color;
}


- (BOOL)wrapsAround { return wrapsAround;}
- (void)setWrapsAround:(BOOL)wraps
{
    wrapsAround = wraps;
    
    if (wrapsAround) {
        for (UIGestureRecognizer *r in [scroller gestureRecognizers]) {
            r.enabled = YES;
        }
        clampingDisabled = YES;
    }
    else
        clampingDisabled = NO;
}

- (void)reloadData
{
    // TODO - implement me!
    
    [self loadPages];
    
    if ([self.delegate respondsToSelector:@selector(gallery:didTurnToPage:totalPages:)]) {
        [self.delegate gallery:self didTurnToPage:currIndex totalPages: [self.dataSource numberOfPagesForGallery:self]];
    }
}

- (void)layoutSubviews
{
    //scroller.frame = self.bounds;
    //[CATransaction begin];
    
    CGRect frame = self.bounds;        
    scroller.frame = frame;
    pageZeroRect = frame;
    
    frame.origin.x += frame.size.width;
    pageOneRect = frame;
    
    frame.origin.x += frame.size.width;
    pageTwoRect = frame;
    
    if (currIndex == prevIndex) {
        // We only have a single page
        scroller.contentSize = CGSizeMake(scroller.frame.size.width, scroller.frame.size.height);
        [scroller scrollRectToVisible:CGRectMake(0, 0, scroller.frame.size.width, scroller.frame.size.height) animated:NO];
        
        self.prevView.frame = pageOneRect;
        self.currentView.frame = pageZeroRect;
        self.nextView.frame = pageTwoRect;
        
        return;
    }
    
    scroller.contentSize = CGSizeMake(pageTwoRect.size.width + pageTwoRect.origin.x, pageTwoRect.size.height);    
    scroller.contentOffset = pageOneRect.origin;
    
    self.prevView.frame = pageZeroRect;
    self.currentView.frame = pageOneRect;
    self.nextView.frame = pageTwoRect;
    
    //[CATransaction commit];
}

#pragma mark -
#pragma mark ScrollViewDelegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {     
	
    [self clampContentOffsets];  // this will do some magic if wrapsAround = NO;
    
    
	// We keep track of the index that we are scrolling to so that we     
	// know what data to load for each page.     
	if(sender.contentOffset.x > sender.frame.size.width) {         
		// We are moving forward. Load the current doc data on the first page. 
        prevIndex = currIndex;        
		currIndex = nextIndex;              
		nextIndex = (nextIndex + 1 > [self.dataSource numberOfPagesForGallery:self] -1) ? 0 : nextIndex + 1;         
        
	}     
	else if(sender.contentOffset.x < sender.frame.size.width) {         
		// We are moving backward. Load the current doc data on the last page.
        nextIndex = currIndex;                 
		currIndex = prevIndex;        
        prevIndex = (currIndex - 1 < 0) ? [self.dataSource numberOfPagesForGallery:self]-1 : currIndex - 1;         
        
	}     
    
    [self loadPages];  // now that the 3 page indices have been set, loadPages will ensure they are loaded and their frames set.
    
    // notify the delegate
    if ([self.delegate respondsToSelector:@selector(gallery:didTurnToPage:totalPages:)]) {
        [self.delegate gallery:self 
                 didTurnToPage:currIndex 
                    totalPages:[self.dataSource numberOfPagesForGallery:self]];
    }
    
	// Reset offset back to middle page     
	[sender scrollRectToVisible:pageOneRect animated:NO]; 
    
    
    
}

#pragma mark Changing Pages

- (void)gotoPageNumber:(int)pageNum
{
    pageNum = pageNum % [self.dataSource numberOfPagesForGallery:self];
    
    [self animateToPageNum:pageNum];
}

- (void)animateToPageNum:(int)pageNum
{
    if (currIndex == pageNum) {
        return;
    }
    
    self.hidden = YES;
    
    // Following is to fix the issue that calling -(void)animateToPageNum: with the first or last page 
    // doesn't commit animation. -(void)animateToPageNum:pageNum will fire the delegate method -(void)scrollViewDidScroll,
    // and the method calls [self clampContestOffsets]. The last method doesn't allow scrolling if the destination page is the first or last page,
    // so scroll animation will not be commited. To avoid this, we  temporaliy set wrapsAround to YES, and after the animation we set back wrapsAround to NO 
    // (in -(void)scrollViewDidEndScrollingAnimation: method).
    
    clampingDisabled = YES;
    
    BOOL pagingDirection;
    CGRect pageRect;
    
    // first determine which direction we want to go.  depending on the pageNum is higher than the current page index
    // here we figure out in the default case 
    if (pageNum > currIndex) {
        // then we will animate right
        pagingDirection = kPagingDirectionGoRight;
    }
    else if(pageNum < currIndex)
    {
        // then we animate left
        pagingDirection = kPagingDirectionGoLeft;
        
    }
    
    // but if the gallery can wrap around, we want to animate in the direction which has the shortest distance  (i.e. with wrapping around)
    if (wrapsAround == YES) {
        
        if (pagingDirection == kPagingDirectionGoRight) {
            if (   ([self.dataSource numberOfPagesForGallery:self] + currIndex) - pageNum < (pageNum - currIndex)) {
                pagingDirection = kPagingDirectionGoLeft;
            }
        }
        else{
            // currently set to go left
            if( ([self.dataSource numberOfPagesForGallery:self] + pageNum) - currIndex < (currIndex - pageNum) )
            {
                pagingDirection = kPagingDirectionGoRight;
            }
            
        }
    }
    
    if (pagingDirection == kPagingDirectionGoRight) {
        nextIndex = pageNum;
        pageRect = pageTwoRect;
    }
    else
    {
        prevIndex = pageNum;
        pageRect = pageZeroRect;
    }
    
    
    [self loadPages];  // load these pages with "inconsistent" page ordering
    
    // here we check which direction we're going (i.e. forward or backward) then set the self.nextView / self.prevView frame property.
    
    if (self.prevView == self.nextView) {
        if (pagingDirection == kPagingDirectionGoRight) {
            // then we are moving right and have to deal with self.nextView and pageTwoRect
            self.nextView.frame = pageTwoRect;
        }
        else if (pagingDirection == kPagingDirectionGoLeft)
        {
            // then we are dealing with self.prevView and pageZeroRect
            self.prevView.frame = pageZeroRect;
        }
    }
    
    
    // then we set up the new values for after the animation takes place (see scrollViewDidEndScrollingAnimation
    currIndex = pageNum;
    nextIndex = (currIndex + 1 > [self.dataSource numberOfPagesForGallery:self] -1) ? 0 : currIndex + 1;
    prevIndex = (currIndex - 1 < 0) ? [self.dataSource numberOfPagesForGallery:self]-1 : currIndex - 1; 
    
    [scroller scrollRectToVisible:pageRect animated:YES];
    // now look to the scrollViewDidEndScrollingAnimation: method
}

// The scroll view calls this method at the end of its implementations of the UIScrollView and setContentOffset:animated: and scrollRectToVisible:animated: methods, but only if animations are requested.  (i.e. if animated: YES) 
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // page order was reset in animateToPageNum
    NSLog(@"Should only fire when the gotoPageNumber method is called!");
    
    [self loadPages];  // now that the 3 page indices have been set, loadPages will ensure they are loaded and their frames set.
    
    // notify the delegate
    if ([self.delegate respondsToSelector:@selector(gallery:didTurnToPage:totalPages:)]) {
        [self.delegate gallery:self 
                 didTurnToPage:currIndex 
                    totalPages:[self.dataSource numberOfPagesForGallery:self]];
    }
    
	// Reset offset back to middle page     
	[scroller scrollRectToVisible:pageOneRect animated:NO];
    
    clampingDisabled = self.wrapsAround;   // look comments in -(void)gotoPageNumner method.
    
    self.hidden = NO;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self clampContentOffsets];
    
    // here we could ensure the frame of next/prev are correct.  Need a way where this only gets set once after crossing a threshold. 
    //  I write that because it seems inefficient to have to reset a frame value every time the scrollview moves.
    if (self.prevView == self.nextView) {
        
        if (scroller.contentOffset.x < scroller.frame.size.width) {
            self.prevView.frame = pageZeroRect;
        }
        else if (scroller.contentOffset.x > scroller.frame.size.width * 2)
        {
            self.nextView.frame = pageTwoRect;
        }
    }
    
}




- (void)clampContentOffsets
{
    if (clampingDisabled == NO) {
        //then we have to clamp the offsets
        if (currIndex == 0) {
            // then don't allow it to scroll left
            if (scroller.contentOffset.x < pageOneRect.origin.x ) {
                scroller.contentOffset = CGPointMake(pageOneRect.origin.x, scroller.contentOffset.y);
                
                // and we have to disable the SwipeGestureRecognizer so that his callback doesn't fire, but really we can disable them all.
                for (UIGestureRecognizer *r in [scroller gestureRecognizers]) {
                    r.enabled = NO;
                }
            }
        }
        else if (currIndex == [self.dataSource numberOfPagesForGallery: self] - 1){
            // then we are on the last page and shouldn't allow it to go right.
            if (scroller.contentOffset.x > pageOneRect.origin.x ) {
                scroller.contentOffset = CGPointMake(pageOneRect.origin.x, scroller.contentOffset.y);
                
                for (UIGestureRecognizer *r in [scroller gestureRecognizers]) {
                    r.enabled = NO;
                }
            }
        }
        else
        {
            
        }
        
        // re-enable all swipe gestures
        for (UIGestureRecognizer *r in [scroller gestureRecognizers]) {
            r.enabled = YES;
        }
    }
    
}




- (void)loadPages
{
    int pageIndex;  // the page we will work on
    CGRect pageRect;  // the frame that the controller's view will take
    UIView *page = nil;  // the pageController for the page
    
    // remove/dealloc/free memory of any controllers we won't need anymore
    for (int i = 0 ; i < [scroller.subviews count]; i++) {
        
        UIView *aView = [scroller.subviews objectAtIndex:i];
        
        // now remove what isn't part of the functionality.  This means views with the following tags:
        // views that have a tag associated with a pageNumber
        // views that have been reserved (i.e. views in that aren't subviews in the scroller)
        
        if (aView.tag == kViewTagOffset + prevIndex || 
            aView.tag == kViewTagOffset + currIndex || 
            aView.tag == kViewTagOffset + nextIndex
            ) 
        {
            continue;
        }
        else
        {
            [aView removeFromSuperview];
        }
    }
    
    if (currIndex == prevIndex) {
        // We only have a single page
        pageIndex = 0;
        page = [self loadViewForPage:pageIndex];
        page.frame = pageZeroRect;
        page.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [scroller addSubview: page];
        scroller.contentSize = CGSizeMake(scroller.frame.size.width, scroller.frame.size.height);
        [scroller scrollRectToVisible:CGRectMake(0, 0, scroller.frame.size.width, scroller.frame.size.height) animated:NO];
        return;
    }
    
    
    // 0, 1, 2 corresponds to previous, current, and next
    for (int i = 0; i < 3; i++) {
        switch (i) {
            case 0:
                pageIndex = prevIndex;
                pageRect = pageZeroRect;
                break;
            case 1:
                pageIndex = currIndex;
                pageRect = pageOneRect;
                break;
            case 2:
                pageIndex = nextIndex;
                pageRect = pageTwoRect;
                break;
        }
        
        page = [self cachedViewForPage:pageIndex];  // will return the controller if already a child, nil otherwise
        
        // if non-nil, that means this controller has been added to the parent already and is a subview of self.view
        if (page) {
            page.frame = pageRect;
            [scroller bringSubviewToFront:page];
        }
        else
        {
            // we have to load the pageViewController.  It will set the view's tag to a value corresponding to its page number
            page = [self loadViewForPage:pageIndex];
            page.frame = pageRect;
            page.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [scroller addSubview: page];
            
            
        }
        
        switch (i) {
            case 0:
                self.prevView = page;
                break;
            case 1:
                self.currentView = page;
                break;
            case 2:
                self.nextView = page;
                break;
        }
    }
    
}

-(UIView*)cachedViewForPage:(int)pageNum
{
    UIView *theView = [scroller viewWithTag:kViewTagOffset + pageNum];
    if (theView == nil) {
        return nil;
    }
    
    return theView;
    
}


-(UIView*)loadViewForPage:(int)pageNum
{
    // TODO, first see if the desired page is already in the scrollview, only THEN, reload him
    
    UIView *pageView = nil;
    
    if (pageView == nil) {
        pageView = [self.dataSource viewForGallery: self pageNum: pageNum pagesize:self.bounds.size];
        pageView.tag = kViewTagOffset + pageNum;       
    }
    
    return pageView;
}



#pragma mark Testing / Expanding Gallery Delegate

- (UIView*)viewForGallery:(InfiniteGallery*)g pageNum:(int)pageNum pagesize:(CGSize)size
{
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    
    
    UIImageView *view = [[[UIImageView alloc] initWithFrame:frame] autorelease];
    switch (pageNum) {
        case 0:
            view.image = [UIImage imageNamed:@"puppy01.jpg"];
            break;
        case 1:
            view.image = [UIImage imageNamed:@"puppy02.jpg"];
            break;
        case 2:
            view.image = [UIImage imageNamed:@"puppy03.jpg"];
            break;
        case 3:
            view.image = [UIImage imageNamed:@"puppy04.jpg"];
            break;
        case 4:
            view.image = [UIImage imageNamed:@"puppy05.jpg"];
            
            break;    
        default:
            break;
    }
    view.contentMode = UIViewContentModeScaleAspectFit;
    
    return view;
    
}
- (int)numberOfPagesForGallery:(InfiniteGallery*)g
{
    return 5;
}

-(void)breakpoint
{
    NSLog(@"Breaking for inspection");
}

@end
