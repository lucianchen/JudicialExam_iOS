//
//  PaperScrollViewController.m
//  JudicialExam
//
//  Created by Chen, Liang on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaperScrollViewController.h"

@interface PaperScrollViewController()

- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (NSError*)loadDocument:(CGPDFDocumentRef*)docRefPointer;
- (void)layoutPages;
- (NSArray*)visiblePages:(NSInteger)currentPage;
- (PaperQuestionView *)anyRecycledPage;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (void)configurePage:(PaperQuestionView *)page forIndex:(NSUInteger)index;
- (IBAction)handleDoubleTap:(UIGestureRecognizer *)sender;
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center scrollView:(UIScrollView*)view;
- (PaperQuestionView*)currentView;

- (void)pageSelectionDidChange:(NSNotification*)notification;
@end

@implementation PaperScrollViewController
@synthesize pageSelector;

- (void)dealloc{
    [pageSelector release];
    [recycledPages release];
    [visiblePages release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    firstNeededIndex = NSNotFound;
	lastNeededIndex = NSNotFound;
	self.pagingScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
	recycledPages = [[NSMutableArray alloc] init];
	visiblePages  = [[NSMutableArray alloc] init];
    
    pagingScrollView.delegate = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
										 duration:(NSTimeInterval)duration
{
	//[recycledPages addObjectsFromArray:visiblePages];
    //	[visiblePages removeAllObjects];
	
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
	pagingScrollView.frame = pagingScrollViewFrame;
	pagingScrollView.contentSize = CGSizeMake(pagingScrollViewFrame.size.width * pageSelector.totalPage,
											  pagingScrollViewFrame.size.height);
	CGPoint offset = pagingScrollView.contentOffset;
	offset.x = (pageSelector.currentPage - 1) * pagingScrollViewFrame.size.width;
	pagingScrollView.contentOffset = offset;
	
	for (PaperQuestionView *page in visiblePages) {
		page.frame = [self frameForPageAtIndex:page.index];
		[page reLayout];
	}
	
	[self layoutPages];
}

- (void)setPageSelector:(PaperPageSelector *)selector{
    [pageSelector autorelease];
    pageSelector = [selector retain];
    
    [pageSelector addPageObserver:self selector:@selector(pageSelectionDidChange:)];
}

- (void)pageSelectionDidChange:(NSNotification*)notification{
    
}

@end
